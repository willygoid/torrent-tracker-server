#!/bin/bash

# Function to check kernel version
check_kernel_version() {
    kernel_version=$(uname -r)

    # Extract major and minor version numbers
    major_version=$(echo "$kernel_version" | cut -d'.' -f1)
    minor_version=$(echo "$kernel_version" | cut -d'.' -f2)

    # Define the maximum allowed major and minor version
    max_major=5
    max_minor=8

    # Check if the kernel version is less than or equal to 5.8
    if [ "$major_version" -lt "$max_major" ] || { [ "$major_version" -eq "$max_major" ] && [ "$minor_version" -le "$max_minor" ]; }; then
        return 0
    else
        return 1
    fi
}

# Function to install the latest kernel
install_latest_kernel() {
    echo "Installing the latest kernel..."
    sudo apt-get install software-properties-common -y
    sudo apt update && sudo apt upgrade -y
    sudo add-apt-repository ppa:cappelikan/ppa -y
    sudo apt update -y
    sudo apt install mainline -y
    sudo mainline --install-latest

    echo "Latest kernel installed! Please run this script again after reboot."
    echo "Rebooting..."
    reboot
}

# Function to install Torrent Tracker
install_torrent_tracker() {
    echo "Installing Rust Lang..."
    sudo apt install git curl -y
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
    echo "Rust is installed with version:"
    rustc --version
    
    echo "Installing clang..."
    sudo apt install clang -y
    export CC=clang
    export CXX=clang++
    echo 'export CC=clang' >> ~/.bashrc
    echo 'export CXX=clang++' >> ~/.bashrc
    source ~/.bashrc
    echo "Clang installed with version:"
    clang --version

    echo "Downloading torrent tracker software..."
    git clone https://github.com/greatest-ape/aquatic.git
    cd aquatic || { echo "Failed to change directory to aquatic"; exit 1; }

    echo "Installing torrent tracker software..."
    cargo build --release

	print allowing firewal for Aquatic Service...
	sudo ufw allow 6969/tcp
	sudo ufw allow 6969/udp
	
	print making software can be executed...
	chmod +x $current_dir/target/release/aquatic
}

# Function to add the service
adding_service() {
    local current_dir
    current_dir=$(pwd)
    
    echo "Creating systemd service file..."
    sudo tee /etc/systemd/system/aquatic.service > /dev/null <<EOF
[Unit]
Description=Aquatic BitTorrent Tracker
After=network.target

[Service]
User=root
WorkingDirectory=$current_dir
ExecStart=$current_dir/target/release/aquatic http
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


    echo "Enabling and starting the Aquatic service..."
    sudo systemctl enable aquatic
    sudo systemctl start aquatic
}

#function to run and check connection
run_and_check(){
	print running torrent tracker software...
	$current_dir/target/release/aquatic udp

	ip_public = getippublic if none set localhost
	
	check have response or not
	curl udp://{ip_public}:6969
	
	if have response, print server installed and working successfully with address
	udp://{ip:public}:6969
	
	if not have response print server installed but have error, make this server open 6969 port

}


# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

# Print current kernel version and minimum version required
echo "Current kernel version is: $(uname -r)"
echo "Minimum kernel version required to continue is 5.8"

# Check kernel version
if check_kernel_version; then
    echo "Kernel version is less than or equal to 5.8. Installing the latest kernel..."
    install_latest_kernel
else
    echo "Kernel version meets the minimum requirement."
    install_torrent_tracker

    read -p "Do you want to add the torrent tracker service? (y/n, default is yes): " answer
    if [[ "$answer" != "n" && "$answer" != "no" ]]; then
        adding_service
    else
        echo "Service installation skipped."
    fi
	
	run_and_check
	
fi
