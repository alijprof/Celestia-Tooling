#!/bin/bash

# Check if .bash_profile exists
if [ ! -f ~/.bash_profile ]; then
    # If not, check if .profile exists
    if [ -f ~/.profile ]; then
        # If .profile exists, rename it to .bash_profile
        mv ~/.profile ~/.bash_profile
    else
        # If neither file exists, create .bash_profile
        touch ~/.bash_profile
    fi
fi

sudo apt update && sudo apt upgrade -y	

# Define variables
NODE_VERSION="v0.9.4"
CHAIN_ID="blockspacerace-0"
PERSISTENT_PEERS="be935b5942fd13c739983a53416006c83837a4d2@178.170.47.171:26656,cea09c9ac235a143d4b6a9d1ba5df6902b2bc2bd@95.214.54.28:20656,5c9cfba00df2aaa9f9fe26952e4bf912e3f1e8ee@195.3.221.5:26656,7b2f4cb70f04f2e9befb6ace66ce1ac7b3bea5b4@178.239.197.179:26656,7ee2ba21197d58679cfc1517b5bbc6465bed387a@65.109.67.25:26656,dc0656ab58280d641c8d10311d86627255bec8a1@148.251.85.27:26656,ccbd6262d0324e2e858594b639f4296cc4952c93@13.57.127.89:26656,a507b2bda6d2974c84ae1e8a8b788fc9e44d01f7@142.132.131.184:26656,9768290c60a746ee97ef1a5bcb8bee69066475e8@65.109.80.150:2600"
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="10"

#Install Dependicies
sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y && sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop net-tools lsof -y < "/dev/null" && sudo apt-get update -y && sudo apt-get install wget liblz4-tool aria2 -y && sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

#Open Ports
sudo ufw allow ssh 
sudo ufw allow 9090
sudo ufw allow 26659
sudo ufw allow 26657
sudo ufw enable

# Install Go
wget "https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Go-Install-v1.20.3.sh"
chmod a+x Go-Install-v1.20.3.sh
./Go-Install-v1.20.3.sh

source ~/.bash_profile

# confirm install
if command -v go &> /dev/null; then
    echo "Go is installed and the PATH is set up correctly"
    go version
else
    echo "Go is not installed or the PATH is not set up correctly"
fi

# Install Celestia APP
wget "https://raw.githubusercontent.com/alijprof/Celestia-Tooling/main/Celestia-App.sh"
chmod a+x Celestia-App.sh
./Celestia-App.sh

# confirm install
if [ $(celestia-appd version | grep -c "0.13.0") -eq 1 ]; then
    echo "Celestia-App Installed Correctly"
else
    echo "Celestia-App NOT Installed Correctly"
fi

# Install Celestia Node
cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/$NODE_VERSION
make build
make install
make cel-key

# Setup the P2P networks
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git
cd ~/celestia-app

# Choose node name
echo "Do you want to choose a name for your node? Enter '1' for a default name or '2' to enter your own name."
read -r USER_CHOICE
if [ "$USER_CHOICE" = "1" ]; then
  NODE_NAME="Lazy Node Runner"
else
  read -p "Enter Your Name: " NODE_NAME
fi
echo "Node name: $NODE_NAME"

# Initialize node
celestia-appd init $NODE_NAME --chain-id $CHAIN_ID

# Copy genesis.json file
cp "$HOME/networks/blockspacerace/genesis.json" "$HOME/.celestia-app/config"

#Peers
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PERSISTENT_PEERS\"/" $HOME/.celestia-app/config/config.toml

#Configure Pruning
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="10"

sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.celestia-app/config/app.toml

#Reset Network
celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app

#Quick Sync
cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | \
    egrep -o ">blockspacerace.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - \
    -C ~/.celestia-app/data/
   
#create system service
echo "[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia-appd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target" > $HOME/celestia-appd.service
sudo mv $HOME/celestia-appd.service /etc/systemd/system/

#enable and start service
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd

#Check Sync
echo "consensus node is now setup and running, Check if connected to peers"
echo "Make sure that you have 'catching_up: false', otherwise leave it running until it is in sync. Using:"curl -s localhost:26657/status | jq .result | jq .sync_info""
echo -n "press y to check Sync (otherwise press enter ) > "
read checksync
echo
if test "$checksync" == "y"
then
    curl -s localhost:26657/status | jq .result | jq .sync_info
fi

#display logs 
echo "Once 'catching_up: true' you can display logs"
echo "you can display logs at any time with "sudo journalctl -u celestia-appd.service -f""
echo -n "press y to display logs on the terminal (otherwise press enter ) > "
read displaylogs
echo
if test "$displaylogs" == "y"
then
    sudo journalctl -u celestia-appd.service -f
fi
#END OF CONSENSUS NODE
