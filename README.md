# FFGT — FreeForGem Ting

GPU miner for **Daler (DLR)** on the **Ting** blockchain (SHA-256 over Ting's tagged block header, 16-byte nonce).
NVIDIA (CUDA, GTX 10 / sm_61 and newer, incl. CMP) and AMD (OpenCL). Linux, HiveOS, Windows. Developer fee **1 %**.

[Русский — ниже](#ffgt--русский)

## Highlights

- Fast closed-source kernels (one SHA-256 compression per nonce from a midstate, rounds 0..11 folded on the host):
  RTX 3070 ≈ 4.3 GH/s at a 1500 MHz lock, ≈ 6.0 GH/s at stock; RTX 4070 Laptop ≈ 5.0 GH/s — 2.5× the official wgpu
  miner on the same card. Every candidate is re-checked on the CPU before it is sent.
- Pools: crypto-connection.net (Ting stratum), failover list with return to the primary.
- Solo: directly on your own Ting node (`--node`), or several rigs through **ffgt-gate** — each rig mapped to a node and
  its payout account; the node's control token never leaves the node's machine.
- The FreeForGem toolbox: clock locks that win over the HiveOS OC profile and are put back on exit, automatic undervolt
  per GPU and lock (`--auto-uv`, every step checked by a separate process), automatic lock choice (`--auto-lock`),
  temperature limit, recovery after a GPU fault or a hung GPU call, per-GPU settings, local API.

## Quick start

| Where | How |
|---|---|
| HiveOS | see [HIVEOS-ffgt.md](HIVEOS-ffgt.md) |
| Windows | unpack the zip, edit `start.bat` (your Ting account), run it |
| Linux | `./ffgt --pool crypto-connection.net:4073 --wallet <ACCOUNT>.<worker>` |
| Solo, own node | `./ffgt --node 127.0.0.1:18440 --node-dir <the node's data directory>` |
| Rigs via gate | on the node's machine: `./ffgt --gate gate.json`; on the rigs: `--pool GATE:4173 --wallet any.<rig> --password <rig password>` |

A Ting account is 64 hex characters: Ting ID Android app (APK from https://github.com/ting-organization/ting-id/releases, not in Google Play), the web wallet https://wallet.ting-project.com, or `ting wallet create` of
[ting-miner](https://github.com/ting-organization/ting-miner). Solo blocks pay the node's
`ting miner payout <account>`.

## Options

```
--pool A[,B]            Ting stratum pool(s) or an ffgt-gate; --wallet ACCOUNT.worker; --password x
--node HOST:PORT        solo on a Ting node's control channel (loopback); --node-dir DIR | --node-token-file FILE
--gate CONFIG.json      run ffgt-gate (see below)
--devices 0,2           GPUs (default all, nvidia-smi numbering);  --backend cuda|opencl
--lock-cclock MHz       core lock (one value or one per GPU);  --lock-mclock MHz;  --moffset MHz
--auto-uv               undervolt tuner (profiles per GPU and lock);  --uv-offset N;  --uv-reset / --uv-reset-all
--auto-lock             choose the lock by measurement;  --auto-lock-range 1650,1500,1350
--temp-limit C          slow a GPU down above C;  --temp-stop C
--failback-minutes M    return to the first pool after M minutes on a backup (default 10, 0 = off)
--api-port N            local API (default 4068, 0 = off): /summary /gpus /metrics
--self-test             GPU kernels against the CPU;  --hash-bench S  speed test;  --minutes M  stop after M minutes
```

## ffgt-gate

Runs beside one or more Ting nodes and serves the rigs with the same stratum as the pool. Example `gate.json`:

```json
{ "listen": ["192.168.0.10:4173"],
  "difficulty": 4,
  "nodes":   { "main": {"control": "127.0.0.1:18440", "token_file": "/var/lib/ting/control.token"} },
  "workers": { "rig01": {"node": "main", "password": "a-long-random-secret"},
               "rig02": {"node": "main", "password": "another-secret"} },
  "api": "127.0.0.1:4180" }
```

Run it as a user that can read `control.token` (e.g. a group with read access), bind it to a LAN / VPN address only.
`GET /summary` on the API address shows workers (shares, estimated hash rate, blocks) and nodes.

## Developer fee

1 %: one 60-second slot per 100 minutes of mining, on crypto-connection.net under the developer's account. Solo without
access to that pool: the node's blocks pay the developer for the slot, then your payout is put back (a marker file makes a
crash during the slot safe: the next start puts your payout back first).

## License

FFGT License (see `LICENSE`): the host program is free to use, modify and redistribute; the GPU library is binary-only.

---

# FFGT — русский

GPU-майнер **Daler (DLR)** в блокчейне **Ting**. NVIDIA (CUDA, от GTX 10 / sm_61, в т.ч. CMP) и AMD (OpenCL). Linux,
HiveOS, Windows. Комиссия разработчика **1 %**.

## Главное

- Быстрые закрытые ядра: RTX 3070 ≈ 4,3 GH/s на локе 1500 МГц, ≈ 6,0 GH/s на стоке; RTX 4070 Laptop ≈ 5,0 GH/s — в 2,5 раза
  быстрее официального wgpu-майнера на той же карте. Каждый кандидат перепроверяется на CPU перед отправкой.
- Пулы: crypto-connection.net, резервный список с возвратом на основной.
- Соло: напрямую на свою ноду Ting (`--node`) или несколько ригов через **ffgt-gate** — каждый риг к своей ноде и её
  аккаунту выплат; токен управления нодой не покидает её машину.
- Набор FreeForGem: локи частот главнее OC-профиля HiveOS и возвращаются при выходе, автоандервольт по карте и локу
  (`--auto-uv`, каждый шаг проверяется отдельным процессом), автовыбор лока (`--auto-lock`), лимит температуры,
  восстановление после сбоя GPU или зависшего вызова, настройки по картам, локальный API.

## Быстрый старт

| Где | Как |
|---|---|
| HiveOS | см. [HIVEOS-ffgt.md](HIVEOS-ffgt.md) |
| Windows | распаковать zip, вписать свой аккаунт Ting в `start.bat`, запустить |
| Linux | `./ffgt --pool crypto-connection.net:4073 --wallet <АККАУНТ>.<воркер>` |
| Соло на своей ноде | `./ffgt --node 127.0.0.1:18440 --node-dir <папка данных ноды>` |
| Риги через шлюз | на машине с нодой: `./ffgt --gate gate.json`; на ригах: `--pool ШЛЮЗ:4173 --wallet any.<риг> --password <пароль рига>` |

Аккаунт Ting — 64 шестнадцатеричных символа: Android-приложение Ting ID (APK с https://github.com/ting-organization/ting-id/releases, в Google Play его нет), веб-кошелёк https://wallet.ting-project.com или `ting wallet create` из
[ting-miner](https://github.com/ting-organization/ting-miner). Соло-блоки платят на `ting miner payout <аккаунт>` ноды.

Опции и пример `gate.json` — выше (английская часть); комиссия: 1 % — слот 60 с на каждые 100 мин майнинга на
crypto-connection.net под аккаунтом разработчика; в соло без доступа к этому пулу на время слота блоки ноды платят
разработчику, затем ваш payout возвращается (файл-маркер защищает от сбоя посреди слота: следующий запуск сначала вернёт
ваш payout).
