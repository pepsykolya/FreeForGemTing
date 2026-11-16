# FFGT 0.2.0 — release notes (DRAFT, not published)

## English

First public release of **FFGT (FreeForGem Ting)**: a GPU miner for **Daler (DLR)** on the **Ting** blockchain.

**What it does**
- Mines DLR on crypto-connection.net (Ting stratum, ports 4073 / 4074), solo on your own Ting node (`--node`), or through
  **ffgt-gate** (several rigs → your nodes, each rig mapped to a node and its payout account).
- NVIDIA: CUDA, GTX 10 (sm_61) to RTX 50 (sm_120), including CMP cards. AMD and others: OpenCL.
- HiveOS custom miner `ffgt`, Windows (`start.bat`), Linux.
- Developer fee 1 % (one 60 s slot per 100 min, on crypto-connection.net).

**Measured** (pool mining, kernel t1p unless noted)

| GPU | Settings | GH/s | W | GH/J |
|---|---|---:|---:|---:|
| RTX 3070 ×4 (HiveOS) | lock 1500 + `--auto-uv` | 4.06–4.09 each, 16.3 total | 248 total | 0.066 |
| RTX 3070 | lock 1500, no undervolt | 4.06 | 99 | 0.041 |
| RTX 3070 (solo, kernel t1) | lock 1800 + `--auto-uv` (+165) | 5.14 | 128 | 0.040 |
| RTX 3070 (solo, kernel t1) | stock clocks (≈2100 MHz) | 5.98 | — | — |
| CMP 50HX ×5 (HiveOS) | locks 1500/1500/1200/1470/1470 + `--auto-uv` | 23.7–24.0 total; 5.0 @1500, 4.9 @1470, 4.0 @1200 | 544–557 total | 0.043 |
| RTX 4070 Laptop | stock | 5.0–5.2 | 90–100 | 0.052 |

Solo (direct node / gate solo blocks) uses kernel t1, about 4 % faster than the pool kernel t1p at the same clock (the
pool's extranonce fixes 4 nonce bytes the faster kernel would use). Hash rate scales linearly with the core clock
(RTX 3070 ≈ 2.85 MH/s per MHz).

Compared with the official ting-miner (wgpu): RTX 4070 Laptop 5.0 vs 2.04 GH/s; AMD Radeon iGPU 0.243 vs 0.125 GH/s.
The official GPU search does not start on HiveOS (no Vulkan driver library there); FFGT does not need Vulkan.

**Reliability (checked)**: every candidate re-hashed on the CPU before it is sent; injected GPU fault and a hung GPU call
→ the miner restarts itself and goes on; temperature limit; clock locks and undervolt put back on exit; solo dev-fee slot
survives a crash (the node's payout is restored at the next start).

**Known**: AMD undervolt is not wired yet (AMD mines at the card's own settings); `--auto-lock` takes several minutes per
lock (it measures each lock with its own undervolt).

**Antivirus**: VirusTotal flags the packages only with generic miner heuristics (Linux/HiveOS 2 of 62 engines:
"BitCoinMiner"/"BtcMine" tool; Windows 1 of 66: "CoinMiner") — the usual result for any GPU miner, not a trojan.

**Files**: `ffgt-0.2.0_hiveos.tar.gz` (HiveOS), `ffgt-0.2.0-linux-x86_64.tar.gz`, `ffgt-0.2.0-windows-x64.zip`,
`SHA256SUMS`.

## Русский

Первый публичный выпуск **FFGT (FreeForGem Ting)** — GPU-майнер **Daler (DLR)** в блокчейне **Ting**.

**Что умеет**
- Майнит DLR на crypto-connection.net (stratum Ting, порты 4073 / 4074), соло на своей ноде Ting (`--node`) или через
  **ffgt-gate** (несколько ригов → ваши ноды, каждый риг к своей ноде и её аккаунту выплат).
- NVIDIA: CUDA, от GTX 10 (sm_61) до RTX 50 (sm_120), включая CMP. AMD и другие: OpenCL.
- HiveOS (custom miner `ffgt`), Windows (`start.bat`), Linux.
- Комиссия разработчика 1 % (слот 60 с на каждые 100 мин, на crypto-connection.net).

**Замеры** — таблица выше (английская часть). Соло (нода напрямую / шлюз) — ядро t1, примерно на 4 % быстрее пулового
t1p на той же частоте. Хешрейт растёт линейно с частотой ядра (RTX 3070 ≈ 2,85 MH/s на МГц). Против официального
ting-miner (wgpu): RTX 4070 Laptop 5,0 против 2,04 GH/s; AMD Radeon iGPU 0,243 против 0,125. Официальный GPU-поиск в
HiveOS не запускается (нет Vulkan-библиотеки драйвера); FFGT Vulkan не нужен.

**Надёжность (проверено)**: каждый кандидат перепроверяется на CPU; сбой GPU и зависший вызов → майнер сам
перезапускается и продолжает; лимит температуры; локи и андервольт возвращаются при выходе; слот комиссии в соло
переживает сбой (payout ноды возвращается при следующем запуске).

**Антивирусы**: VirusTotal отмечает пакеты только общей эвристикой майнера (Linux/HiveOS — 2 из 62, Windows — 1 из 66,
«CoinMiner/BtcMine») — обычное дело для любого GPU-майнера, это не троян.

**Известное**: андервольт для AMD пока не подключён; `--auto-lock` тратит несколько минут на каждый лок (меряет каждый со
своим андервольтом).
