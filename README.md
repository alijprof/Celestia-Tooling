# Celestia Node Shell Scrips
The following hardware minimum requirements:
- Memory: 8 GB RAM
- CPU: 6 cores
- Disk: 1 TB SSD Storage
- Bandwidth: 1 Gbps for Download/1 Gbps for Upload
# Consensus & Bridge Node on one device

To run a consensus node and a bridge node on the same device, follow these steps:
1. Run the consensus node shell script as the root user.
2. Once the consensus node script has been executed, proceed to run the bridge node script as the root user.

The shell script automates the installation and configuration of a Celestia Consensus and Bridge client on Ubuntu 20.04 LTS. It includes the following steps:
- Installing prerequisite packages
- Installing Go
- Installing the Celestia node
- Initiating the Celestia node for a bridge client
- Setting up a wallet or importing an existing one
- Starting the bridge and Consesnus client with SystemD

By following these steps and executing the shell scripts, you can conveniently install and configure both the consensus and bridge nodes on your Ubuntu 20.04 LTS device, enabling you to participate in the Celestia network and leverage its functionalities.

Run as root user:
    
    sudo -i

download script, make executable and run the script using the below:

# Consensus Node

    wget https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Consensus-Node.sh && chmod +x Consensus-Node.sh && ./Consensus-Node.sh

# Bridge Node

    wget https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Bridge-Node.sh && chmod +x Bridge-Node.sh && ./Bridge-Node.sh
    
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
