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

#init node
celestia light init --p2p.network blockspacerace

#select gRPC endpoint use default or enter custom
echo -n "select gRPC endpoint (1 - default-https://rpc-blockspacerace.pops.one:9090, 2 - enter custom gRPC,default - no) > "
read selectendpoint
echo
if test "$selectendpoint" == "1"
then
    RPC_ENDPOINT=$"https://rpc-blockspacerace.pops.one:9090"
    echo RPC_ENDPOINT=$RPC_ENDPOINT | sudo tee -i -a /root/.celestia-light-blockspacerace/config.toml
fi
if test "$selectendpoint" == "2"
then
    read -p "Enter Your Endpoint: " RPC_ENDPOINT
    echo RPC_ENDPOINT=$RPC_ENDPOINT | sudo tee -i -a /root/.celestia-light-blockspacerace/config.toml
fi

#create system service
echo "[Unit]
Description=celestia-lightd Light Node
After=network-online.target
[Service]
User=root
ExecStart=/usr/local/bin/celestia light start --core.ip $RPC_ENDPOINT 
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target" > $HOME/celestia-lightd.service
sudo mv $HOME/celestia-lightd.service /etc/systemd/system/

#enable and start service
sudo systemctl enable celestia-lightd
sudo systemctl start celestia-lightd

#display wallet 
cd celestia-node
echo "your wallet address is below, to pay for data transactions you will need to fund this address"
echo "(cat ./cel-key list --node.type light --keyring-backend test)"

#logs
echo "you can display logs at any time with"
echo "sudo journalctl -u celestia-lightd.service -f"
echo -n "press y to display logs on the terminal (otherwise press enter ) > "
read displaylogs
echo
if test "$displaylogs" == "y"
then
    sudo journalctl -u celestia-lightd.service -f
fi
