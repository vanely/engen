#!/bin/bash
# ================================================================
# engen — Selective Tool Removal
# Reads installed tools from JSON config and removes selected ones.
# ================================================================

remove_installs() {
  local config_file="${1}"

  # If no config specified, find one
  if [[ -z "${config_file}" ]]; then
    section_header "Cleanup - Remove Installed Tools"
    bline ""

    local configs=()
    for f in "${ENGEN_CONFIG_DIR}"/*.json; do
      [ -f "$f" ] || continue
      configs+=("$f")
    done

    if [ ${#configs[@]} -eq 0 ]; then
      warn "No JSON configs found."
      bline "Tools installed without a config can't be tracked."
      echo ""
      return
    fi

    if [ ${#configs[@]} -eq 1 ]; then
      config_file="${configs[0]}"
    else
      bline "Select environment:"
      for i in "${!configs[@]}"; do
        local name
        name=$(python3 -c "import json; print(json.load(open('${configs[$i]}'))['name'])" 2>/dev/null)
        bline "  [$i] ${name}"
      done
      local idx
      idx=$(prompt ">" "0")
      config_file="${configs[$idx]}"
    fi
  fi

  if [[ ! -f "${config_file}" ]]; then
    err "Config not found"
    return 1
  fi

  # Read installed tools
  local tools_json
  tools_json=$(python3 -c "
import json
with open('${config_file}') as f:
    data = json.load(f)
tools = data.get('tools', {}).get('installed', [])
if not tools:
    print('EMPTY')
else:
    for i, t in enumerate(tools):
        print(f'{i}|{t[\"name\"]}|{t[\"method\"]}')
" 2>/dev/null)

  if [[ "${tools_json}" == "EMPTY" ]] || [[ -z "${tools_json}" ]]; then
    warn "No tools tracked in this config."
    bline "Install tools through engen to track them."
    echo ""
    return
  fi

  bline ""
  bline "Installed tools:"
  local tool_names=() tool_methods=()
  while IFS='|' read -r idx name method; do
    bline "  [${idx}] ${name} (${method})"
    tool_names+=("$name")
    tool_methods+=("$method")
  done <<< "${tools_json}"

  bline ""
  local selection
  selection=$(prompt "Remove (numbers, space-separated, or 'all')" "")

  local indices_to_remove=()
  if [[ "${selection,,}" == "all" ]]; then
    for i in "${!tool_names[@]}"; do
      indices_to_remove+=("$i")
    done
  else
    read -ra indices_to_remove <<< "${selection}"
  fi

  # Remove in reverse order to keep indices valid
  IFS=$'\n' sorted=($(printf '%s\n' "${indices_to_remove[@]}" | sort -rn))
  unset IFS

  for idx in "${sorted[@]}"; do
    local name="${tool_names[$idx]}"
    local method="${tool_methods[$idx]}"

    echo -n "  Removing ${name} (${method})..."

    case "${method}" in
      apt)
        sudo apt-get remove -y "${name}" &>/dev/null && echo " done" || echo " failed"
        ;;
      snap)
        sudo snap remove "${name}" &>/dev/null && echo " done" || echo " failed"
        ;;
      brew)
        brew uninstall "${name}" &>/dev/null && echo " done" || echo " failed"
        ;;
      npm-global)
        npm uninstall -g "${name}" &>/dev/null && echo " done" || echo " failed"
        ;;
      rustup)
        rustup self uninstall -y &>/dev/null && echo " done" || echo " failed"
        ;;
      *)
        echo " (manual removal needed for ${method})"
        ;;
    esac

    # Remove from config
    python3 -c "
import json, sys
name = sys.argv[1]
with open(sys.argv[2]) as f:
    data = json.load(f)
data['tools']['installed'] = [t for t in data.get('tools', {}).get('installed', []) if t['name'] != name]
with open(sys.argv[2], 'w') as f:
    json.dump(data, f, indent=2)
" "${name}" "${config_file}"
  done

  bline ""
  ok "Cleanup complete"
  echo ""
}
