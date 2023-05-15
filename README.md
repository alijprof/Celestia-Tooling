# Celestia Node Shell Scrips
The following hardware minimum requirements:
Memory: 8 GB RAM
CPU: 6 cores
Disk: 1 TB SSD Storage
Bandwidth: 1 Gbps for Download/1 Gbps for Upload
# Consensus & Bridge Node on one device

The following is for running a consensus node and bridge node on the same device. You should run the consensus node shell script first then the bridge node script as root user. This is a shell script that automates the installation and configuration of a Celestia Consensus & Bridge client on Ubuntu 20.04 LTS, including installing prerequisite packages, Go, selecting the Celestia Network, installing the Celestia node, initiating the Celestia node for a bridge client, setting up a wallet or importing an existing one, and starting the light client with SystemD.

    sudo -i

download script, make executable and run the script using the below:

# Consensus Node

    wget https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Consensus-Node.sh && chmod +x Consensus-Node.sh && ./Consensus-Node.sh

# Bridge Node

    wget https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Bridge-Node.sh && chmod +x Bridge-Node.sh && ./Bridge-Node.sh
    
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
