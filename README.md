# Celestia Node Shell Scrips
It is important to ensure the correct hardware requirements that can be seen below:
![image](https://github.com/alijprof/Celestia-Tooling/assets/95873824/dc76f691-2c80-40d2-9fb6-46566500c57b)

# Consensus & Bridge Node on one device

The following is for running a consensus node and bridge node on the same device. You should run the consensus node shell script first then the bridge node script as root user. This is a shell script that automates the installation and configuration of a Celestia Consensus & Bridge client on Ubuntu 20.04 LTS, including installing prerequisite packages, Go, selecting the Celestia Network, installing the Celestia node, initiating the Celestia node for a bridge client, setting up a wallet or importing an existing one, and starting the light client with SystemD.

    sudo -i

download script, make executable and run the script using the below:

# Consensus Node

    wget https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Consensus-Node.sh && chmod +x Consensus-Node.sh && ./Consensus-Node.sh

# Bridge Node

    wget https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Bridge-Node.sh && chmod +x Bridge-Node.sh && ./Bridge-Node.sh
    
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
