#!/bin/bash

# Create directories
mkdir -p "$HOME/log/hardlink"
mkdir -p "$HOME/log/softlink"

if ! [ -d "/mnt/raid" ]; then
    mkdir -p /mnt/raid
fi

# Variables
date=$(date '+%Y%m%d-%H:%M')

# Functions
function info(){
    echo "---------- $1 ----------"
    sleep 1
}
#1
info "1a. Creating file"

if touch /tmp/Wafu; then
    echo "File successfully created"
fi

info "1b. Creating hard link"

if ln --verbose /tmp/Wafu /tmp/hard 2>> "$HOME/log/hardlink/hardlink${date}.log"; then
    echo "Hardlink successfully created"
else
    echo "There was a problem creating a hardlink. Check $HOME/log/hardlink/ for more info."
    exit 1
fi

info "1c. Creating soft link"

if ln -s --verbose /tmp/Wafu /tmp/soft 2>> "$HOME/log/softlink/softlink${date}.log"; then
    echo "Softlink successfully created"
else
    echo "There was a problem creating a softlink. Check $HOME/log/softlink/ for more info."
    exit 1
fi

#2
info "2. Creating file"

if touch "$HOME/AllMighty"; then
    echo "File successfully created"
    info "Setting permissions"
    if chmod --verbose u+s,g+s,o+t "$HOME/AllMighty"; then
        echo "Permissions successfully set"
    fi
fi

#4
info "4. Running find command"

tmp_files=$(find /tmp -type f -perm /g+s)
if [ -z "$tmp_files" ]; then
    echo "No matching files"
else
    echo "$tmp_files"
fi

#5
info "5. Running sed command"

pogo=$(sed -E '/nologin/ s/(games|operator)/pogo/g' /etc/passwd)
if [ -z "$pogo" ]; then
    echo "Failed to find and replace words. Nonexistent"
else
    echo "$pogo"
    info "Found and replaced instances successfully"
fi

#6
info "6. Counting unique shell instances of users"

shell=$(cut -d : -f 7 /etc/passwd | sort | uniq -c)
if [ -z "$shell" ]; then
    echo "/etc/passwd file is empty"
else
    echo "$shell"
fi

#7
info "7. Running grep command"

find_users=$(grep -E 'bob|ftp|systemd' /etc/passwd)
if [ -z "$find_users" ]; then
    echo "No such users in passwd file"
else
    echo "$find_users"
fi

#8
info "8. Finding directories in /etc"

find_dir=$(find /etc -type d -name '*.d')
if [ -z "$find_dir" ]; then
    echo "No matching directories"
else
    echo "$find_dir"
fi

#9
info "9a. Creating files 1..30"
if touch ~/file{1..30}; then
    echo "Files successfully created"
fi

info "9b. Archive and compress files ending with 0"

if tar -zcf files_ending_with_0.tar.gz ~/file*0 2> /dev/null; then
    echo "Archive and compression complete"
fi

#10
info "10. Archive and compress 9 to 21"

if tar -zcf 0ps.tar ~/file{9..21} 2> /dev/null; then
    echo "Archive and compression complete"
fi

#11
info "11. Finding files that starts with [The]"
echo grep -r '^The' /etc/ 2> ~/error.log > ~/regular.log

#12
info "12. Creating file using dd"

dd if=/dev/zero of="$USER.log" bs=1M count=14
if [ -e "$HOME/$USER.log" ]; then
    echo "File created successfully"
else
    echo "File not created"
fi

#13
info "13. Interactive script"

read -rp "Enter a number: " number

if (( number > 4 && number < 10 )); then
    echo "$number is greater than 4 and lesser than 10"
else
	echo "$number is not greater than 4 and not lesser than 10"
fi

#14
info "14. Interactive script"

while true
do
	read -rp "Enter number: " number

	if (( number == 0 ))
	then
		echo "You entered ${number}. Exiting loop"
        break
	fi
done

#15
info "15. Terminating sshd process"
info "Getting PID"

pid=$(pidof sshd)
if kill "$pid"; then
    echo "sshd with id $pid terminated"
fi

#16
info "16a. Creating partition on /dev/sdb"

if fdisk /dev/sdb <<EOF
n
p
1

+128M
t
8e
w
EOF
then
    echo "Partition created successfully"
else
    echo "Failed to create partition"
fi

info "16b. Creating partition on /dev/sdc"

if fdisk /dev/sdc <<EOF
n
p
1

+128M
t
8e
w
EOF
then
    echo "Partition created successfully"
else
    echo "Failed to create partition"
fi

info "16c. Creating physical volumes out of sdb1 sdc1"

if pvcreate /dev/sdb1 /dev/sdc1; then
    echo "Physical volumes created successfully"
else
    echo "Failed to create physical volumes"
fi

info "16d. Creating volume group from both PVs"

if vgcreate academy_vg /dev/sdb1 /dev/sdc1; then
    echo "Volume group created successfully"
else
    echo "Failed to create volume group"
fi

info "16e. Creating logical volume"

if lvcreate -n academy_lv -l 100%FREE academy_vg; then
    echo "Logical volume created successfully"
else
    echo "Failed to create logical volume"
fi

if systemctl daemon-reload; then
    echo "Daemon reloaded"
else
    echo "Failed to reload daemon"
fi

#17
info "17a. Creating partition on /dev/sdb"

if fdisk /dev/sdb <<EOF
n
p
2

+1G
t
82
w
EOF
then
    echo "Swap partition created successfully"
else
    echo "Failed to create swap partition"
fi

info "17b. Creating swap filesystem"

if mkswap /dev/sdb2; then
    echo "Swap filesystem created"
else
    echo "Failed to create swap filesystem"
fi

info "17c. Enabling swap"

if swapon /dev/sdb2; then
    echo "Swap successfully enabled"
else
    echo "Failed to enable swap"
fi

info "17d. Setting persistence on boot"

if echo '/dev/sdb none swap defaults 0 2' >> /etc/fstab; then
    echo "Added swap entry to fstab"
else
    echo "Failed to add entry to fstab"
fi

info "17e. Reloading systemd daemon"

if systemctl daemon-reload; then
    echo "Daemon reloaded"
else
    echo "Failed to reload daemon"
fi

#18
info "18a. Creating raid partition on /dev/sdb"

if fdisk /dev/sdb <<EOF
n
p
3

+1G
t
fd
w
EOF
then
    echo "Raid partition created successfully"
else
    echo "Failed to create raid partition"
fi

info "18b. Creating raid partition on /dev/sdc"

if fdisk /dev/sdc <<EOF
n
p
2

+1G
t
fd
w
EOF
then
    echo "Raid partition created successfully"
else
    echo "Failed to create raid partition"
fi

info "18c. Creating level 1 raid"

if mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb3 /dev/sdc2; then
    echo "Raid successfully created"
else
    echo "Failed to create raid"
fi

info "18d. Formatting to ext4"

if mkfs.ext4 /dev/md0; then
    echo "Format successful"
else
    echo "Format failed"
fi

info "18e. Mounting raid"

if mount /dev/md0 /mnt/raid; then
    echo "Successfully mounted"
else
    echo "Failed to mount"
fi

info "18f. Setting persistence on boot"

if echo '/dev/md0 /mnt/raid ext4 defaults 0 2' >> /etc/fstab; then
    echo "Added swap entry to fstab"
else
    echo "Failed to add entry to fstab"
fi