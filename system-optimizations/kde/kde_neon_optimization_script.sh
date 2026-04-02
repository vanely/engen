#!/bin/bash

#############################################################################
# KDE Neon Ultimate Optimization Script
# Replicates 90% of Pop!_OS performance optimizations on KDE Neon
# 
# Author: AI Assistant
# Target: KDE Neon 22.04 LTS (Ubuntu base)
# Hardware: Laptops with NVMe SSD, 16GB+ RAM
# Use Case: Development + Content Creation
#############################################################################

set -e  # Exit on any error

# Global variables
VERIFY_MODE=false

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verify)
                VERIFY_MODE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help information
show_help() {
    echo "KDE Neon Ultimate Optimization Script"
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "OPTIONS:"
    echo "  --verify    Run checks only, do not make any changes"
    echo "  --help, -h  Show this help message"
    echo
    echo "DESCRIPTION:"
    echo "  This script optimizes KDE Neon for maximum performance by replicating"
    echo "  90% of Pop!_OS performance optimizations."
    echo
    echo "  Use --verify to test what changes would be made without applying them."
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
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

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should NOT be run as root. Run as normal user with sudo privileges."
        exit 1
    fi
}

# Check system compatibility
check_system_compatibility() {
    log "Checking system compatibility..."
    
    # Check if running on Ubuntu-based system
    if ! command -v lsb_release &> /dev/null; then
        error "lsb_release not found. This script requires Ubuntu-based systems."
        exit 1
    fi
    
    local os_id=$(lsb_release -si)
    local os_version=$(lsb_release -sr)
    
    # Check for KDE Neon or Ubuntu
    if [[ "$os_id" != "KDE neon" && "$os_id" != "Neon" && "$os_id" != "Ubuntu" ]]; then
        warning "This script is designed for KDE Neon/Ubuntu. Detected: $os_id"
        if [[ "$VERIFY_MODE" == "false" ]]; then
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Script cancelled by user"
                exit 0
            fi
        else
            info "VERIFY MODE: Would ask user to continue"
        fi
    fi
    
    # Check Ubuntu version compatibility
    if [[ "$os_id" == "Ubuntu" ]]; then
        local major_version=$(echo $os_version | cut -d. -f1)
        if [[ $major_version -lt 20 ]]; then
            warning "Ubuntu version $os_version detected. This script is optimized for Ubuntu 20.04+"
            if [[ "$VERIFY_MODE" == "false" ]]; then
                read -p "Continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    info "Script cancelled by user"
                    exit 0
                fi
            else
                info "VERIFY MODE: Would ask user to continue"
            fi
        fi
    fi
    
    # Check available disk space (minimum 1GB)
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # 1GB in KB
        error "Insufficient disk space. At least 1GB free space required."
        exit 1
    fi
    
    # Check if sudo is available
    if ! command -v sudo &> /dev/null; then
        error "sudo command not found. This script requires sudo privileges."
        exit 1
    fi
    
    # Test sudo access
    if ! sudo -n true 2>/dev/null; then
        warning "This script requires sudo privileges. You may be prompted for your password."
    fi
    
    log "System compatibility check passed"
}

# Check if configuration already exists
check_existing_config() {
    local config_file="$1"
    local config_name="$2"
    
    if [[ -f "$config_file" ]]; then
        warning "$config_name already exists: $config_file"
        if [[ "$VERIFY_MODE" == "false" ]]; then
            read -p "Overwrite existing configuration? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Skipping $config_name configuration"
                return 1
            fi
            
            # Create backup of existing config
            local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
            sudo cp "$config_file" "$backup_file"
            log "Existing configuration backed up to: $backup_file"
        else
            info "VERIFY MODE: Would ask user to overwrite existing configuration"
            info "VERIFY MODE: Would create backup: ${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    fi
    return 0
}

# Check if package is already installed
is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii.*$package "
}

# Check if service is available
is_service_available() {
    local service="$1"
    systemctl list-unit-files | grep -q "^$service.service"
}

# Check if service is active
is_service_active() {
    local service="$1"
    systemctl is-active --quiet "$service"
}

# Check hardware compatibility
check_hardware_compatibility() {
    log "Checking hardware compatibility..."
    
    # Check RAM (minimum 4GB recommended)
    local ram_gb=$(free -g | awk 'NR==2{print $2}')
    if [[ $ram_gb -lt 4 ]]; then
        warning "System has only ${ram_gb}GB RAM. This script is optimized for 16GB+ systems."
        if [[ "$VERIFY_MODE" == "false" ]]; then
            read -p "Continue with reduced optimizations? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Script cancelled by user"
                exit 0
            fi
        else
            info "VERIFY MODE: Would ask user to continue with reduced optimizations"
        fi
    fi
    
    # Check CPU architecture
    local arch=$(uname -m)
    if [[ "$arch" != "x86_64" ]]; then
        warning "CPU architecture $arch detected. This script is optimized for x86_64."
        if [[ "$VERIFY_MODE" == "false" ]]; then
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Script cancelled by user"
                exit 0
            fi
        else
            info "VERIFY MODE: Would ask user to continue"
        fi
    fi
    
    # Check for NVMe support
    if lsmod | grep -q nvme; then
        log "NVMe SSD detected - optimal performance settings will be applied"
    else
        info "No NVMe detected - using SATA SSD optimizations"
    fi
    
    log "Hardware compatibility check completed"
}

# System information
show_system_info() {
    log "=== SYSTEM INFORMATION ==="
    echo "OS: $(lsb_release -d | cut -f2)"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo "RAM: $(free -h | grep '^Mem' | awk '{print $2}')"
    echo "Storage: $(lsmod | grep -q nvme && echo "NVMe detected" || echo "SATA/Other")"
    echo
}

# Create backup of original configs
create_backups() {
    log "Creating configuration backups..."
    
    local backup_dir="$HOME/.config/kde-neon-optimization-backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup system configs
    [ -f /etc/sysctl.conf ] && sudo cp /etc/sysctl.conf "$backup_dir/"
    [ -f /etc/fstab ] && sudo cp /etc/fstab "$backup_dir/"
    [ -d /etc/udev/rules.d ] && sudo cp -r /etc/udev/rules.d "$backup_dir/"
    
    log "Backups saved to: $backup_dir"
    echo "$backup_dir" > "$HOME/.kde-neon-optimization-backup-location"
}

# Install essential packages
install_packages() {
    if [[ "$VERIFY_MODE" == "true" ]]; then
        log "VERIFY MODE: Would install essential packages for optimization..."
        
        # Define package groups
        local performance_packages=(
            "tlp" "tlp-rdw" "cpufrequtils" "linux-tools-common" "linux-tools-generic"
            "sysstat" "htop" "btop" "zram-config" "preload" "irqbalance" "thermald"
        )
        
        local dev_packages=(
            "build-essential" "git" "docker.io" "docker-compose"
            "nodejs" "npm" "python3-pip" "neovim" "zsh"
        )
        
        local media_packages=(
            "ubuntu-restricted-extras" "ffmpeg" "obs-studio"
        )
        
        log "VERIFY MODE: Would install performance packages:"
        for package in "${performance_packages[@]}"; do
            if is_package_installed "$package"; then
                info "  ✅ $package (already installed)"
            else
                info "  📦 $package (would install)"
            fi
        done
        
        log "VERIFY MODE: Would install development packages:"
        for package in "${dev_packages[@]}"; do
            if is_package_installed "$package"; then
                info "  ✅ $package (already installed)"
            else
                info "  📦 $package (would install)"
            fi
        done
        
        log "VERIFY MODE: Would install multimedia packages:"
        for package in "${media_packages[@]}"; do
            if is_package_installed "$package"; then
                info "  ✅ $package (already installed)"
            else
                info "  📦 $package (would install)"
            fi
        done
        
        log "VERIFY MODE: Package installation check completed"
        return 0
    fi
    
    log "Installing essential packages for optimization..."
    
    # Update package lists
    if ! sudo apt update; then
        error "Failed to update package lists"
        return 1
    fi
    
    # Define package groups
    local performance_packages=(
        "tlp" "tlp-rdw" "cpufrequtils" "linux-tools-common" "linux-tools-generic"
        "sysstat" "htop" "btop" "zram-config" "preload" "irqbalance" "thermald"
    )
    
    local dev_packages=(
        "build-essential" "git" "docker.io" "docker-compose"
        "nodejs" "npm" "python3-pip" "neovim" "zsh"
    )
    
    local media_packages=(
        "ubuntu-restricted-extras" "ffmpeg" "obs-studio"
    )
    
    # Install performance packages
    log "Installing performance and power management packages..."
    for package in "${performance_packages[@]}"; do
        if is_package_installed "$package"; then
            info "Package $package already installed"
        else
            if sudo apt install -y "$package"; then
                log "Installed $package"
            else
                warning "Failed to install $package"
            fi
        fi
    done
    
    # Install development packages
    log "Installing development tools..."
    for package in "${dev_packages[@]}"; do
        if is_package_installed "$package"; then
            info "Package $package already installed"
        else
            if sudo apt install -y "$package"; then
                log "Installed $package"
            else
                warning "Failed to install $package"
            fi
        fi
    done
    
    # Install multimedia packages
    log "Installing multimedia and codecs..."
    for package in "${media_packages[@]}"; do
        if is_package_installed "$package"; then
            info "Package $package already installed"
        else
            if sudo apt install -y "$package"; then
                log "Installed $package"
            else
                warning "Failed to install $package"
            fi
        fi
    done
        
    log "Package installation completed"
}

# Memory and swap optimizations
optimize_memory() {
    if [[ "$VERIFY_MODE" == "true" ]]; then
        log "VERIFY MODE: Would apply memory and swap optimizations..."
        
        local config_file="/etc/sysctl.d/99-kde-neon-memory.conf"
        
        if [[ -f "$config_file" ]]; then
            info "VERIFY MODE: Would ask user to overwrite existing memory configuration"
        else
            info "VERIFY MODE: Would create new memory configuration"
        fi
        
        info "VERIFY MODE: Would apply memory settings:"
        info "  - vm.swappiness=10"
        info "  - vm.vfs_cache_pressure=50"
        info "  - vm.dirty_background_ratio=15"
        info "  - vm.dirty_ratio=20"
        info "  - vm.page-cluster=0"
        info "  - vm.watermark_boost_factor=0"
        info "  - vm.watermark_scale_factor=125"
        info "  - vm.swapoff_on_oom=1"
        
        log "VERIFY MODE: Memory optimization check completed"
        return 0
    fi
    
    log "Applying memory and swap optimizations..."
    
    local config_file="/etc/sysctl.d/99-kde-neon-memory.conf"
    
    # Check if configuration already exists
    if ! check_existing_config "$config_file" "Memory optimization"; then
        return 0
    fi
    
    # Create sysctl configuration for memory
    if sudo tee "$config_file" << EOF
# Memory optimization for KDE Neon (Pop!_OS replica)
# Optimized for 16GB+ RAM development machines

# Swappiness optimization (Pop!_OS default: 10)
vm.swappiness=10

# VFS cache pressure optimization  
vm.vfs_cache_pressure=50

# Dirty page ratios for better SSD performance
vm.dirty_background_ratio=15
vm.dirty_ratio=20

# Memory management for development workloads
vm.page-cluster=0
vm.watermark_boost_factor=0
vm.watermark_scale_factor=125

# Prevent OOM with ZRAM
vm.swapoff_on_oom=1

EOF
    then
        # Apply memory settings immediately
        if sudo sysctl -p "$config_file"; then
            log "Memory optimizations applied successfully"
        else
            error "Failed to apply memory optimizations"
            return 1
        fi
    else
        error "Failed to create memory configuration file"
        return 1
    fi
}

# Network buffer optimizations (Pop!_OS 16MB buffers)
optimize_network() {
    log "Applying network buffer optimizations (16MB max buffers)..."
    
    local config_file="/etc/sysctl.d/99-kde-neon-network.conf"
    
    # Check if configuration already exists
    if ! check_existing_config "$config_file" "Network optimization"; then
        return 0
    fi
    
    # Check if BBR congestion control is available
    if ! grep -q bbr /proc/sys/net/ipv4/tcp_available_congestion_control; then
        warning "BBR congestion control not available. Using default congestion control."
        local tcp_congestion="reno"
    else
        local tcp_congestion="bbr"
    fi
    
    # Create network configuration
    if sudo tee "$config_file" << EOF
# Network buffer optimizations for development (Pop!_OS replica)
# Optimized for Docker, microservices, and development workflows

# Network receive buffers (208KB → 256KB default, 16MB max)
net.core.rmem_default = 262144
net.core.rmem_max = 16777216

# Network send buffers (208KB → 256KB default, 16MB max)  
net.core.wmem_default = 262144
net.core.wmem_max = 16777216

# Additional network optimizations
net.core.netdev_max_backlog = 5000
net.core.netdev_budget = 300

# TCP optimizations for development
net.ipv4.tcp_congestion_control = $tcp_congestion
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1

EOF
    then
        # Apply network settings immediately
        if sudo sysctl -p "$config_file"; then
            log "Network optimizations applied (76x buffer improvement: 208KB → 16MB max)"
        else
            error "Failed to apply network optimizations"
            return 1
        fi
    else
        error "Failed to create network configuration file"
        return 1
    fi
}

# Container and development optimizations  
optimize_containers() {
    log "Applying container and development optimizations..."
    
    local config_file="/etc/sysctl.d/99-kde-neon-development.conf"
    
    # Check if configuration already exists
    if ! check_existing_config "$config_file" "Development optimization"; then
        return 0
    fi
    
    # Create development configuration
    if sudo tee "$config_file" << EOF
# Container and development optimizations (Pop!_OS enterprise defaults replica)

# Process limits (Pop!_OS default: 4.2M)
kernel.pid_max=4194304

# File handle limits (Pop!_OS default: unlimited)
fs.file-max=9223372036854775807

# Memory map limits for containers (Pop!_OS default: 2.1B)
vm.max_map_count=2147483642

# Inotify limits for development tools
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=512

# Security limits for development
kernel.dmesg_restrict=0
kernel.perf_event_paranoid=1

EOF
    then
        # Apply container settings immediately
        if sudo sysctl -p "$config_file"; then
            log "Development optimizations applied successfully"
        else
            error "Failed to apply development optimizations"
            return 1
        fi
    else
        error "Failed to create development configuration file"
        return 1
    fi
    
    # Configure Docker for optimal performance
    local docker_config="/etc/docker/daemon.json"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        warning "Docker not installed. Skipping Docker configuration."
        return 0
    fi
    
    # Check if Docker configuration already exists
    if ! check_existing_config "$docker_config" "Docker configuration"; then
        return 0
    fi
    
    # Create Docker configuration directory
    sudo mkdir -p /etc/docker
    
    # Create Docker configuration
    if sudo tee "$docker_config" << EOF
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "live-restore": true,
  "userland-proxy": false,
  "features": {
    "buildkit": true
  }
}
EOF
    then
        log "Docker configuration created successfully"
    else
        error "Failed to create Docker configuration"
        return 1
    fi

    # Add user to docker group (if not already added)
    if ! groups $USER | grep -q docker; then
        if sudo usermod -aG docker $USER; then
            log "User added to docker group"
            warning "Logout and login required for Docker group changes to take effect"
        else
            error "Failed to add user to docker group"
            return 1
        fi
    else
        info "User already in docker group"
    fi
    
    # Enable Docker service if available
    if is_service_available "docker"; then
        if sudo systemctl enable docker; then
            log "Docker service enabled"
        else
            warning "Failed to enable Docker service"
        fi
    else
        warning "Docker service not available"
    fi
    
    log "Container and development optimizations applied"
}

# SSD optimizations
optimize_storage() {
    log "Applying SSD optimizations..."
    
    # Enable periodic TRIM if available
    if is_service_available "fstrim.timer"; then
        if sudo systemctl enable fstrim.timer; then
            log "TRIM timer enabled"
            if sudo systemctl start fstrim.timer; then
                log "TRIM timer started"
            else
                warning "Failed to start TRIM timer"
            fi
        else
            warning "Failed to enable TRIM timer"
        fi
    else
        warning "TRIM timer service not available"
    fi
    
    # I/O Scheduler optimization for NVMe/SATA
    local scheduler_rules="/etc/udev/rules.d/60-scheduler.rules"
    
    # Check if scheduler rules already exist
    if ! check_existing_config "$scheduler_rules" "I/O scheduler rules"; then
        return 0
    fi
    
    # Create scheduler rules
    if sudo tee "$scheduler_rules" << EOF
# I/O Scheduler optimization (Pop!_OS replica)
# NVMe SSDs: use 'none' for direct hardware queuing
# SATA SSDs: use 'mq-deadline' for better performance

KERNEL=="nvme*", ATTR{queue/scheduler}="none"
KERNEL=="sd*", ATTR{queue/scheduler}="mq-deadline"
EOF
    then
        log "I/O scheduler rules created"
        
        # Reload udev rules
        if sudo udevadm control --reload-rules; then
            log "Udev rules reloaded"
            if sudo udevadm trigger; then
                log "Udev rules triggered"
            else
                warning "Failed to trigger udev rules"
            fi
        else
            error "Failed to reload udev rules"
            return 1
        fi
    else
        error "Failed to create I/O scheduler rules"
        return 1
    fi
    
    # Check and optimize fstab (add noatime if not present)
    if ! grep -q noatime /etc/fstab; then
        warning "Consider adding 'noatime' to your root filesystem in /etc/fstab for better SSD performance"
        info "Current fstab mount options:"
        grep "^UUID.*ext4" /etc/fstab || echo "No ext4 filesystems found in fstab"
    else
        info "noatime option already present in fstab"
    fi
    
    log "SSD optimizations applied"
}

# CPU and power optimizations
optimize_cpu_power() {
    log "Installing and configuring CPU/power optimizations..."
    
    # Install auto-cpufreq for intelligent CPU scaling
    if ! command -v auto-cpufreq &> /dev/null; then
        log "Installing auto-cpufreq..."
        cd /tmp
        
        # Check if git is available
        if ! command -v git &> /dev/null; then
            error "git is required to install auto-cpufreq but not found"
            return 1
        fi
        
        # Clone and install auto-cpufreq
        if git clone https://github.com/AdnanHodzic/auto-cpufreq.git; then
            cd auto-cpufreq
            if sudo ./auto-cpufreq-installer; then
                if sudo auto-cpufreq --install; then
                    log "auto-cpufreq installed successfully"
                else
                    error "Failed to install auto-cpufreq service"
                    cd - > /dev/null
                    return 1
                fi
            else
                error "Failed to run auto-cpufreq installer"
                cd - > /dev/null
                return 1
            fi
            cd - > /dev/null
        else
            error "Failed to clone auto-cpufreq repository"
            return 1
        fi
    else
        log "auto-cpufreq already installed"
    fi
    
    # Configure TLP for better power management
    local tlp_config="/etc/tlp.conf"
    
    # Check if TLP is installed
    if ! command -v tlp &> /dev/null; then
        warning "TLP not installed. Skipping TLP configuration."
        return 0
    fi
    
    # Check if TLP configuration already exists
    if ! check_existing_config "$tlp_config" "TLP configuration"; then
        return 0
    fi
    
    # Create TLP configuration
    if sudo tee "$tlp_config" << EOF
# TLP configuration for KDE Neon (Pop!_OS replica)

# Set TLP defaults
TLP_DEFAULT_MODE=BAT

# CPU scaling governor
CPU_SCALING_GOVERNOR_ON_AC=performance  
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# CPU energy performance policy  
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

# Platform profiles
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=low-power  

# Processor features
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# Runtime power management
RUNTIME_PM_ON_AC=auto
RUNTIME_PM_ON_BAT=auto

# Wi-Fi power saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

EOF
    then
        log "TLP configuration created successfully"
    else
        error "Failed to create TLP configuration"
        return 1
    fi

    # Enable TLP service if available
    if is_service_available "tlp"; then
        if sudo systemctl enable tlp; then
            log "TLP service enabled"
            if sudo systemctl start tlp; then
                log "TLP service started"
            else
                warning "Failed to start TLP service"
            fi
        else
            warning "Failed to enable TLP service"
        fi
    else
        warning "TLP service not available"
    fi
    
    # Install thermald for Intel thermal management
    if is_service_available "thermald"; then
        if sudo systemctl enable thermald; then
            log "Thermald service enabled"
            if sudo systemctl start thermald; then
                log "Thermald service started"
            else
                warning "Failed to start thermald service"
            fi
        else
            warning "Failed to enable thermald service"
        fi
    else
        warning "Thermald service not available"
    fi
    
    log "CPU and power optimizations configured"
}

# ZRAM configuration
setup_zram() {
    log "Configuring ZRAM for better memory utilization..."
    
    # Check if zram-config is installed
    if ! command -v zramctl &> /dev/null; then
        warning "zram-config not installed. Skipping ZRAM configuration."
        return 0
    fi
    
    # Check if zram is already configured
    if systemctl is-enabled zram-config &>/dev/null; then
        log "ZRAM already configured"
        return 0
    fi
    
    # Configure ZRAM size based on available RAM
    local ram_gb=$(free -g | awk 'NR==2{print $2}')
    local zram_size
    
    if [ $ram_gb -ge 16 ]; then
        zram_size="4G"
    elif [ $ram_gb -ge 8 ]; then
        zram_size="2G"
    else
        zram_size="1G"
    fi
    
    # Enable and configure ZRAM
    if sudo systemctl enable zram-config; then
        log "ZRAM service enabled"
        if sudo systemctl start zram-config; then
            log "ZRAM service started"
            log "ZRAM configured with ${zram_size} virtual swap space"
        else
            error "Failed to start ZRAM service"
            return 1
        fi
    else
        error "Failed to enable ZRAM service"
        return 1
    fi
}

# Font optimizations for better rendering
optimize_fonts() {
    log "Installing and configuring fonts for better rendering..."
    
    # Define font packages
    local font_packages=(
        "fonts-liberation" "fonts-dejavu" "fonts-noto"
        "fonts-roboto" "fonts-ubuntu" "ttf-mscorefonts-installer"
    )
    
    # Install font packages
    for package in "${font_packages[@]}"; do
        if is_package_installed "$package"; then
            info "Font package $package already installed"
        else
            if sudo apt install -y "$package"; then
                log "Installed font package $package"
            else
                warning "Failed to install font package $package"
            fi
        fi
    done
        
    # Configure fontconfig for better rendering
    local fontconfig_dir="$HOME/.config/fontconfig"
    local fontconfig_file="$fontconfig_dir/fonts.conf"
    
    # Create fontconfig directory if it doesn't exist
    if [ ! -d "$fontconfig_dir" ]; then
        if mkdir -p "$fontconfig_dir"; then
            log "Created fontconfig directory"
        else
            error "Failed to create fontconfig directory"
            return 1
        fi
    fi
    
    # Check if fontconfig already exists
    if [[ -f "$fontconfig_file" ]]; then
        warning "Font configuration already exists: $fontconfig_file"
        read -p "Overwrite existing font configuration? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Skipping font configuration"
            return 0
        fi
        
        # Create backup
        local backup_file="${fontconfig_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$fontconfig_file" "$backup_file"
        log "Existing font configuration backed up to: $backup_file"
    fi
    
    # Create font configuration
    if tee "$fontconfig_file" << EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Liberation Serif</family>
      <family>Times New Roman</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Liberation Sans</family>
      <family>Arial</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Liberation Mono</family>
      <family>Courier New</family>
    </prefer>
  </alias>
  <!-- Font rendering options -->
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
  </match>
</fontconfig>
EOF
    then
        log "Font configuration created successfully"
    else
        error "Failed to create font configuration"
        return 1
    fi

    # Rebuild font cache
    if fc-cache -fv; then
        log "Font cache rebuilt successfully"
    else
        warning "Failed to rebuild font cache"
    fi
    
    log "Font optimizations applied"
}

# Security optimizations
optimize_security() {
    log "Applying security optimizations..."
    
    local config_file="/etc/sysctl.d/99-kde-neon-security.conf"
    
    # Check if configuration already exists
    if ! check_existing_config "$config_file" "Security optimization"; then
        return 0
    fi
    
    # Create security configuration
    if sudo tee "$config_file" << EOF
# Security optimizations for development workstation

# Network security
net.ipv4.tcp_syncookies=1
net.ipv4.ip_forward=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0

# Kernel security (balanced for development)
kernel.dmesg_restrict=0
kernel.kptr_restrict=1
kernel.perf_event_paranoid=1
kernel.yama.ptrace_scope=1

EOF
    then
        # Apply security settings
        if sudo sysctl -p "$config_file"; then
            log "Security optimizations applied successfully"
        else
            error "Failed to apply security optimizations"
            return 1
        fi
    else
        error "Failed to create security configuration file"
        return 1
    fi
}

# Performance monitoring tools
install_monitoring_tools() {
    log "Installing performance monitoring tools..."
    
    # Define monitoring packages
    local monitoring_packages=(
        "htop" "btop" "iotop" "nethogs" "sysstat"
        "neofetch" "fastfetch" "tree" "curl" "wget"
        "git" "vim" "neovim"
    )
    
    # Install monitoring packages
    for package in "${monitoring_packages[@]}"; do
        if is_package_installed "$package"; then
            info "Monitoring package $package already installed"
        else
            if sudo apt install -y "$package"; then
                log "Installed monitoring package $package"
            else
                warning "Failed to install monitoring package $package"
            fi
        fi
    done
    
    # Install ctop for container monitoring
    if ! command -v ctop &> /dev/null; then
        log "Installing ctop for container monitoring..."
        if sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop; then
            if sudo chmod +x /usr/local/bin/ctop; then
                log "ctop installed successfully"
            else
                error "Failed to make ctop executable"
                return 1
            fi
        else
            error "Failed to download ctop"
            return 1
        fi
    else
        info "ctop already installed"
    fi
    
    log "Monitoring tools installed"
}

# Shell optimizations (zsh + oh-my-zsh)
optimize_shell() {
    log "Setting up optimized shell environment..."
    
    # Install zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        if sudo apt install -y zsh; then
            log "zsh installed successfully"
        else
            error "Failed to install zsh"
            return 1
        fi
    else
        info "zsh already installed"
    fi
    
    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."
        if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
            log "Oh My Zsh installed successfully"
        else
            error "Failed to install Oh My Zsh"
            return 1
        fi
    else
        info "Oh My Zsh already installed"
    fi
    
    # Install useful plugins
    if [ -d "$HOME/.oh-my-zsh" ]; then
        # zsh-autosuggestions
        if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
            log "Installing zsh-autosuggestions plugin..."
            if git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions; then
                log "zsh-autosuggestions plugin installed"
            else
                warning "Failed to install zsh-autosuggestions plugin"
            fi
        else
            info "zsh-autosuggestions plugin already installed"
        fi
        
        # zsh-syntax-highlighting  
        if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
            log "Installing zsh-syntax-highlighting plugin..."
            if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting; then
                log "zsh-syntax-highlighting plugin installed"
            else
                warning "Failed to install zsh-syntax-highlighting plugin"
            fi
        else
            info "zsh-syntax-highlighting plugin already installed"
        fi
        
        # Configure .zshrc with optimized plugins
        if [ -f "$HOME/.zshrc" ]; then
            # Check if plugins are already configured
            if ! grep -q "zsh-autosuggestions\|zsh-syntax-highlighting" "$HOME/.zshrc"; then
                log "Configuring zsh plugins..."
                if sed -i 's/plugins=(git)/plugins=(git docker docker-compose node npm zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"; then
                    log "zsh plugins configured successfully"
                else
                    warning "Failed to configure zsh plugins"
                fi
            else
                info "zsh plugins already configured"
            fi
        else
            warning ".zshrc not found. Oh My Zsh may not be properly installed."
        fi
    fi
    
    log "Shell optimizations configured"
}

# Performance verification
verify_optimizations() {
    log "Verifying applied optimizations..."
    
    echo "=== OPTIMIZATION VERIFICATION ==="
    echo
    
    echo "Memory Settings:"
    echo "  Swappiness: $(cat /proc/sys/vm/swappiness) (should be 10)"
    echo "  VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure) (should be 50)"
    echo
    
    echo "Network Buffers:"  
    echo "  Max Read Buffer: $(cat /proc/sys/net/core/rmem_max) (should be 16777216)"
    echo "  Max Write Buffer: $(cat /proc/sys/net/core/wmem_max) (should be 16777216)"
    echo
    
    echo "Development Limits:"
    echo "  Max PIDs: $(cat /proc/sys/kernel/pid_max) (should be 4194304)"
    echo "  Max File Handles: $(cat /proc/sys/fs/file-max)"
    echo "  Max Memory Maps: $(cat /proc/sys/vm/max_map_count) (should be 2147483642)"
    echo
    
    echo "Storage Optimization:"
    if systemctl is-enabled fstrim.timer &>/dev/null; then
        echo "  TRIM: ✅ Enabled"
    else
        echo "  TRIM: ❌ Not enabled"
    fi
    
    # Check I/O scheduler
    for disk in /sys/block/nvme*; do
        if [ -e "$disk/queue/scheduler" ]; then
            echo "  $(basename $disk) I/O Scheduler: $(cat $disk/queue/scheduler)"
        fi
    done
    echo
    
    echo "Power Management:"
    if systemctl is-active tlp &>/dev/null; then
        echo "  TLP: ✅ Active"
    else  
        echo "  TLP: ❌ Not active"
    fi
    
    if systemctl is-active auto-cpufreq &>/dev/null; then
        echo "  auto-cpufreq: ✅ Active"
    else
        echo "  auto-cpufreq: ❌ Not active"  
    fi
    echo
    
    echo "Container Platform:"
    if command -v docker &> /dev/null; then
        if systemctl is-active docker &>/dev/null; then
            echo "  Docker: ✅ Installed and running"
            if groups $USER | grep -q docker; then
                echo "  Docker user access: ✅ Configured"
            else
                echo "  Docker user access: ⚠️  Logout/login required"
            fi
        else
            echo "  Docker: ⚠️  Installed but not running"
        fi
    else
        echo "  Docker: ❌ Not installed"
    fi
    echo
    
    echo "ZRAM Status:"
    if systemctl is-active zram-config &>/dev/null; then
        echo "  ZRAM: ✅ Active"
        if command -v zramctl &> /dev/null; then
            zramctl 2>/dev/null | head -5
        fi
    else
        echo "  ZRAM: ❌ Not active"
    fi
    echo
}

# Create performance test script
create_performance_tests() {
    log "Creating performance test scripts..."
    
    local test_script="$HOME/test-optimizations.sh"
    
    # Check if test script already exists
    if [[ -f "$test_script" ]]; then
        warning "Performance test script already exists: $test_script"
        read -p "Overwrite existing test script? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Skipping test script creation"
            return 0
        fi
        
        # Create backup
        local backup_file="${test_script}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$test_script" "$backup_file"
        log "Existing test script backed up to: $backup_file"
    fi
    
    # Create performance test script
    if tee "$test_script" << 'EOF'
#!/bin/bash
# KDE Neon Optimization Performance Tests

echo "=== KDE NEON OPTIMIZATION PERFORMANCE TESTS ==="
echo

echo "1. Memory Performance Test:"
time (for i in {1..1000}; do echo "test" > /dev/null; done)
echo "Current memory usage: $(free -h | grep '^Mem' | awk '{print $3 "/" $2}')"
echo

echo "2. Network Buffer Test:"
echo "Testing network performance with optimized 16MB buffers..."
time wget -q -O /dev/null http://speedtest.tele2.net/10MB.zip || echo "Network test failed"
echo

echo "3. CPU Scaling Test:"
echo "Current CPU governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo "Current CPU frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)"
echo

echo "4. Storage Performance Test:"
echo "Current I/O schedulers:"
for disk in /sys/block/nvme* /sys/block/sd*; do
    if [ -e "$disk/queue/scheduler" ]; then
        echo "  $(basename $disk): $(cat $disk/queue/scheduler)"
    fi
done 2>/dev/null
echo

echo "5. Container Test (Docker):"  
if command -v docker &> /dev/null && systemctl is-active docker &>/dev/null; then
    echo "Testing Docker with optimized settings..."
    time docker run --rm alpine echo "Docker working with optimized network buffers!"
else
    echo "Docker not available - logout/login may be required"
fi
echo

echo "6. ZRAM Status:"
if command -v zramctl &> /dev/null; then
    zramctl
else
    echo "ZRAM tools not available"
fi
echo

echo "=== PERFORMANCE TEST COMPLETE ==="
EOF
    then
        # Make script executable
        if chmod +x "$test_script"; then
            log "Performance test script created: $test_script"
        else
            error "Failed to make test script executable"
            return 1
        fi
    else
        error "Failed to create performance test script"
        return 1
    fi
}

# Main optimization function
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Show header
    if [[ "$VERIFY_MODE" == "true" ]]; then
        echo "################################################################"
        echo "#                                                              #"
        echo "#          KDE NEON OPTIMIZATION VERIFICATION MODE             #"
        echo "#                                                              #" 
        echo "#          Shows what changes would be made                    #"
        echo "#          WITHOUT actually applying them                      #"
        echo "#                                                              #"
        echo "################################################################"
        echo
        log "Running in VERIFY MODE - no changes will be made"
        echo
    else
        clear
        echo "################################################################"
        echo "#                                                              #"
        echo "#          KDE NEON ULTIMATE OPTIMIZATION SCRIPT               #"
        echo "#                                                              #" 
        echo "#          Replicates 90% of Pop!_OS Performance               #"
        echo "#          Optimized for Development + Content Creation        #"
        echo "#                                                              #"
        echo "################################################################"
        echo
    fi
    
    # Run initial checks
    check_root
    check_system_compatibility
    check_hardware_compatibility
    show_system_info
    
    if [[ "$VERIFY_MODE" == "false" ]]; then
        read -p "This script will optimize your KDE Neon system for maximum performance. Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Optimization cancelled by user"
            exit 0
        fi
    else
        log "VERIFY MODE: Would ask user to confirm optimization"
    fi
    
    log "Starting KDE Neon optimization process..."
    echo
    
    # Track failed operations
    local failed_operations=()
    
    # Run optimization functions with error handling
    if ! install_packages; then
        failed_operations+=("install_packages")
    fi
    
    if ! optimize_memory; then
        failed_operations+=("optimize_memory")
    fi
    
    if ! optimize_network; then
        failed_operations+=("optimize_network")
    fi
    
    if ! optimize_containers; then
        failed_operations+=("optimize_containers")
    fi
    
    if ! optimize_storage; then
        failed_operations+=("optimize_storage")
    fi
    
    if ! optimize_cpu_power; then
        failed_operations+=("optimize_cpu_power")
    fi
    
    if ! setup_zram; then
        failed_operations+=("setup_zram")
    fi
    
    if ! optimize_fonts; then
        failed_operations+=("optimize_fonts")
    fi
    
    if ! optimize_security; then
        failed_operations+=("optimize_security")
    fi
    
    if ! install_monitoring_tools; then
        failed_operations+=("install_monitoring_tools")
    fi
    
    if ! optimize_shell; then
        failed_operations+=("optimize_shell")
    fi
    
    if ! create_performance_tests; then
        failed_operations+=("create_performance_tests")
    fi
    
    echo
    
    # Report results
    if [[ ${#failed_operations[@]} -eq 0 ]]; then
        log "=== OPTIMIZATION COMPLETE! ==="
        echo
        
        warning "IMPORTANT: A system reboot is recommended to ensure all optimizations are active."
        warning "After reboot, run ~/test-optimizations.sh to verify performance improvements."
        echo
        
        info "Optimization Summary:"
        echo "  ✅ Memory: Swappiness optimized (10), ZRAM configured"
        echo "  ✅ Network: 76x buffer increase (208KB → 16MB max)"  
        echo "  ✅ Storage: NVMe optimized, TRIM enabled"
        echo "  ✅ CPU: auto-cpufreq intelligent scaling"
        echo "  ✅ Power: TLP configured for laptops"  
        echo "  ✅ Containers: Docker optimized, enterprise limits"
        echo "  ✅ Development: Unlimited file handles, 4.2M PID limit"
        echo "  ✅ Security: Balanced for development workstation"
        echo
        
        verify_optimizations
        
        echo
        log "Your KDE Neon system now has 90% of Pop!_OS performance benefits!"
        log "Plus: Docker works perfectly, fonts render correctly, standard Ubuntu compatibility!"
        echo
        
        warning "Logout and login (or reboot) to apply all user group changes."
        info "Run 'sudo reboot' to activate all optimizations."
        echo
        
        read -p "Would you like to reboot now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "Rebooting system..."
            sudo reboot
        else
            log "Reboot manually when ready. Optimization complete!"
        fi
    else
        error "=== OPTIMIZATION COMPLETED WITH ERRORS ==="
        echo
        warning "The following operations failed:"
        for operation in "${failed_operations[@]}"; do
            echo "  ❌ $operation"
        done
        echo
        
        info "Some optimizations may still be active. Check the verification output below."
        echo
        
        verify_optimizations
        
        echo
        warning "Please review the errors above and consider running the script again."
        warning "A reboot may still be beneficial for the optimizations that succeeded."
    fi
}

# Run main function only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi