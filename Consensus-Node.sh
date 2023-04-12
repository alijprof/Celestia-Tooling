#Install Dependicies
sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y && sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop net-tools lsof -y < "/dev/null" && sudo apt-get update -y && sudo apt-get install wget liblz4-tool aria2 -y && sudo apt update && sudo apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

#Install Golang
ver="1.19.1"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

#Install Celestia APP
cd $HOME 
rm -rf celestia-app 
git clone https://github.com/celestiaorg/celestia-app.git 
cd celestia-app/ 
APP_VERSION=v0.12.2 
git checkout tags/$APP_VERSION -b $APP_VERSION 
make install 

#Install Celestia Node
cd $HOME 
rm -rf celestia-node 
git clone https://github.com/celestiaorg/celestia-node.git 
cd celestia-node/ 
git checkout tags/v0.8.2 
make build 
make install 
make cel-key 

#Setup the P2P networks
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git
cd ~/celestia-app

#Pick Name

print("Do you want to a rubbish boring name or enter your own name?")
user_choice = input("Enter '1' for boring name or '2' for own name: ")

if user_choice == "1":
then
    NODE_NAME=$"Lazy Node Runner"
    echo NODE_NAME=$NODE_NAME
fi
if user_choice == "2":
then
    read -p "Enter Your Name: " NODE_NAME
    echo NODE_NAME=$NODE_NAME
fi

#initialise Node
celestia-appd init $NODE_NAME --chain-id blockspacerace-0

#Copy Genesis.json file
cp $HOME/networks/blockspacerace/genesis.json $HOME/.celestia-app/config

#Peers
PERSISTENT_PEERS="be935b5942fd13c739983a53416006c83837a4d2@178.170.47.171:26656,cea09c9ac235a143d4b6a9d1ba5df6902b2bc2bd@95.214.54.28:20656,5c9cfba00df2aaa9f9fe26952e4bf912e3f1e8ee@195.3.221.5:26656,7b2f4cb70f04f2e9befb6ace66ce1ac7b3bea5b4@178.239.197.179:26656,7ee2ba21197d58679cfc1517b5bbc6465bed387a@65.109.67.25:26656,dc0656ab58280d641c8d10311d86627255bec8a1@148.251.85.27:26656,ccbd6262d0324e2e858594b639f4296cc4952c93@13.57.127.89:26656,a507b2bda6d2974c84ae1e8a8b788fc9e44d01f7@142.132.131.184:26656,9768290c60a746ee97ef1a5bcb8bee69066475e8@65.109.80.150:2600"
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

#enable and start service
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd

#END OF CONSENSUS NODE
