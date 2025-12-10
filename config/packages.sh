# Desktop Environment Packages

# This file contains package lists for different desktop environments
# Adapt these for your specific distribution

## GNOME
gnome_packages=(
    "gnome"
    "gnome-extra"
    "gdm"
)

## KDE Plasma
kde_packages=(
    "plasma"
    "kde-applications"
    "sddm"
)

## XFCE
xfce_packages=(
    "xfce4"
    "xfce4-goodies"
    "lightdm"
    "lightdm-gtk-greeter"
)

## Cinnamon
cinnamon_packages=(
    "cinnamon"
    "cinnamon-desktop"
    "lightdm"
)

## MATE
mate_packages=(
    "mate"
    "mate-extra"
    "lightdm"
)

## LXDE
lxde_packages=(
    "lxde"
    "lxdm"
)

## i3
i3_packages=(
    "i3-wm"
    "i3status"
    "i3lock"
    "dmenu"
    "lightdm"
)

## Base packages (always installed)
base_packages=(
    "base"
    "linux"
    "linux-firmware"
    "grub"
    "networkmanager"
    "sudo"
    "vim"
    "nano"
)

## NVIDIA packages
nvidia_packages=(
    "nvidia"
    "nvidia-utils"
    "nvidia-settings"
)

## ZRAM packages
zram_packages=(
    "zram-generator"
)
