# Celestia-Tooling
deployment scripts for celestia nodes
Celestia conensus Node – Ubuntu/AMD

Hardware requirements
The following hardware minimum requirements are recommended for running the Consensus Full Node:

Memory: 8 GB RAM
CPU: Quad-Core
Disk: 250 GB SSD Storage
Bandwidth: 1 Gbps for Download/100 Mbps for Upload

Celestia Official docs: https://docs.celestia.org/

Install dependencies
Once you have setup your instance, ssh into the instance to begin installing the dependencies needed to run a node.

sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y && sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop net-tools lsof -y < "/dev/null" && sudo apt-get update -y && sudo apt-get install wget liblz4-tool aria2 -y && sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

Install Golang
celestia-app and celestia-node are written in Golang so we must install Golang to build and run them.

ver="1.19.3"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version


Setup the P2P networks
Now we will setup the P2P Networks by cloning the networks repository:

cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git



To initialize the network pick a "node-name" that describes your node. The --chain-id parameter we are using here is blockspacerace-0. Keep in mind that this might change if a new testnet is deployed.

celestia-appd init "node-name" --chain-id blockspacerace-0

Copy the genesis.json file. For blockspacerace we are using:

cp $HOME/networks/blockspacerace/genesis.json $HOME/.celestia-app/config

Set seeds and peers:

PERSISTENT_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/blockspacerace/peers.txt | tr -d '\n')
echo $PERSISTENT_PEERS
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PERSISTENT_PEERS\"/" $HOME/.celestia-app/config/config.toml


Note: You can find more peers here.

Configure pruning
For lower disk space usage we recommend setting up pruning using the configurations below. You can change this to your own pruning configurations if you want:

PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="10"

sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.celestia-app/config/app.toml


Reset network
This will delete all data folders so we can start fresh:

celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app

Quick sync
Quick sync effectively downloads the entire data directory from a third-party provider meaning the node has all the application and blockchain state as the node it was copied from.

Run the following command to quick-sync from a snapshot for blockspacerace:

cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | \
    egrep -o ">blockspacerace.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - \
    -C ~/.celestia-app/data/
    
    Consensus nodes
If you are running a validator or consensus full node, here are the steps to setting up celestia-appd as a background process.

Start the celestia-app with SystemD
SystemD is a daemon service useful for running applications as background processes.

Create Celestia-App systemd file:

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd.service
[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia-appd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

If the file was created successfully you will be able to see its content:

cat /etc/systemd/system/celestia-appd.service

Enable and start celestia-appd daemon:

sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd
