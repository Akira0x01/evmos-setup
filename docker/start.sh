#!/bin/bash

BIN_DIR="/home/user/bin"
if ! echo "$PATH" | tr ':' '\n' | grep -q "$BIN_DIR"; then
    export PATH="$PATH:$BIN_DIR"
fi

DENOM="vcity"

CHAIN="vcitychain"
CHAINID="$CHAIN"_2023825-1
CHAIND="evmosd"

DATA_DIR=$(pwd)/build/vcity
CONFIG=$DATA_DIR/config/config.toml
APP_CONFIG=$DATA_DIR/config/app.toml

sed -i 's/^seeds = .*/seeds = ""/' $CONFIG
sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
sed -i 's/enable-indexer = false/enable-indexer = true/g' $APP_CONFIG
perl -i -0pe 's/# Enable defines if the API server should be enabled.\nenable = false/# Enable defines if the API server should be enabled.\nenable = true/' $APP_CONFIG
sed -i.bak "s/aevmos/$DENOM/g" $APP_CONFIG

# make sure the localhost IP is 0.0.0.0
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' "$CONFIG"
sed -i 's|^laddr = "tcp://127\.0\.0\.1:26657"|laddr = "tcp://0\.0\.0\.0:26657"|' "$CONFIG"
sed -i 's/127.0.0.1/0.0.0.0/g' "$APP_CONFIG"
sed -i 's/localhost/0.0.0.0/g' "$APP_CONFIG"

# pruning settings
# if pruning is defined
if [[ -z "${pruning}" ]]; then 
    pruning="--pruning=nothing"
else
    pruning=""
    sed -i 's/pruning = "default"/pruning = "custom"/g' "$APP_CONFIG"
    sed -i 's/pruning-keep-recent = "0"/pruning-keep-recent = "5"/g' "$APP_CONFIG"
    sed -i 's/pruning-interval = "0"/pruning-interval = "10"/g' "$APP_CONFIG"
fi

echo "running $CHAIN with extra flags $EXTRA_FLAGS"
echo "starting $CHAIN node in background ..."
echo "./"$CHAIND" start "$pruning" --rpc.unsafe --keyring-backend test --home "$DATA_DIR" "$EXTRA_FLAGS" >"$DATA_DIR"/node.log"
$CHAIND start --rpc.unsafe \
--json-rpc.enable true --api.enable \
--keyring-backend test --home $DATA_DIR --chain-id $CHAINID $EXTRA_FLAGS
