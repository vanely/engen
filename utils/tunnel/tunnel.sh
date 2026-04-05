#!/bin/bash
# ================================================================
# engen — Cloudflare Tunnel with TinyURL
# Expose any localhost port to the internet via a temporary
# Cloudflare quick tunnel, shortened with TinyURL.
#
# Usage:
#   tunnel start <port>       # start tunnel on port, get tiny URL
#   tunnel stop               # stop active tunnel
#   tunnel status             # show active tunnel info
#   tunnel url                # print just the short URL
#   tunnel list               # list common ports to tunnel
#
# Dependencies: cloudflared, curl
# ================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TUNNEL_PID_FILE="/tmp/engen-tunnel.pid"
TUNNEL_LOG="/tmp/engen-tunnel.log"
TUNNEL_URL_FILE="/tmp/engen-tunnel-url.txt"
TUNNEL_SHORT_URL_FILE="/tmp/engen-tunnel-short-url.txt"
TUNNEL_PORT_FILE="/tmp/engen-tunnel-port.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ----------------------------------------------------------------
# Shorten a URL (tries multiple free services, no auth needed)
# ----------------------------------------------------------------
shorten_url() {
    local long_url="${1}"
    local short_url

    # ulvis.net — single redirect, no blacklisting
    short_url=$(curl -s "https://ulvis.net/api.php?url=${long_url}" 2>/dev/null)
    if [[ -n "${short_url}" ]] && [[ "${short_url}" == https://* ]]; then
        echo "${short_url}"
        return
    fi

    # Fallback — return original
    echo "${long_url}"
}

# ----------------------------------------------------------------
# Start tunnel
# ----------------------------------------------------------------
start_tunnel() {
    local port="${1:-}"

    if [[ -z "${port}" ]]; then
        echo ""
        echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}║  Tunnel — Expose Local Port              ║${NC}"
        echo -e "${BOLD}╠══════════════════════════════════════════╝${NC}"
        echo "║"
        echo "║  Common ports:"
        echo "║    3000  React / Next.js dev server"
        echo "║    3001  Dashboard"
        echo "║    4000  GraphQL / API server"
        echo "║    5173  Vite dev server"
        echo "║    5678  n8n"
        echo "║    8000  Django / FastAPI"
        echo "║    8080  General dev server"
        echo "║"
        echo -ne "║  Port to expose: "
        read -r port
        echo ""
    fi

    # Validate port
    if ! [[ "${port}" =~ ^[0-9]+$ ]] || [ "${port}" -lt 1 ] || [ "${port}" -gt 65535 ]; then
        echo -e "${RED}Invalid port: ${port}${NC}"
        return 1
    fi

    # Check if something is listening on that port
    if ! curl -s -o /dev/null --connect-timeout 2 "http://localhost:${port}" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Nothing seems to be running on port ${port}${NC}"
        echo -ne "Continue anyway? (y/n): "
        read -r confirm
        [[ "$(echo "${confirm}" | tr '[:upper:]' '[:lower:]')" != "y" ]] && return 0
    fi

    # Check cloudflared
    if ! command -v cloudflared &>/dev/null; then
        echo -e "${RED}cloudflared not installed.${NC}"
        echo "Install: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/"
        return 1
    fi

    # Stop existing tunnel if running
    stop_tunnel 2>/dev/null || true

    echo -ne "Starting tunnel on port ${port}..."

    # Start cloudflared in background
    nohup cloudflared tunnel --url "http://localhost:${port}" > "${TUNNEL_LOG}" 2>&1 &
    echo $! > "${TUNNEL_PID_FILE}"
    echo "${port}" > "${TUNNEL_PORT_FILE}"

    # Wait for URL to appear in logs (up to 15 seconds)
    local attempts=0
    local tunnel_url=""
    while [ $attempts -lt 30 ]; do
        tunnel_url=$(grep -aoP 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' "${TUNNEL_LOG}" 2>/dev/null | head -1)
        if [ -n "${tunnel_url}" ]; then
            break
        fi
        sleep 0.5
        attempts=$((attempts + 1))
    done

    if [ -z "${tunnel_url}" ]; then
        echo -e " ${RED}✗${NC}"
        echo "Could not extract tunnel URL. Check ${TUNNEL_LOG}"
        return 1
    fi

    echo "${tunnel_url}" > "${TUNNEL_URL_FILE}"
    echo -e " ${GREEN}✓${NC}"

    # Shorten the URL
    echo -ne "Shortening URL..."
    local short_url
    short_url=$(shorten_url "${tunnel_url}")
    echo "${short_url}" > "${TUNNEL_SHORT_URL_FILE}"
    echo -e " ${GREEN}✓${NC}"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Tunnel Active                           ║${NC}"
    echo -e "${BOLD}╠══════════════════════════════════════════╝${NC}"
    echo "║"
    echo -e "║  Local:    ${CYAN}http://localhost:${port}${NC}"
    echo -e "║  Tunnel:   ${DIM}${tunnel_url}${NC}"
    echo -e "║  Share:    ${GREEN}${BOLD}${short_url}${NC}"
    echo "║"
    echo -e "║  PID:      $(cat "${TUNNEL_PID_FILE}")"
    echo -e "║  Log:      ${TUNNEL_LOG}"
    echo "║"
    echo -e "║  ${DIM}Stop with: tunnel stop${NC}"
    echo ""

    # Copy to clipboard if xclip is available
    if command -v xclip &>/dev/null; then
        echo -n "${short_url}" | xclip -selection clipboard
        echo -e "${DIM}Short URL copied to clipboard.${NC}"
    elif command -v xsel &>/dev/null; then
        echo -n "${short_url}" | xsel --clipboard
        echo -e "${DIM}Short URL copied to clipboard.${NC}"
    fi
}

# ----------------------------------------------------------------
# Stop tunnel
# ----------------------------------------------------------------
stop_tunnel() {
    if [ -f "${TUNNEL_PID_FILE}" ]; then
        local pid
        pid=$(cat "${TUNNEL_PID_FILE}")
        if kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}"
            echo -e "Tunnel stopped ${DIM}(PID ${pid})${NC}"
        else
            echo "Tunnel process not running (stale PID)"
        fi
        rm -f "${TUNNEL_PID_FILE}" "${TUNNEL_URL_FILE}" "${TUNNEL_SHORT_URL_FILE}" "${TUNNEL_PORT_FILE}"
    else
        echo "No tunnel running"
    fi
}

# ----------------------------------------------------------------
# Status
# ----------------------------------------------------------------
show_status() {
    if [ -f "${TUNNEL_PID_FILE}" ] && kill -0 "$(cat "${TUNNEL_PID_FILE}")" 2>/dev/null; then
        local port="?"
        [ -f "${TUNNEL_PORT_FILE}" ] && port=$(cat "${TUNNEL_PORT_FILE}")
        local full_url="?"
        [ -f "${TUNNEL_URL_FILE}" ] && full_url=$(cat "${TUNNEL_URL_FILE}")
        local short_url="?"
        [ -f "${TUNNEL_SHORT_URL_FILE}" ] && short_url=$(cat "${TUNNEL_SHORT_URL_FILE}")

        echo ""
        echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}║  Tunnel Status                           ║${NC}"
        echo -e "${BOLD}╠══════════════════════════════════════════╝${NC}"
        echo "║"
        echo -e "║  Status:   ${GREEN}ACTIVE${NC}"
        echo -e "║  Port:     ${port}"
        echo -e "║  Local:    ${CYAN}http://localhost:${port}${NC}"
        echo -e "║  Tunnel:   ${DIM}${full_url}${NC}"
        echo -e "║  Share:    ${GREEN}${BOLD}${short_url}${NC}"
        echo -e "║  PID:      $(cat "${TUNNEL_PID_FILE}")"
        echo ""
    else
        echo -e "Tunnel: ${RED}NOT RUNNING${NC}"
    fi
}

# ----------------------------------------------------------------
# Just print the short URL
# ----------------------------------------------------------------
show_url() {
    if [ -f "${TUNNEL_SHORT_URL_FILE}" ]; then
        cat "${TUNNEL_SHORT_URL_FILE}"
    else
        echo "No tunnel URL available. Start with: tunnel start <port>"
        return 1
    fi
}

# ----------------------------------------------------------------
# Interactive port selection
# ----------------------------------------------------------------
list_ports() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Common Ports                            ║${NC}"
    echo -e "${BOLD}╠══════════════════════════════════════════╝${NC}"
    echo "║"
    echo "║  [0]  3000  React / Next.js dev server"
    echo "║  [1]  3001  Dashboard / Storybook"
    echo "║  [2]  4000  GraphQL / API server"
    echo "║  [3]  5173  Vite dev server"
    echo "║  [4]  5678  n8n"
    echo "║  [5]  8000  Django / FastAPI"
    echo "║  [6]  8080  General dev server / Adminer"
    echo "║  [7]  8888  Jupyter Notebook"
    echo "║"
    echo "║  Or enter a custom port number"
    echo "║"
    echo -ne "║  > "
    read -r choice

    local ports=(3000 3001 4000 5173 5678 8000 8080 8888)
    local port

    if [[ "${choice}" =~ ^[0-7]$ ]]; then
        port="${ports[$choice]}"
    elif [[ "${choice}" =~ ^[0-9]+$ ]]; then
        port="${choice}"
    else
        echo -e "${RED}Invalid selection${NC}"
        return 1
    fi

    start_tunnel "${port}"
}

# ----------------------------------------------------------------
# Entry point
# ----------------------------------------------------------------
case "${1:-}" in
    start)
        start_tunnel "${2:-}"
        ;;
    stop)
        stop_tunnel
        ;;
    status)
        show_status
        ;;
    url)
        show_url
        ;;
    list)
        list_ports
        ;;
    *)
        echo "Usage: tunnel {start <port>|stop|status|url|list}"
        echo ""
        echo "  start <port>   Start tunnel on specified port"
        echo "  start          Interactive port selection"
        echo "  stop           Stop active tunnel"
        echo "  status         Show tunnel info + short URL"
        echo "  url            Print just the short URL"
        echo "  list           Pick from common ports"
        ;;
esac
