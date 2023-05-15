#!/bin/bash

#In this part the celestia APP and NODE have already been installed during the consensus node set up

#In this we will be running both the consensus and bridge node on the same device and linking them together

# Define default values for parameters
DEFAULT_CORE_IP="localhost"
DEFAULT_CORE_RPC_PORT="26657"
DEFAULT_CORE_GRPC_PORT="9090"
DEFAULT_METRICS_TLS="false"
DEFAULT_METRICS_ENDPOINT="otel.celestia.tools:4318"
DEFAULT_GATEWAY_ADDR="localhost"
DEFAULT_GATEWAY_PORT="26659"
DEFAULT_P2P_NETWORK="blockspacerace"

# Parse input parameters
CORE_IP=${1:-$DEFAULT_CORE_IP}
CORE_RPC_PORT=${2:-$DEFAULT_CORE_RPC_PORT}
CORE_GRPC_PORT=${3:-$DEFAULT_CORE_GRPC_PORT}
METRICS_TLS=${4:-$DEFAULT_METRICS_TLS}
METRICS_ENDPOINT=${5:-$DEFAULT_METRICS_ENDPOINT}
GATEWAY_ADDR=${6:-$DEFAULT_GATEWAY_ADDR}
GATEWAY_PORT=${7:-$DEFAULT_GATEWAY_PORT}
P2P_NETWORK=${8:-$DEFAULT_P2P_NETWORK}

# Change to celestia-node directory
cd ~/celestia-node

# Initialize celestia bridge
celestia bridge init --core.ip $CORE_IP --p2p.network $P2P_NETWORK

#WALLET SETUP
#use default wallet or import existing
source $HOME/.bash_profile
echo -n "import existing wallet? (1 - use auto-generated wallet, 2 - import existing wallet) > "
read selectwallet
echo
if test "$selectwallet" == "1"
then
    WALLET="my_celes_key"
    echo "export WALLET=$WALLET" >> $HOME/.bash_profile
fi
if test "$selectwallet" == "2"
then
    read -p "Enter name for wallet: " WALLET
    echo "export WALLET=$WALLET" >> $HOME/.bash_profile
fi

#display wallet info or import existing
if [ "$WALLET" == "my_celes_key" ]
then
    ./cel-key list --node.type full --p2p.network $P2P_NETWORK --keyring-backend test
    echo "to pay for data transactions this address must be funded, press any key to continue"
    read -n 1 -r -s -p ""
else
    ./cel-key add $WALLET --keyring-backend test --node.type full --p2p.network $P2P_NETWORK --recover
fi

# Create system service

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-bridge.service
[Unit]
Description=celestia-bridge Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) bridge start --core.ip $CORE_IP --core.rpc.port $CORE_RPC_PORT --core.grpc.port $CORE_GRPC_PORT --keyring.accname $WALLET --metrics.tls=$METRICS_TLS --metrics --metrics.endpoint $METRICS_ENDPOINT --gateway --gateway.addr $GATEWAY_ADDR --gateway.port $GATEWAY_PORT --p2p.network $P2P_NETWORK
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# enable and start service
systemctl daemon-reload
systemctl enable celestia-bridged.service
systemctl start celestia-bridged.service

# display wallet address
echo "Your wallet address is below. To pay for data transactions you will need to fund this address. Check Discord for a faucet."
cel_key_list_output="$(cel-key list --node.type bridge --keyring-backend test --p2p.network blockspacerace)"
if [[ $? -ne 0 ]]; then
    echo "ERROR: failed to retrieve wallet address"
    exit 1
fi
wallet_address="$(echo "${cel_key_list_output}" | jq -r '.[0].address')"
echo "${wallet_address}"

# display logs
read -p "Do you want to display logs? (y/n) " display_logs
if [[ "$display_logs" == "y" ]]; then
    sudo journalctl -u celestia-bridged.service -f
fi

echo "Congrats, Bridge Node installation is complete!!!"

#End of Process
