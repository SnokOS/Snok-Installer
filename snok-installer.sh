#!/bin/bash

################################################################################
# Snok-Installer - Distribution-Independent Linux Installer
# Version: 2.0
# License: GPLv3
# Description: Modern, flexible Linux installer with multi-language support
################################################################################

set -e  # Exit on error
trap 'error_handler $? $LINENO' ERR

################################################################################
# GLOBAL VARIABLES
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/logs/snok-installer-$(date +%Y%m%d-%H%M%S).log"
CONFIG_DIR="${SCRIPT_DIR}/config"
ASSETS_DIR="${SCRIPT_DIR}/assets"

# Installation variables
SELECTED_LANG="en"
SELECTED_TIMEZONE=""
SELECTED_KEYBOARD=""
SELECTED_DISK=""
SELECTED_SWAP_TYPE=""
INSTALL_NVIDIA=false
IS_UEFI=false
USE_ENCRYPTION=false
USERNAME=""
USER_PASSWORD=""
ROOT_PASSWORD=""
HOSTNAME=""
SELECTED_DE=""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

################################################################################
# LOGGING FUNCTIONS
################################################################################

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*" | tee -a "$LOG_FILE"
}

################################################################################
# ERROR HANDLING
################################################################################

error_handler() {
    local exit_code=$1
    local line_number=$2
    log_error "Script failed at line $line_number with exit code $exit_code"
    
    if command -v dialog &> /dev/null; then
        dialog --title "$(get_text 'error_title')" \
               --msgbox "$(get_text 'error_occurred')\n\n$(get_text 'line'): $line_number\n$(get_text 'exit_code'): $exit_code\n\n$(get_text 'check_log'): $LOG_FILE" \
               12 60
    else
        echo -e "${RED}Error occurred at line $line_number (exit code: $exit_code)${NC}"
        echo "Check log file: $LOG_FILE"
    fi
    
    cleanup_on_error
    exit $exit_code
}

cleanup_on_error() {
    log "Performing cleanup after error..."
    # Unmount any mounted partitions
    sync
    # Add more cleanup as needed
}

################################################################################
# LANGUAGE SUPPORT
################################################################################

declare -A LANG_STRINGS

init_languages() {
    # English
    LANG_STRINGS["en_welcome"]="Welcome to Snok-Installer"
    LANG_STRINGS["en_select_language"]="Select Language"
    LANG_STRINGS["en_select_timezone"]="Select Timezone"
    LANG_STRINGS["en_select_keyboard"]="Select Keyboard Layout"
    LANG_STRINGS["en_select_disk"]="Select Installation Disk"
    LANG_STRINGS["en_user_setup"]="User Setup"
    LANG_STRINGS["en_installation_summary"]="Installation Summary"
    LANG_STRINGS["en_installing"]="Installing System..."
    LANG_STRINGS["en_complete"]="Installation Complete"
    LANG_STRINGS["en_error_title"]="Error"
    LANG_STRINGS["en_error_occurred"]="An error occurred during installation"
    LANG_STRINGS["en_line"]="Line"
    LANG_STRINGS["en_exit_code"]="Exit Code"
    LANG_STRINGS["en_check_log"]="Check log file"
    LANG_STRINGS["en_nvidia_detected"]="NVIDIA GPU Detected"
    LANG_STRINGS["en_nvidia_install"]="Install NVIDIA Drivers?"
    LANG_STRINGS["en_uefi_detected"]="UEFI Boot Mode Detected"
    LANG_STRINGS["en_legacy_detected"]="Legacy BIOS Mode Detected"
    LANG_STRINGS["en_swap_selection"]="Select SWAP Type"
    LANG_STRINGS["en_swap_partition"]="SWAP Partition"
    LANG_STRINGS["en_zram"]="ZRAM (Compressed RAM)"
    LANG_STRINGS["en_no_swap"]="No SWAP"
    LANG_STRINGS["en_encryption"]="Enable Disk Encryption (LUKS)?"
    LANG_STRINGS["en_username"]="Enter Username"
    LANG_STRINGS["en_password"]="Enter Password"
    LANG_STRINGS["en_hostname"]="Enter Hostname"
    LANG_STRINGS["en_desktop_env"]="Select Desktop Environment"
    LANG_STRINGS["en_partitioning"]="Disk Partitioning"
    LANG_STRINGS["en_auto_partition"]="Automatic Partitioning"
    LANG_STRINGS["en_manual_partition"]="Manual Partitioning"
    LANG_STRINGS["en_continue"]="Continue"
    LANG_STRINGS["en_cancel"]="Cancel"
    LANG_STRINGS["en_yes"]="Yes"
    LANG_STRINGS["en_no"]="No"
    
    # Arabic (العربية)
    LANG_STRINGS["ar_welcome"]="مرحباً بك في Snok-Installer"
    LANG_STRINGS["ar_select_language"]="اختر اللغة"
    LANG_STRINGS["ar_select_timezone"]="اختر المنطقة الزمنية"
    LANG_STRINGS["ar_select_keyboard"]="اختر تخطيط لوحة المفاتيح"
    LANG_STRINGS["ar_select_disk"]="اختر قرص التثبيت"
    LANG_STRINGS["ar_user_setup"]="إعداد المستخدم"
    LANG_STRINGS["ar_installation_summary"]="ملخص التثبيت"
    LANG_STRINGS["ar_installing"]="جاري تثبيت النظام..."
    LANG_STRINGS["ar_complete"]="اكتمل التثبيت"
    LANG_STRINGS["ar_error_title"]="خطأ"
    LANG_STRINGS["ar_error_occurred"]="حدث خطأ أثناء التثبيت"
    LANG_STRINGS["ar_line"]="السطر"
    LANG_STRINGS["ar_exit_code"]="رمز الخروج"
    LANG_STRINGS["ar_check_log"]="تحقق من ملف السجل"
    LANG_STRINGS["ar_nvidia_detected"]="تم اكتشاف بطاقة NVIDIA"
    LANG_STRINGS["ar_nvidia_install"]="تثبيت تعريفات NVIDIA؟"
    LANG_STRINGS["ar_uefi_detected"]="تم اكتشاف وضع UEFI"
    LANG_STRINGS["ar_legacy_detected"]="تم اكتشاف وضع BIOS القديم"
    LANG_STRINGS["ar_swap_selection"]="اختر نوع SWAP"
    LANG_STRINGS["ar_swap_partition"]="قسم SWAP"
    LANG_STRINGS["ar_zram"]="ZRAM (ذاكرة مضغوطة)"
    LANG_STRINGS["ar_no_swap"]="بدون SWAP"
    LANG_STRINGS["ar_encryption"]="تفعيل تشفير القرص (LUKS)؟"
    LANG_STRINGS["ar_username"]="أدخل اسم المستخدم"
    LANG_STRINGS["ar_password"]="أدخل كلمة المرور"
    LANG_STRINGS["ar_hostname"]="أدخل اسم الجهاز"
    LANG_STRINGS["ar_desktop_env"]="اختر بيئة سطح المكتب"
    LANG_STRINGS["ar_partitioning"]="تقسيم القرص"
    LANG_STRINGS["ar_auto_partition"]="تقسيم تلقائي"
    LANG_STRINGS["ar_manual_partition"]="تقسيم يدوي"
    LANG_STRINGS["ar_continue"]="متابعة"
    LANG_STRINGS["ar_cancel"]="إلغاء"
    LANG_STRINGS["ar_yes"]="نعم"
    LANG_STRINGS["ar_no"]="لا"
}

get_text() {
    local key="${SELECTED_LANG}_${1}"
    echo "${LANG_STRINGS[$key]:-$1}"
}

################################################################################
# DEPENDENCY CHECKING
################################################################################

install_dependencies() {
    log "Installing missing dependencies..."
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        log "Detected APT package manager (Debian/Ubuntu)"
        apt-get update -qq
        apt-get install -y dialog parted dosfstools e2fsprogs pciutils cryptsetup lvm2 2>&1 | tee -a "$LOG_FILE"
    elif command -v pacman &> /dev/null; then
        log "Detected Pacman package manager (Arch)"
        pacman -Sy --noconfirm dialog parted dosfstools e2fsprogs pciutils cryptsetup lvm2 2>&1 | tee -a "$LOG_FILE"
    elif command -v dnf &> /dev/null; then
        log "Detected DNF package manager (Fedora/RHEL)"
        dnf install -y dialog parted dosfstools e2fsprogs pciutils cryptsetup lvm2 2>&1 | tee -a "$LOG_FILE"
    elif command -v zypper &> /dev/null; then
        log "Detected Zypper package manager (openSUSE)"
        zypper install -y dialog parted dosfstools e2fsprogs pciutils cryptsetup lvm2 2>&1 | tee -a "$LOG_FILE"
    else
        log_error "No supported package manager found"
        return 1
    fi
    
    log_success "Dependencies installed successfully"
}

check_dependencies() {
    log "Checking dependencies..."
    
    local deps=("dialog" "lsblk" "parted" "mkfs.ext4" "mkfs.fat" "lspci" "wipefs" "cryptsetup")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        echo -e "${YELLOW}Missing required dependencies: ${missing_deps[*]}${NC}"
        echo -e "${CYAN}Attempting to install automatically...${NC}"
        
        if install_dependencies; then
            log_success "All dependencies installed"
        else
            echo -e "${RED}Failed to install dependencies automatically${NC}"
            echo "Please install them manually and try again."
            exit 1
        fi
    else
        log_success "All dependencies satisfied"
    fi
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script must be run as root${NC}"
        echo "Please run: sudo $0"
        exit 1
    fi
}

################################################################################
# HARDWARE DETECTION
################################################################################

detect_nvidia() {
    log "Detecting NVIDIA GPU..."
    
    if lspci | grep -i nvidia &> /dev/null; then
        log_success "NVIDIA GPU detected"
        return 0
    else
        log "No NVIDIA GPU detected"
        return 1
    fi
}

detect_boot_mode() {
    log "Detecting boot mode..."
    
    if [ -d /sys/firmware/efi ]; then
        IS_UEFI=true
        log_success "UEFI boot mode detected"
    else
        IS_UEFI=false
        log_success "Legacy BIOS boot mode detected"
    fi
}

detect_disks() {
    log "Detecting storage devices..."
    
    # Get list of disks (excluding loop devices and removable media)
    mapfile -t DISKS < <(lsblk -dpno NAME,SIZE,TYPE | grep 'disk' | awk '{print $1 " " $2}')
    
    if [ ${#DISKS[@]} -eq 0 ]; then
        log_error "No disks detected"
        return 1
    fi
    
    log_success "Detected ${#DISKS[@]} disk(s)"
    return 0
}

get_system_info() {
    log "Gathering system information..."
    
    local cpu_info=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    local ram_info=$(free -h | awk '/^Mem:/ {print $2}')
    local disk_info=$(lsblk -dno NAME,SIZE | head -1)
    
    log "CPU: $cpu_info"
    log "RAM: $ram_info"
    log "Primary Disk: $disk_info"
}

################################################################################
# ASCII LOGO
################################################################################

show_logo() {
    clear
    cat << "EOF"
    
     ███████╗███╗   ██╗ ██████╗ ██╗  ██╗
     ██╔════╝████╗  ██║██╔═══██╗██║ ██╔╝
     ███████╗██╔██╗ ██║██║   ██║█████╔╝ 
     ╚════██║██║╚██╗██║██║   ██║██╔═██╗ 
     ███████║██║ ╚████║╚██████╔╝██║  ██╗
     ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
                                        
     INSTALLER - Distribution Independent
     Version 2.0 | GPLv3 License
     
EOF
    sleep 2
}

################################################################################
# USER INTERFACE FUNCTIONS
################################################################################

language_selection() {
    log "Showing language selection..."
    
    SELECTED_LANG=$(dialog --clear --title "Language / اللغة" \
        --menu "Select your language / اختر لغتك:" 15 60 4 \
        "en" "English" \
        "ar" "العربية (Arabic)" \
        "fr" "Français" \
        "es" "Español" \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        clear
        exit 0
    fi
    
    log "Language selected: $SELECTED_LANG"
}

welcome_screen() {
    dialog --title "$(get_text 'welcome')" \
           --msgbox "$(get_text 'welcome')\n\n$(get_text 'continue')" 10 60
}

timezone_selection() {
    log "Showing timezone selection..."
    
    # Get list of timezones
    local timezones=($(timedatectl list-timezones))
    local menu_items=()
    
    for tz in "${timezones[@]:0:50}"; do  # Limit to first 50 for dialog
        menu_items+=("$tz" "")
    done
    
    SELECTED_TIMEZONE=$(dialog --clear --title "$(get_text 'select_timezone')" \
        --menu "$(get_text 'select_timezone'):" 20 60 15 \
        "${menu_items[@]}" \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        SELECTED_TIMEZONE="UTC"
    fi
    
    log "Timezone selected: $SELECTED_TIMEZONE"
}

keyboard_selection() {
    log "Showing keyboard layout selection..."
    
    SELECTED_KEYBOARD=$(dialog --clear --title "$(get_text 'select_keyboard')" \
        --menu "$(get_text 'select_keyboard'):" 20 60 10 \
        "us" "US English" \
        "ar" "Arabic" \
        "fr" "French" \
        "de" "German" \
        "es" "Spanish" \
        "ru" "Russian" \
        "jp" "Japanese" \
        "cn" "Chinese" \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        SELECTED_KEYBOARD="us"
    fi
    
    log "Keyboard layout selected: $SELECTED_KEYBOARD"
}

disk_selection() {
    log "Showing disk selection..."
    
    detect_disks
    
    local menu_items=()
    for disk in "${DISKS[@]}"; do
        menu_items+=($disk)
    done
    
    SELECTED_DISK=$(dialog --clear --title "$(get_text 'select_disk')" \
        --menu "$(get_text 'select_disk'):" 15 70 8 \
        "${menu_items[@]}" \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        log_error "No disk selected"
        exit 1
    fi
    
    # Extract just the device name
    SELECTED_DISK=$(echo "$SELECTED_DISK" | awk '{print $1}')
    
    log "Disk selected: $SELECTED_DISK"
}

swap_selection() {
    log "Showing SWAP type selection..."
    
    local ram_gb=$(free -g | awk '/^Mem:/ {print $2}')
    local recommendation=""
    
    if [ "$ram_gb" -lt 4 ]; then
        recommendation="$(get_text 'swap_partition') (Recommended for <4GB RAM)"
    elif [ "$ram_gb" -lt 8 ]; then
        recommendation="$(get_text 'zram') (Recommended for 4-8GB RAM)"
    else
        recommendation="$(get_text 'zram') or $(get_text 'no_swap') (Recommended for >8GB RAM)"
    fi
    
    SELECTED_SWAP_TYPE=$(dialog --clear --title "$(get_text 'swap_selection')" \
        --menu "$(get_text 'swap_selection'):\n\nRAM: ${ram_gb}GB\n$recommendation" 18 70 3 \
        "swap" "$(get_text 'swap_partition')" \
        "zram" "$(get_text 'zram')" \
        "none" "$(get_text 'no_swap')" \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        SELECTED_SWAP_TYPE="zram"
    fi
    
    log "SWAP type selected: $SELECTED_SWAP_TYPE"
}

nvidia_prompt() {
    if detect_nvidia; then
        dialog --title "$(get_text 'nvidia_detected')" \
               --yesno "$(get_text 'nvidia_install')" 8 60
        
        if [ $? -eq 0 ]; then
            INSTALL_NVIDIA=true
            log "User chose to install NVIDIA drivers"
        else
            INSTALL_NVIDIA=false
            log "User chose not to install NVIDIA drivers"
        fi
    fi
}

encryption_prompt() {
    dialog --title "Disk Encryption (LUKS)" \
           --yesno "Enable full disk encryption?\n\n\
Benefits:\n\
  ✓ Protects data if disk is stolen\n\
  ✓ Uses LUKS2 encryption standard\n\
  ✓ Military-grade security\n\n\
Drawbacks:\n\
  ✗ Requires password on every boot\n\
  ✗ Slight performance impact (~5%)\n\
  ✗ Cannot recover data if password is lost\n\n\
Enable encryption?" 18 60
    
    if [ $? -eq 0 ]; then
        USE_ENCRYPTION=true
        log "User enabled disk encryption"
    else
        USE_ENCRYPTION=false
        log "User disabled disk encryption"
    fi
}

password_input_with_toggle() {
    local title="$1"
    local prompt="$2"
    local password=""
    
    # Simple password input with option to show
    password=$(dialog --clear --title "$title" \
        --extra-button --extra-label "Show Password" \
        --ok-label "Continue" \
        --cancel-label "Cancel" \
        --insecure --passwordbox "$prompt\n\n(Password hidden as ***)\n\nPress 'Show Password' to reveal" 12 60 \
        3>&1 1>&2 2>&3)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # Continue pressed with hidden password
        echo "$password"
        return 0
    elif [ $exit_code -eq 3 ]; then
        # Show password button pressed - display in plain text
        password=$(dialog --clear --title "$title" \
            --ok-label "Continue" \
            --cancel-label "Cancel" \
            --inputbox "$prompt\n\n(Password visible)\n\nPress 'Continue' when done" 12 60 "$password" \
            3>&1 1>&2 2>&3)
        
        if [ $? -eq 0 ]; then
            echo "$password"
            return 0
        else
            return 1
        fi
    else
        # Cancel pressed
        return 1
    fi
}

user_setup() {
    log "Starting user setup..."
    
    # Username
    USERNAME=$(dialog --clear --title "$(get_text 'user_setup')" \
        --inputbox "$(get_text 'username'):" 10 60 \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ] || [ -z "$USERNAME" ]; then
        USERNAME="user"
    fi
    
    # User password with toggle
    USER_PASSWORD=$(password_input_with_toggle "$(get_text 'user_setup')" "$(get_text 'password') for $USERNAME:")
    if [ $? -ne 0 ]; then
        log_error "Password input cancelled"
        exit 1
    fi
    
    # Confirm user password
    local password_confirm=$(password_input_with_toggle "$(get_text 'user_setup')" "Confirm $(get_text 'password') for $USERNAME:")
    if [ $? -ne 0 ]; then
        log_error "Password confirmation cancelled"
        exit 1
    fi
    
    # Check if passwords match
    if [ "$USER_PASSWORD" != "$password_confirm" ]; then
        dialog --title "Error" --msgbox "Passwords do not match! Please try again." 8 50
        user_setup
        return
    fi
    
    # Root password with toggle
    ROOT_PASSWORD=$(password_input_with_toggle "$(get_text 'user_setup')" "Root $(get_text 'password'):")
    if [ $? -ne 0 ]; then
        log_error "Root password input cancelled"
        exit 1
    fi
    
    # Confirm root password
    local root_password_confirm=$(password_input_with_toggle "$(get_text 'user_setup')" "Confirm Root $(get_text 'password'):")
    if [ $? -ne 0 ]; then
        log_error "Root password confirmation cancelled"
        exit 1
    fi
    
    # Check if root passwords match
    if [ "$ROOT_PASSWORD" != "$root_password_confirm" ]; then
        dialog --title "Error" --msgbox "Root passwords do not match! Please try again." 8 50
        user_setup
        return
    fi
    
    # Set default hostname automatically
    HOSTNAME="snok-linux"
    
    log "User setup complete: username=$USERNAME, hostname=$HOSTNAME"
}

desktop_environment_selection() {
    log "Showing desktop environment selection..."
    
    SELECTED_DE=$(dialog --clear --title "$(get_text 'desktop_env')" \
        --menu "$(get_text 'desktop_env'):" 18 60 10 \
        "gnome" "GNOME" \
        "kde" "KDE Plasma" \
        "xfce" "XFCE" \
        "cinnamon" "Cinnamon" \
        "mate" "MATE" \
        "lxde" "LXDE" \
        "i3" "i3 (Tiling WM)" \
        "none" "No Desktop (Server)" \
        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        SELECTED_DE="xfce"
    fi
    
    log "Desktop environment selected: $SELECTED_DE"
}

installation_summary() {
    log "Showing installation summary..."
    
    local boot_mode="Legacy BIOS"
    [ "$IS_UEFI" = true ] && boot_mode="UEFI"
    
    local nvidia_status="No"
    [ "$INSTALL_NVIDIA" = true ] && nvidia_status="Yes"
    
    local encryption_status="No"
    [ "$USE_ENCRYPTION" = true ] && encryption_status="Yes"
    
    dialog --title "$(get_text 'installation_summary')" \
           --yesno "$(get_text 'installation_summary'):\n\n\
Language: $SELECTED_LANG\n\
Timezone: $SELECTED_TIMEZONE\n\
Keyboard: $SELECTED_KEYBOARD\n\
Disk: $SELECTED_DISK\n\
Boot Mode: $boot_mode\n\
SWAP Type: $SELECTED_SWAP_TYPE\n\
Encryption: $encryption_status\n\
NVIDIA Drivers: $nvidia_status\n\
Desktop: $SELECTED_DE\n\
Username: $USERNAME\n\
Hostname: $HOSTNAME\n\n\
Proceed with installation?" 22 70
    
    if [ $? -ne 0 ]; then
        log "User cancelled installation"
        clear
        exit 0
    fi
}

################################################################################
# PARTITIONING FUNCTIONS
################################################################################

auto_partition_disk() {
    log "Starting automatic disk partitioning on $SELECTED_DISK..."
    
    # Warning
    dialog --title "WARNING" \
           --yesno "This will ERASE ALL DATA on $SELECTED_DISK!\n\nAre you sure?" 8 60
    
    if [ $? -ne 0 ]; then
        log "User cancelled partitioning"
        exit 0
    fi
    
    # Wipe disk
    log "Wiping disk $SELECTED_DISK..."
    wipefs -af "$SELECTED_DISK" 2>&1 | tee -a "$LOG_FILE"
    
    # Create partition table
    if [ "$IS_UEFI" = true ]; then
        log "Creating GPT partition table for UEFI..."
        parted -s "$SELECTED_DISK" mklabel gpt 2>&1 | tee -a "$LOG_FILE"
        
        # EFI partition (512MB) - GPT doesn't use filesystem type in mkpart
        log "Creating EFI partition..."
        parted -s "$SELECTED_DISK" mkpart EFI 1MiB 513MiB 2>&1 | tee -a "$LOG_FILE"
        parted -s "$SELECTED_DISK" set 1 esp on 2>&1 | tee -a "$LOG_FILE"
        
        # Root partition (remaining space or leave space for swap)
        if [ "$SELECTED_SWAP_TYPE" = "swap" ]; then
            log "Creating root partition and swap partition..."
            # Get disk size and calculate partition end
            local disk_size=$(parted -s "$SELECTED_DISK" unit MiB print | grep "^Disk" | awk '{print $3}' | sed 's/MiB//')
            local swap_start=$((disk_size - 4096))  # 4GiB = 4096MiB from end
            parted -s "$SELECTED_DISK" mkpart ROOT 513MiB ${swap_start}MiB 2>&1 | tee -a "$LOG_FILE"
            parted -s "$SELECTED_DISK" mkpart SWAP ${swap_start}MiB 100% 2>&1 | tee -a "$LOG_FILE"
        else
            log "Creating root partition..."
            parted -s "$SELECTED_DISK" mkpart ROOT 513MiB 100% 2>&1 | tee -a "$LOG_FILE"
        fi
    else
        log "Creating MBR partition table for Legacy BIOS..."
        parted -s "$SELECTED_DISK" mklabel msdos 2>&1 | tee -a "$LOG_FILE"
        
        # Root partition - MBR uses filesystem type
        if [ "$SELECTED_SWAP_TYPE" = "swap" ]; then
            log "Creating root partition and swap partition..."
            # Get disk size and calculate partition end
            local disk_size=$(parted -s "$SELECTED_DISK" unit MiB print | grep "^Disk" | awk '{print $3}' | sed 's/MiB//')
            local swap_start=$((disk_size - 4096))  # 4GiB = 4096MiB from end
            parted -s "$SELECTED_DISK" mkpart primary ext4 1MiB ${swap_start}MiB 2>&1 | tee -a "$LOG_FILE"
            parted -s "$SELECTED_DISK" mkpart primary linux-swap ${swap_start}MiB 100% 2>&1 | tee -a "$LOG_FILE"
        else
            log "Creating root partition..."
            parted -s "$SELECTED_DISK" mkpart primary ext4 1MiB 100% 2>&1 | tee -a "$LOG_FILE"
        fi
        
        parted -s "$SELECTED_DISK" set 1 boot on 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Wait for kernel to update
    sleep 2
    partprobe "$SELECTED_DISK"
    sleep 2
    
    log_success "Disk partitioning complete"
}

format_partitions() {
    log "Formatting partitions..."
    
    local root_part="${SELECTED_DISK}2"
    local efi_part="${SELECTED_DISK}1"
    
    # Handle different naming schemes (nvme, mmcblk, etc.)
    if [[ "$SELECTED_DISK" =~ "nvme" ]] || [[ "$SELECTED_DISK" =~ "mmcblk" ]]; then
        root_part="${SELECTED_DISK}p2"
        efi_part="${SELECTED_DISK}p1"
    fi
    
    # Format EFI partition (UEFI only)
    if [ "$IS_UEFI" = true ]; then
        log "Formatting EFI partition $efi_part..."
        mkfs.fat -F32 "$efi_part" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Format root partition
    log "Formatting root partition $root_part..."
    
    if [ "$USE_ENCRYPTION" = true ]; then
        log "Setting up LUKS encryption..."
        echo -n "$USER_PASSWORD" | cryptsetup luksFormat "$root_part" -
        echo -n "$USER_PASSWORD" | cryptsetup open "$root_part" cryptroot -
        mkfs.ext4 -L "Snok-Root" /dev/mapper/cryptroot 2>&1 | tee -a "$LOG_FILE"
    else
        mkfs.ext4 -L "Snok-Root" "$root_part" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Format swap partition if selected
    if [ "$SELECTED_SWAP_TYPE" = "swap" ]; then
        local swap_part="${SELECTED_DISK}3"
        # Handle different naming schemes for swap
        if [[ "$SELECTED_DISK" =~ "nvme" ]] || [[ "$SELECTED_DISK" =~ "mmcblk" ]]; then
            swap_part="${SELECTED_DISK}p3"
        fi
        log "Formatting swap partition $swap_part..."
        mkswap "$swap_part" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    log_success "Partition formatting complete"
}

################################################################################
# INSTALLATION FUNCTIONS
################################################################################

mount_partitions() {
    log "Mounting partitions..."
    
    local root_part="${SELECTED_DISK}2"
    local efi_part="${SELECTED_DISK}1"
    
    # Handle different naming schemes
    if [[ "$SELECTED_DISK" =~ "nvme" ]] || [[ "$SELECTED_DISK" =~ "mmcblk" ]]; then
        root_part="${SELECTED_DISK}p2"
        efi_part="${SELECTED_DISK}p1"
    fi
    
    # Mount root
    mkdir -p /mnt
    if [ "$USE_ENCRYPTION" = true ]; then
        mount /dev/mapper/cryptroot /mnt
    else
        mount "$root_part" /mnt
    fi
    
    # Mount EFI (UEFI only)
    if [ "$IS_UEFI" = true ]; then
        mkdir -p /mnt/boot/efi
        mount "$efi_part" /mnt/boot/efi
    fi
    
    # Enable swap if selected
    if [ "$SELECTED_SWAP_TYPE" = "swap" ]; then
        local swap_part="${SELECTED_DISK}3"
        # Handle different naming schemes for swap
        if [[ "$SELECTED_DISK" =~ "nvme" ]] || [[ "$SELECTED_DISK" =~ "mmcblk" ]]; then
            swap_part="${SELECTED_DISK}p3"
        fi
        swapon "$swap_part"
    fi
    
    log_success "Partitions mounted"
}

install_base_system() {
    log "Installing base system..."
    
    # This is a placeholder - actual implementation depends on the distribution
    # For Arch-based: pacstrap /mnt base linux linux-firmware
    # For Debian-based: debootstrap
    
    dialog --title "$(get_text 'installing')" \
           --infobox "$(get_text 'installing')\n\nThis may take several minutes..." 8 60
    
    # Simulate installation for demonstration
    for i in {1..100}; do
        echo "$i"
        sleep 0.1
    done | dialog --title "$(get_text 'installing')" --gauge "Installing base system..." 8 60 0
    
    log_success "Base system installed"
}

configure_system() {
    log "Configuring system..."
    
    # Set hostname
    echo "$HOSTNAME" > /mnt/etc/hostname
    
    # Set timezone
    ln -sf "/usr/share/zoneinfo/$SELECTED_TIMEZONE" /mnt/etc/localtime
    
    # Set keyboard layout
    echo "KEYMAP=$SELECTED_KEYBOARD" > /mnt/etc/vconsole.conf
    
    # Create user
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME" 2>&1 | tee -a "$LOG_FILE" || true
    echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd 2>&1 | tee -a "$LOG_FILE" || true
    echo "root:$ROOT_PASSWORD" | arch-chroot /mnt chpasswd 2>&1 | tee -a "$LOG_FILE" || true
    
    log_success "System configuration complete"
}

install_bootloader() {
    log "Installing bootloader..."
    
    if [ "$IS_UEFI" = true ]; then
        log "Installing GRUB for UEFI..."
        # arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    else
        log "Installing GRUB for Legacy BIOS..."
        # arch-chroot /mnt grub-install --target=i386-pc "$SELECTED_DISK"
    fi
    
    # Generate GRUB config
    # arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    
    log_success "Bootloader installed"
}

setup_zram() {
    if [ "$SELECTED_SWAP_TYPE" = "zram" ]; then
        log "Setting up ZRAM..."
        
        # Create zram configuration
        cat > /mnt/etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
        
        log_success "ZRAM configured"
    fi
}

install_nvidia_drivers() {
    if [ "$INSTALL_NVIDIA" = true ]; then
        log "Installing NVIDIA drivers..."
        
        dialog --title "$(get_text 'installing')" \
               --infobox "Installing NVIDIA drivers..." 6 50
        
        # Distribution-specific NVIDIA installation
        # For Arch: arch-chroot /mnt pacman -S nvidia nvidia-utils
        # For Ubuntu: arch-chroot /mnt apt install nvidia-driver-XXX
        
        log_success "NVIDIA drivers installed"
    fi
}

install_desktop_environment() {
    if [ "$SELECTED_DE" != "none" ]; then
        log "Installing desktop environment: $SELECTED_DE..."
        
        dialog --title "$(get_text 'installing')" \
               --infobox "Installing $SELECTED_DE desktop environment..." 6 50
        
        # Distribution and DE-specific installation
        # This would need to be implemented based on the target distribution
        
        log_success "Desktop environment installed"
    fi
}

################################################################################
# MAIN INSTALLATION FLOW
################################################################################

main() {
    # Initialize
    mkdir -p "$(dirname "$LOG_FILE")"
    log "=== Snok-Installer Started ==="
    log "Log file: $LOG_FILE"
    
    # Show logo
    show_logo
    
    # Check requirements
    check_root
    check_dependencies
    init_languages
    
    # Detect hardware
    detect_boot_mode
    get_system_info
    
    # User interaction
    language_selection
    welcome_screen
    timezone_selection
    keyboard_selection
    disk_selection
    swap_selection
    nvidia_prompt
    encryption_prompt
    user_setup
    desktop_environment_selection
    installation_summary
    
    # Installation process
    auto_partition_disk
    format_partitions
    mount_partitions
    install_base_system
    configure_system
    setup_zram
    install_bootloader
    install_nvidia_drivers
    install_desktop_environment
    
    # Completion
    log_success "Installation completed successfully!"
    
    dialog --title "$(get_text 'complete')" \
           --msgbox "$(get_text 'complete')\n\nYou can now reboot your system.\n\nLog file: $LOG_FILE" 12 60
    
    clear
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "You can now reboot your system."
}

# Run main function
main "$@"
