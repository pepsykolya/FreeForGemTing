#!/usr/bin/env bash
# FFGT — see LICENSE
# Sourced by the HiveOS agent: sets $khs (total, kH/s) and $stats (JSON) from the miner's periodic log line
#   [  60s] GPU0 5.128 (102 W, 0.0503 GH/W)  GPU1 ... | total 10.256 GH/s, 204 W, 0.0503 GH/W | candidates .. | user sub 9 acc 9 rej 0 ... | fee sub ..
_ffgt_dir=$(dirname "${BASH_SOURCE[0]}")
. "$_ffgt_dir/h-manifest.conf"
_log="${CUSTOM_LOG_BASENAME}.log"
_line=$(tail -n 400 "$_log" 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -aE ' total [0-9.]+ GH/s' | tail -n 1)
_age=$(( $(date +%s) - $(stat -c %Y "$_log" 2>/dev/null || echo 0) ))
if [[ -z $_line || $_age -gt 60 ]]; then
  khs=0
  stats=null
else
  mapfile -t _ids < <(grep -oP 'GPU\K[0-9]+(?= [0-9.]+)' <<< "$_line")
  mapfile -t _ghs < <(grep -oP 'GPU[0-9]+ \K[0-9.]+' <<< "$_line")
  _total=$(grep -oP 'total \K[0-9.]+' <<< "$_line")
  _up=$(grep -oP '^\[\s*\K[0-9]+' <<< "$_line")
  _acc=$(grep -oP 'user sub [0-9]+ acc \K[0-9]+' <<< "$_line")
  _rej=$(grep -oP 'user sub [0-9]+ acc [0-9]+ rej \K[0-9]+' <<< "$_line")
  mapfile -t _bus  < <(nvidia-smi --query-gpu=pci.bus --format=csv,noheader 2>/dev/null)
  mapfile -t _temp < <(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
  mapfile -t _fan  < <(nvidia-smi --query-gpu=fan.speed --format=csv,noheader,nounits 2>/dev/null)
  _hs=(); _b=(); _t=(); _f=()
  for i in "${!_ids[@]}"; do
    d=${_ids[$i]}
    _hs+=("$(awk -v x="${_ghs[$i]}" 'BEGIN{printf "%.0f", x*1e6}')")
    _b+=("$(( ${_bus[$d]:-0} ))")
    _t+=("${_temp[$d]:-0}")
    f=${_fan[$d]:-0}; [[ $f =~ ^[0-9]+$ ]] || f=0; _f+=("$f")
  done
  _eff=$(grep -oP 'total .*?\K[0-9.]+ GH/W' <<< "$_line" | head -n 1)
  _ver=$CUSTOM_VERSION; [[ -n $_eff ]] && _ver="$CUSTOM_VERSION ${_eff/GH\/W/GH\/J}"
  khs=$(awk -v x="${_total:-0}" 'BEGIN{printf "%.0f", x*1e6}')
  stats=$(jq -nc \
    --argjson hs "$(printf '%s\n' "${_hs[@]}" | jq -sc .)" \
    --argjson temp "$(printf '%s\n' "${_t[@]}" | jq -sc .)" \
    --argjson fan "$(printf '%s\n' "${_f[@]}" | jq -sc .)" \
    --argjson bus "$(printf '%s\n' "${_b[@]}" | jq -sc .)" \
    --arg ver "$_ver" --argjson up "${_up:-0}" --argjson acc "${_acc:-0}" --argjson rej "${_rej:-0}" \
    '{hs: $hs, hs_units: "khs", temp: $temp, fan: $fan, uptime: $up, ver: $ver, ar: [$acc, $rej], algo: "ting", bus_numbers: $bus}')
fi
