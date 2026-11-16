#!/usr/bin/env bash
# FFGT — see LICENSE
cd "$(dirname "$0")"
. ./h-manifest.conf
[[ -f $CUSTOM_CONFIG_FILENAME ]] || { echo "No config file $CUSTOM_CONFIG_FILENAME"; exit 1; }
mkdir -p "$(dirname "$CUSTOM_LOG_BASENAME")"
# --auto-uv / --auto-lock results and the crash-recovery files live in /hive-config (survive miner updates and reboots)
[[ -d /hive-config ]] && export FFGP_STATE_DIR=${FFGP_STATE_DIR:-/hive-config/ffgt}
# GPU numbering in PCI bus order, the same as nvidia-smi and the HiveOS dashboard
export CUDA_DEVICE_ORDER=PCI_BUS_ID
[[ -z ${NO_COLOR:-} ]] && export FFG_COLOR=${FFG_COLOR:-1}
set -f
CFG="$(< "$CUSTOM_CONFIG_FILENAME")"
# tee -i: `miner stop` sends SIGINT to the pipeline; tee outlives the miner so its shutdown (clocks and offsets put back) is logged
./ffgt $CFG 2>&1 | tee -i --append "${CUSTOM_LOG_BASENAME}.log"
