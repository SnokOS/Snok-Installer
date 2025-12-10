# Snok-Installer V2

<div align="center">

![Snok Logo](assets/logo.png)

**Distribution-Independent Linux Installer**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version](https://img.shields.io/badge/version-2.0-green.svg)](https://github.com/snok/installer)

</div>

---

## 🌟 Overview

**Snok-Installer** is a powerful, distribution-independent Linux installer designed for ease of use and maximum flexibility. It provides a modern text-based interface for installing Linux systems with advanced features like encryption, automatic hardware detection, and multi-language support.

### Key Features

✅ **Distribution Independent** - Works with any Linux distribution  
✅ **Modern TUI Interface** - Beautiful dialog-based interface  
✅ **Multi-Language Support** - Arabic, English, French, Spanish  
✅ **Automatic Hardware Detection** - NVIDIA GPU, UEFI/Legacy BIOS  
✅ **Advanced Partitioning** - Auto and manual modes  
✅ **Disk Encryption** - Full LUKS encryption support  
✅ **SWAP Options** - Choose between SWAP partition, ZRAM, or none  
✅ **Dual-Boot Support** - Install alongside existing systems  
✅ **Desktop Environment Selection** - Multiple DE options  
✅ **Comprehensive Logging** - Detailed installation logs  
✅ **Error Recovery** - Automatic error detection and handling  

---

## 📋 Requirements

### System Requirements
- **RAM**: Minimum 2GB (4GB+ recommended)
- **Disk Space**: Minimum 20GB
- **Boot Mode**: UEFI or Legacy BIOS
- **Architecture**: x86_64

### Software Dependencies
```bash
# Required packages
dialog lsblk parted mkfs.ext4 mkfs.fat lspci wipefs cryptsetup
```

---

## 🚀 Installation & Usage

### Quick Start

1. **Download the installer**:
   ```bash
   git clone https://github.com/SnokOS/Snok-Installer.git
   cd Snok-Installer
   ```

2. **Make executable**:
   ```bash
   chmod +x snok-installer.sh
   ```

3. **Run as root**:
   ```bash
   sudo ./snok-installer.sh
   ```

### Installation Steps

The installer guides you through these steps:

1. **Language Selection** - Choose your preferred language
2. **Timezone Configuration** - Set your timezone
3. **Keyboard Layout** - Select keyboard layout
4. **Disk Selection** - Choose installation disk
5. **SWAP Configuration** - Select SWAP type (partition/ZRAM/none)
6. **Encryption** - Optional LUKS disk encryption
7. **User Setup** - Create user account and set passwords
8. **Desktop Environment** - Choose your DE
9. **Summary Review** - Confirm installation settings
10. **Installation** - Automated installation process
11. **Completion** - Reboot into your new system

---

## 🎨 Features in Detail

### 🌍 Multi-Language Support

Full support for:
- **English** - Complete interface
- **العربية (Arabic)** - RTL text support
- **Français (French)** - Coming soon
- **Español (Spanish)** - Coming soon

### 🖥️ Hardware Detection

**Automatic Detection:**
- NVIDIA GPU detection with driver installation option
- UEFI vs Legacy BIOS boot mode
- Storage devices and capacity
- CPU and RAM information

### 💾 Disk Management

**Partitioning Options:**
- **Automatic**: One-click partitioning
- **Manual**: Advanced control (coming soon)

**Supported Features:**
- LUKS full disk encryption
- LVM (Logical Volume Manager)
- RAID configurations
- GPT and MBR partition tables

### 🔄 SWAP Configuration

Smart SWAP recommendations based on RAM:
- **< 4GB RAM**: SWAP partition recommended
- **4-8GB RAM**: ZRAM recommended
- **> 8GB RAM**: ZRAM or no SWAP

**Options:**
- Traditional SWAP partition
- ZRAM (compressed RAM swap)
- No SWAP

### 🎯 Desktop Environments

Choose from:
- GNOME
- KDE Plasma
- XFCE
- Cinnamon
- MATE
- LXDE
- i3 (Tiling WM)
- None (Server installation)

---

## 📁 Project Structure

```
Snok-Installer
├── snok-installer.sh      # Main installer script
├── assets/
│   └── logo.png           # Snok logo
├── config/                # Configuration files
├── logs/                  # Installation logs
└── README.md             # This file
```

---

## 🔧 Advanced Usage

### Command Line Options

```bash
# Standard installation
sudo ./snok-installer.sh

# View help (coming soon)
sudo ./snok-installer.sh --help

# Dry run mode (coming soon)
sudo ./snok-installer.sh --dry-run
```

### Log Files

Installation logs are saved to:
```
logs/snok-installer-YYYYMMDD-HHMMSS.log
```

---

## 🛠️ Customization

### For Developers

The installer is modular and easy to customize:

**Key Functions:**
- `language_selection()` - Language menu
- `auto_partition_disk()` - Partitioning logic
- `install_base_system()` - Base system installation
- `configure_system()` - System configuration

**Adding Languages:**
Edit the `init_languages()` function to add new language strings.

**Distribution-Specific Adaptations:**
Modify `install_base_system()` for your distribution's package manager:
- Arch: `pacstrap`
- Debian/Ubuntu: `debootstrap`
- Fedora: `dnf`

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Missing dependencies"  
**Solution**: Install required packages:
```bash
sudo apt install dialog parted  # Debian/Ubuntu
sudo pacman -S dialog parted    # Arch
```

**Issue**: "No disks detected"  
**Solution**: Ensure you're running as root and disks are properly connected

**Issue**: "UEFI boot failed"  
**Solution**: Check BIOS settings, ensure Secure Boot is disabled

### Getting Help

- Check log files in `logs/` directory
- Review error messages carefully
- Ensure all dependencies are installed
- Test in a virtual machine first

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0**.

See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Inspired by Calamares installer framework
- Built for the Linux community
- Special thanks to all contributors

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/SnokOS/installer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SnokOS/installer/discussions)
- **Email**: support@snok-installer.org

---

<div align="center">

**Made with ❤️ for the Linux Community**

[Website](https://SnokOS.org) • [Documentation](https://docs.SnokOS.org) • [Community](https://community.SnokOS.org)

</div>

---

## 📖 README - النسخة العربية

# Snok-Installer V2

## نظرة عامة

**Snok-Installer** هو برنامج تثبيت لينكس قوي ومستقل عن التوزيعات، مصمم لسهولة الاستخدام والمرونة القصوى.

### المزايا الرئيسية

✅ مستقل عن التوزيعة  
✅ واجهة نصية عصرية  
✅ دعم متعدد اللغات (العربية، الإنجليزية)  
✅ كشف تلقائي للعتاد (NVIDIA، UEFI/Legacy)  
✅ تقسيم متقدم للأقراص  
✅ تشفير كامل للقرص (LUKS)  
✅ خيارات SWAP متعددة  
✅ دعم الإقلاع المزدوج  

### الاستخدام

```bash
sudo ./snok-installer.sh
```

### المتطلبات

- ذاكرة RAM: 2GB كحد أدنى
- مساحة القرص: 20GB كحد أدنى
- وضع الإقلاع: UEFI أو Legacy BIOS

---

**صنع بـ ❤️ لمجتمع لينكس**
