#!/bin/bash

#############################################################################
# Cursor IDE Installation Script
# 
# Installs Cursor AI-powered code editor on Linux systems
# Supports multiple installation methods with automatic detection
# 
# Author: AI Assistant
# Target: Ubuntu/Pop!_OS/KDE Neon and derivatives
# Requirements: curl, wget, or browser for download
#############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Script configuration
CURSOR_DOWNLOAD_URL="https://download.cursor.sh"
INSTALL_DIR="$HOME/.local/share/cursor"
DESKTOP_FILE="$HOME/.local/share/applications/cursor.desktop"
BIN_LINK="$HOME/.local/bin/cursor"
TEMP_DIR="/tmp/cursor-install"

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should NOT be run as root. Run as normal user."
        exit 1
    fi
}

# Display header
show_header() {
    clear
    echo "################################################################"
    echo "#                                                              #"
    echo "#              CURSOR IDE INSTALLATION SCRIPT                 #"
    echo "#                                                              #"
    echo "#          AI-Powered Code Editor Installation                 #"
    echo "#                                                              #"
    echo "################################################################"
    echo
}

# System information
show_system_info() {
    log "System Information:"
    echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown Linux")"
    echo "Architecture: $(uname -m)"
    echo "User: $USER"
    echo "Home: $HOME"
    echo
}

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    local deps=("curl" "wget" "unzip")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        warning "Missing dependencies: ${missing[*]}"
        info "Installing missing dependencies..."
        sudo apt update
        sudo apt install -y "${missing[@]}"
    fi
    
    log "Dependencies check complete"
}

# Create necessary directories
create_directories() {
    log "Creating installation directories..."
    
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/bin" 
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        warning "Adding ~/.local/bin to PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# Detect best installation method
detect_installation_method() {
    log "Detecting best installation method..."
    
    local arch=$(uname -m)
    local os_id=$(lsb_release -i 2>/dev/null | cut -f2 | tr '[:upper:]' '[:lower:]' || echo "unknown")
    
    info "Architecture: $arch"
    info "OS: $os_id"
    
    # Default to AppImage for maximum compatibility
    INSTALL_METHOD="appimage"
    
    # Check if we can use .deb package (Ubuntu/Debian derivatives)
    if [[ "$os_id" =~ (ubuntu|debian|pop|neon) ]] && [[ "$arch" == "x86_64" ]]; then
        info "Debian-based system detected - can use .deb package"
        INSTALL_METHOD="deb"
    fi
    
    highlight "Selected installation method: $INSTALL_METHOD"
}

# Download Cursor IDE
download_cursor() {
    log "Downloading Cursor IDE..."
    
    cd "$TEMP_DIR"
    
    case "$INSTALL_METHOD" in
        "deb")
            info "Downloading .deb package..."
            
            # Method 1: Try to get download link from official website
            DEB_URL=""
            if command -v curl &> /dev/null; then
                info "Checking Cursor website for latest download link..."
                # Try to extract download URL from the official website
                DEB_URL=$(curl -s https://cursor.sh/ | grep -o 'https://downloads\.cursor\.com[^"]*\.deb' | head -1)
            fi
            
            # Method 2: Fallback to known working URL pattern (may need version updates)
            if [[ -z "$DEB_URL" ]]; then
                warning "Could not extract latest URL, using known working link"
                DEB_URL="https://downloads.cursor.com/production/b753cece5c67c47cb5637199a5a5de2b7100c18f/linux/x64/deb/amd64/deb/cursor_1.6.35_amd64.deb"
            fi
            
            info "Download URL: $DEB_URL"
            
            # Download with progress and retry
            if ! wget --progress=bar:force -O cursor.deb "$DEB_URL"; then
                warning "wget failed, trying with curl..."
                if ! curl -L --progress-bar -o cursor.deb "$DEB_URL"; then
                    error "Both wget and curl failed to download"
                    return 1
                fi
            fi
            
            # Verify download
            if [[ ! -f cursor.deb ]] || [[ $(stat -c%s cursor.deb) -lt 50000000 ]]; then
                error "Download appears incomplete or corrupted"
                info "File size: $(stat -c%s cursor.deb 2>/dev/null || echo '0') bytes"
                return 1
            fi
            ;;
            
        "appimage")
            info "Downloading AppImage..."
            
            # Try to get AppImage URL from official website
            APPIMAGE_URL=""
            if command -v curl &> /dev/null; then
                info "Checking Cursor website for AppImage download..."
                # Try to extract AppImage URL (if available)
                APPIMAGE_URL=$(curl -s https://cursor.sh/ | grep -o 'https://downloads\.cursor\.com[^"]*\.AppImage' | head -1)
            fi
            
            # Fallback - AppImage might not be available, suggest manual download
            if [[ -z "$APPIMAGE_URL" ]]; then
                warning "AppImage URL not found automatically"
                info "Please check https://cursor.sh/ for AppImage availability"
                info "Falling back to .deb installation method"
                INSTALL_METHOD="deb"
                download_cursor  # Recursive call with deb method
                return $?
            fi
            
            info "Download URL: $APPIMAGE_URL"
            
            if ! wget --progress=bar:force -O cursor.AppImage "$APPIMAGE_URL"; then
                warning "wget failed, trying with curl..."
                if ! curl -L --progress-bar -o cursor.AppImage "$APPIMAGE_URL"; then
                    error "Failed to download AppImage"
                    return 1
                fi
            fi
            ;;
            
        *)
            error "Unknown installation method: $INSTALL_METHOD"
            exit 1
            ;;
    esac
    
    log "Download completed successfully"
}

# Install .deb package
install_deb() {
    log "Installing Cursor IDE from .deb package..."
    
    sudo dpkg -i cursor.deb || {
        warning "Dependencies missing, fixing..."
        sudo apt-get install -f -y
    }
    
    # Verify installation
    if command -v cursor &> /dev/null; then
        log "Cursor IDE installed successfully via .deb package"
        CURSOR_BINARY=$(which cursor)
    else
        error ".deb installation failed"
        return 1
    fi
}

# Install AppImage
install_appimage() {
    log "Installing Cursor IDE from AppImage..."
    
    # Make AppImage executable
    chmod +x cursor.AppImage
    
    # Move to installation directory
    mv cursor.AppImage "$INSTALL_DIR/cursor.AppImage"
    
    # Create wrapper script
    tee "$BIN_LINK" << EOF
#!/bin/bash
exec "$INSTALL_DIR/cursor.AppImage" "\$@"
EOF
    
    chmod +x "$BIN_LINK"
    
    log "Cursor IDE AppImage installed successfully"
    CURSOR_BINARY="$BIN_LINK"
}

# Create desktop entry
create_desktop_entry() {
    log "Creating desktop entry..."
    
    # Extract icon if possible (for AppImage)
    local icon_path="$INSTALL_DIR/cursor.png"
    
    if [[ "$INSTALL_METHOD" == "appimage" ]]; then
        # Try to extract icon from AppImage
        if command -v magick &> /dev/null || command -v convert &> /dev/null; then
            "$INSTALL_DIR/cursor.AppImage" --appimage-extract-and-run --version &>/dev/null || true
        fi
        
        # Fallback: download cursor icon
        if [[ ! -f "$icon_path" ]]; then
            info "Downloading Cursor icon..."
            curl -s -L "https://cursor.sh/favicon.ico" -o "$icon_path" 2>/dev/null || {
                warning "Could not download icon, using default"
                icon_path="text-editor"
            }
        fi
    else
        # For .deb installation, use system icon
        icon_path="cursor"
    fi
    
    # Create desktop entry
    tee "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=$CURSOR_BINARY %F
Icon=$icon_path
Type=Application
StartupNotify=true
Categories=Development;TextEditor;IDE;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/javascript;application/json;text/css;text/html;text/xml;text/markdown;
StartupWMClass=Cursor
EOF
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi
    
    log "Desktop entry created successfully"
}

# Set up file associations
setup_file_associations() {
    log "Setting up file associations..."
    
    # Common development file extensions
    local extensions=(
        "js" "ts" "jsx" "tsx" "json" "html" "css" "scss" "less"
        "py" "rb" "go" "rs" "java" "cpp" "c" "h" "hpp"
        "php" "xml" "yaml" "yml" "toml" "ini" "conf"
        "md" "txt" "log" "sh" "bash" "zsh"
    )
    
    info "Cursor can be associated with development files"
    info "File extensions that can be associated: ${extensions[*]}"
    
    read -p "Would you like to make Cursor the default editor for common development files? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for ext in "${extensions[@]}"; do
            xdg-mime default cursor.desktop "text/x-$ext" 2>/dev/null || true
            xdg-mime default cursor.desktop "application/x-$ext" 2>/dev/null || true
        done
        log "File associations configured"
    else
        info "Skipped file associations"
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check if cursor command is available
    if command -v cursor &> /dev/null; then
        local version=$(cursor --version 2>/dev/null || echo "Version check failed")
        log "Cursor IDE installed successfully!"
        info "Command: cursor"
        info "Version: $version"
        info "Location: $(which cursor)"
    else
        error "Cursor command not found in PATH"
        return 1
    fi
    
    # Check desktop entry
    if [[ -f "$DESKTOP_FILE" ]]; then
        log "Desktop entry created: $DESKTOP_FILE"
    fi
    
    # Display usage instructions
    echo
    highlight "=== CURSOR IDE INSTALLATION COMPLETE ==="
    echo
    info "Usage Instructions:"
    echo "  • Launch from command line: cursor"
    echo "  • Launch from applications menu: Search for 'Cursor'"
    echo "  • Open file: cursor filename.js"
    echo "  • Open directory: cursor /path/to/project"
    echo
    
    info "Integration with development workflow:"
    echo "  • Git integration: Built-in"
    echo "  • AI assistance: Built-in (requires account)"
    echo "  • Extensions: VS Code compatible"
    echo "  • Terminal: Integrated terminal available"
    echo
}

# Cleanup temporary files
cleanup() {
    log "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Handle installation failure
handle_failure() {
    error "Installation failed!"
    
    echo
    warning "Troubleshooting steps:"
    echo "1. Check internet connection"
    echo "2. Verify download URLs are accessible"
    echo "3. Check available disk space"
    echo "4. Try running with verbose output: bash -x $0"
    echo
    
    info "Manual installation options:"
    echo "• Download directly from: https://cursor.sh/"
    echo "• Try different installation method"
    echo "• Check Cursor documentation for alternatives"
    
    cleanup
    exit 1
}

# Uninstall function
uninstall_cursor() {
    log "Uninstalling Cursor IDE..."
    
    # Remove files
    rm -f "$BIN_LINK"
    rm -f "$DESKTOP_FILE"
    rm -rf "$INSTALL_DIR"
    
    # For .deb installation
    if dpkg -l | grep -q cursor; then
        sudo apt remove cursor -y
    fi
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi
    
    log "Cursor IDE uninstalled successfully"
}

# Main installation function
install_cursor() {
    show_header
    show_system_info
    
    read -p "This will install Cursor IDE on your system. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled"
        exit 0
    fi
    
    # Set up error handling
    trap handle_failure ERR
    
    check_root
    check_dependencies  
    create_directories
    detect_installation_method
    download_cursor
    
    case "$INSTALL_METHOD" in
        "deb")
            install_deb
            ;;
        "appimage")
            install_appimage
            ;;
    esac
    
    create_desktop_entry
    setup_file_associations
    verify_installation
    cleanup
    
    log "Installation process completed successfully!"
}

# Command line argument handling
case "${1:-install}" in
    "install")
        install_cursor
        ;;
    "uninstall")
        uninstall_cursor
        ;;
    "verify")
        verify_installation
        ;;
    "--help"|"-h")
        echo "Cursor IDE Installation Script"
        echo
        echo "Usage: $0 [command]"
        echo
        echo "Commands:"
        echo "  install    Install Cursor IDE (default)"
        echo "  uninstall  Remove Cursor IDE"  
        echo "  verify     Check installation status"
        echo "  --help     Show this help message"
        echo
        ;;
    *)
        error "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
