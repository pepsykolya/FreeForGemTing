#!/usr/bin/env bash
# FFGT — see LICENSE
# Called by HiveOS with the flight sheet variables; writes the miner arguments to $CUSTOM_CONFIG_FILENAME.
#   Pool URL       (CUSTOM_URL)       crypto-connection.net:4073 (a Ting stratum pool) or an ffgt-gate (HOST:PORT on your LAN);
#                                     several URLs separated by spaces or commas = a failover list (the first is the primary);
#                                     node://127.0.0.1:18440 = solo on a Ting node on this rig (Extra config: --node-dir DIR)
#   Wallet/worker  (CUSTOM_TEMPLATE)  %WAL%.%WORKER_NAME%  (WAL = your Ting account, 64 hex digits)
#   Pass           (CUSTOM_PASS)      x for a pool; the rig's password for an ffgt-gate
#   Extra config   (CUSTOM_USER_CONFIG) e.g. --lock-cclock 1500 --auto-uv
cd "$(dirname "$0")"
. ./h-manifest.conf
urls=${CUSTOM_URL//,/ }
url=${urls%% *}
tpl=${CUSTOM_TEMPLATE:-}
wallet=${tpl%%.*}
worker=${WORKER_NAME:-rig}
[[ $tpl == *.* ]] && worker=${tpl#*.}
extra=${CUSTOM_USER_CONFIG:-}
[[ -z $url ]] && echo "ffgt: Pool URL is empty in the flight sheet" >&2
if [[ $url == node://* ]]; then
  echo "--node ${url#node://} $extra" > "$CUSTOM_CONFIG_FILENAME"
  exit 0
fi
[[ -z $wallet ]] && echo "ffgt: Wallet template is empty in the flight sheet" >&2
poolargs=
for u in $urls; do poolargs="$poolargs --pool $u"; done
echo "${poolargs# } --wallet $wallet --worker $worker --password ${CUSTOM_PASS:-x} $extra" > "$CUSTOM_CONFIG_FILENAME"
