#!/usr/bin/env bash
echo "****************************************************************"
echo "* 1 ____     _____   _______                            _      *"
echo "*  / __ \   / ____| |__   __|     /\                   | |     *"
echo "* | |  | | | (___      | |       /  \     _ __    ___  | |__   *"
echo "* | |  | |  \___ \     | |      / /\ \   | '__|  / __| | '_ \  *" 
echo "* | |__| |  ____) |    | |     / ____ \  | |    | (__  | | | | *"
echo "*  \____/  |_____/     |_|    /_/    \_\ |_|     \___| |_| |_| *"
echo "*                                                              *"
echo "****************************************************************"

echo "*******************************************************"
echo "* 1                                                   *"
echo "*       Arch Linux Pre-Install Setup and Config       *"
echo "*                                                     *"
echo "*******************************************************"
    timedatectl set-ntp true
    SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"       # Get the value of Present Directory
    sed -i 's/^#Parallel/Parallel/' /etc/pacman.conf                                        # Enable Parallel Downloads
    sed -i 's/^#Color/Color/' /etc/pacman.conf                                              # Enable Color
    #sed -i                                                                                 # ILoveCandy
    pacman -S --noconfirm --needed pacman-contrib reflector rsync #terminus-font
    #setfont ter-v22b


echo "*******************************************************"
echo "* 1     Setting up mirrors for optimal download       *"
echo "*******************************************************"
    echo "****************************************************************"
    echo "* 1 ____     _____   _______                            _      *"
    echo "*  / __ \   / ____| |__   __|     /\                   | |     *"
    echo "* | |  | | | (___      | |       /  \     _ __    ___  | |__   *"
    echo "* | |  | |  \___ \     | |      / /\ \   | '__|  / __| | '_ \  *"
    echo "* | |__| |  ____) |    | |     / ____ \  | |    | (__  | | | | *"
    echo "*  \____/  |_____/     |_|    /_/    \_\ |_|     \___| |_| |_| *"
    echo "*                                                              *"
    echo "****************************************************************"
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup                             # Backup your mirrorlist
    #iso=$(curl -4 ifconfig.co/country-iso)                                                 # Mirrorlist on Country Basis
    #reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
    reflector -a 48 -p https -l 20 --save /etc/pacman.d/mirrorlist                          # Generate new mirrorlist


echo "*******************************************************"
echo "* 1           Installing prerequisites                *"
echo "*******************************************************"
    pacman -S --noconfirm --needed gptfdisk btrfs-progs


echo "*******************************************************"
echo "* 1                                                   *"
echo "*              Disk Partitioning Setup                *"
echo "*                                                     *"
echo "*******************************************************"
    echo "-------------------------------------------------------"
    echo "          Please Choose The Options Carefully          "
    echo "-------------------------------------------------------"
    PS2='Please Choose The Options Carefully: '
    options=("Already Done Partitioning earlier with this script (Skip Partitioning)" "Run Partitioning Script Now" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Already Done Partitioning earlier with this script (Skip Partitioning)")
                echo "######################################################################################################"
                echo "**************************************************************"
                echo "*       Please Remind us Names & Numbers of Partitions      *"
                echo "**************************************************************"
                lsblk 
                echo "######################################################################################################"
                echo "Please Enter Your *EFI/SYS* Partition Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                read EFI
                echo "Please Enter Your *EFI/SYS* Partition Number {example (1) / (p1) -> Partition Number Only}"
                read EFIn
                echo "Please Enter Your *ROOT* Partition Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                read ROOT
                echo "Please Enter Your *ROOT* Partition Number {example (2) / (p2) -> Partition Number Only}"
                read ROOTn
                break
                ;;
            "Run Partitioning Script Now")
                        echo "######################################################################################################"
                        echo "**************************************************************"
                        echo "*       Please Note Down The Partition Names & Numbers       *"
                        echo "**************************************************************"
                        lsblk 
                        echo "######################################################################################################"
                        PS4='Please Select How You Want To Partition Your Hard-Drive:'
                        options=("Choose Root(/) and Boot Partition Manually" "Format Only Root(/) Partition & not EFI Partition" "Erase Entire HDD/SSD and Create New Partitions (Auto)" "Quit")
                        select opt in "${options[@]}"
                        do
                            case $opt in
                                "Choose Root(/) and Boot Partition Manually")
                                    echo "**********************************************************"
                                    echo "*                Custom-Partition                        *"
                                    echo "*________________________________________________________*"
                                    echo "* THIS WILL FORMAT AND DELETE ALL DATA ON THE PARTITIONS *"
                                    echo "**********************************************************"
                                    echo "Please Enter Your *EFI/SYS* Partition Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read EFI
                                    echo "Please Enter Your *EFI/SYS* Partition Number {example (1) / (p1) -> Partition Number Only}"
                                    read EFIn
                                    echo "Please Enter Your *ROOT* Partition Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read ROOT
                                    echo "Please Enter Your *ROOT* Partition Number {example (2) / (p2) -> Partition Number Only}"
                                    read ROOTn
                                    echo "*******************************************************"
                                    echo "*              Formatting Partitions...               *"
                                    echo "*******************************************************"
                                    # set partition types
                                        sgdisk -t $EFIn:ef00 ${EFI}         # fat32
                                        sgdisk -t $ROOTn:8300 ${ROOT}       # ext4
                                    # label partitions
                                        sgdisk -c $EFIn:"EFI-ARCH" ${EFI}
                                        sgdisk -c $ROOTn:"ROOT" ${ROOT}
                                    echo "-------------------------------------------------------"
                                    echo "               Creating Filesystems...                 "
                                    echo "-------------------------------------------------------"
                                        mkfs.vfat -F32 -n "EFI-ARCH" "${EFI}${EFIn}"
                                        mkfs.btrfs -f -L "ROOT" "${ROOT}${ROOTn}"
                                    echo "*******************************************************"
                                    echo "*                 Creating Subvolume                  *"
                                    echo "*******************************************************"      
                                        mount -t btrfs "${ROOT}${ROOTn}" /mnt           # Root Partition Temp Mount
                                        ls /mnt | xargs btrfs subvolume delete          # subvolume Delete
                                        btrfs subvolume create /mnt/@                   # subvolume Create
                                        umount /mnt
                                    break
                                    ;;
                                "Format Only Root(/) Partition & not EFI Partition")
                                    echo "**************************************************************"
                                    echo "*       Custom-Partition Dual-Boot (One EFI Partition)       *"
                                    echo "*____________________________________________________________*"
                                    echo "* THIS WILL FORMAT AND DELETE ALL DATA ON THE ROOT PARTITION *"
                                    echo "**************************************************************"
                                    echo "Please Enter Your *EFI/SYS* Partition Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read EFI
                                    echo "Please Enter Your *EFI/SYS* Partition Number {example (1) / (p1) -> Partition Number Only}"
                                    read EFIn
                                    echo "Please Enter Your *ROOT* Partition Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read ROOT
                                    echo "Please Enter Your *ROOT* Partition Number {example (2) / (p2) -> Partition Number Only}"
                                    read ROOTn
                                    echo "*******************************************************"
                                    echo "*              Formatting Partition...                *"
                                    echo "*******************************************************"
                                    # set partition types
                                        sgdisk -t $ROOTn:8300 ${ROOT}       #ext4
                                    # label partitions
                                        sgdisk -c $EFIn:"EFI-COMMON" ${EFI}    
                                        sgdisk -c $ROOTn:"ROOT" ${ROOT}
                                    echo "-------------------------------------------------------"
                                    echo "               Creating Filesystems...                 "
                                    echo "-------------------------------------------------------"
                                        mkfs.btrfs -f -L "ROOT" "${ROOT}${ROOTn}"
                                    echo "*******************************************************"
                                    echo "*                 Creating Subvolume                  *"
                                    echo "*******************************************************"      
                                        mount -t btrfs "${ROOT}${ROOTn}" /mnt           # Root Partition Temp Mount
                                        ls /mnt | xargs btrfs subvolume delete          # subvolume Delete
                                        btrfs subvolume create /mnt/@                   # subvolume Create
                                        umount /mnt
                                    break
                                    ;;
                                "Erase Entire HDD/SSD and Create New Partitions (Auto)")
                                    echo "***********************************************************"
                                    echo "*                    Auto-Partition                       *"
                                    echo "*_________________________________________________________*"
                                    echo "*--> THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK  <--*"
                                    echo "***********************************************************"
                                    echo "Please Enter Your Disk Name {example (/dev/sda) / (/dev/nvme0n1) -> Without Partition Number}"
                                    read DISK
                                    echo "*******************************************************"
                                    echo "*                Formatting disk...                   *"
                                    echo "*******************************************************"
                                    # disk prep
                                        sgdisk -Z ${DISK}       # zap/Clean all on disk
                                        sgdisk -a 2048 -o ${DISK}         # new gpt disk 2048 alignment
                                    # create partitions
                                        sgdisk -n 1::+500M --typecode=1:ef00 --change-name=1:'EFI-ARCH' ${DISK}     # partition 1 (UEFI Boot Partition) --fat32
                                        sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ROOT' ${DISK}    # partition 2 (Root), default start, remaining --ext4
                                    # Value Assignment
                                        EFI=${DISK}
                                        EFIn=1
                                        ROOT=${DISK}
                                        ROOTn=2
                                    echo "-------------------------------------------------------"
                                    echo "               Creating Filesystems...                 " 
                                    echo "-------------------------------------------------------"
                                        mkfs.vfat -F32 -n "EFI-ARCH" "${EFI}${EFIn}"
                                        mkfs.btrfs -f -L "ROOT" "${ROOT}${ROOTn}"
                                    echo "*******************************************************"
                                    echo "*                 Creating Subvolume                  *"
                                    echo "*******************************************************"      
                                        mount -t btrfs "${ROOT}${ROOTn}" /mnt           # Root Partition Temp Mount
                                        ls /mnt | xargs btrfs subvolume delete          # subvolume Delete
                                        btrfs subvolume create /mnt/@                   # subvolume Create
                                        umount /mnt
                                    break
                                    ;;
                                "Continue"|"Q"|"Quit"|*)
                                    break
                                    ;;
                            esac
                        done
                ;;
            "Continue"|"Q"|"Quit"|*)
                break
                ;;
        esac
    done


echo "*******************************************************"
echo "* 1               Mounting Partitions                 *"
echo "*******************************************************" 
    mount -t btrfs -o subvol=@ "${ROOT}${ROOTn}" /mnt
    mkdir -p /mnt/boot/efi
    mount "${EFI}${EFIn}" /mnt/boot/

    if ! grep -qs '/mnt' /proc/mounts; then                                                 # Check Drive is mounted or not 
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    #reboot now                                                                             # ( Link / Direct it towards partitioning)
    fi


echo "*******************************************************"
echo "* 1     Arch Linux Installation on Main Drive         *"
echo "*_____________________________________________________*"
echo "*******************************************************"
    pacstrap /mnt base linux linux-firmware nano bash-completion base-devel vim reflector sudo archlinux-keyring wget libnewt networkmanager --noconfirm --needed
    genfstab -U /mnt >> /mnt/etc/fstab
    echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf         # additions to gpg.conf
    cp -R ${SCRIPT_DIR} /mnt/root/                                                          # Copy Script to /root/ostarch/
    cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist


# echo "-----------------------------------------------------"
# echo "---------- Swap for systems with <8G RAM ------------"
# echo "-----------------------------------------------------"
    TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
    if [[  $TOTALMEM -lt 7900000 ]]; then
        if [[ ! -f "/mnt/opt/swap/swapfile" ]]; then                            # Not Valid
            echo "*******************************************************"
            echo "* 1                Making Swap File                   *"
            echo "*******************************************************"
            #Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
            mkdir /mnt/opt/swap #make a dir that we can apply NOCOW to to make it btrfs-friendly.
            chattr +C /mnt/opt/swap #apply NOCOW, btrfs needs that.
            dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
            chmod 600 /mnt/opt/swap/swapfile #set permissions.
            chown root /mnt/opt/swap/swapfile
            mkswap /mnt/opt/swap/swapfile
            swapon /mnt/opt/swap/swapfile
            #The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the sysytem itself.
            echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab #Add swap to fstab, so it KEEPS working after installation.
        fi
        echo "*******************************************************"
        echo "* 1                   Swap Done.                      *"
        echo "*_____________________________________________________*"
        echo "*******************************************************"
    fi



# echo "******************************************************"
# echo "*           GRUB-Bootloader Install (BIOS)           *"
# echo "******************************************************"
    if [[ ! -d "/sys/firmware/efi" ]]; then                             # Not Valid
        echo "*******************************************************"
        echo "* 1         GRUB-Bootloader Install (BIOS)            *"
        echo "*_____________________________________________________*"
        echo "*******************************************************"
            pacman -S grub --noconfirm --needed
            grub-install --target=i386-pc ${EFI}
            isvbox=$(lspci | grep "VirtualBox G")
                if [ "${isvbox}" ]; then
			        echo "VirtualBox detected, creating startup.nsh..."
			        echo "\EFI\arch\grubx64.efi" > /boot/startup.nsh
		        fi
            grub-mkconfig -o /boot/grub/grub.cfg
    fi


echo "*******************************************************"
echo "* 1                                                   *"
echo "*----------System Ready for 2-system-install----------*"
echo "*                                                     *"
echo "*******************************************************"
