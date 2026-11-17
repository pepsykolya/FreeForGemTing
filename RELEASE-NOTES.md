# FFGT — release notes

# FFGT 0.2.1

## English

Fixes and power saving on top of 0.2.0.

- **Memory lock by default (NVIDIA)**: the miner locks the video memory at the lowest clock that keeps the full core clock
  range (SHA-256 does not use the video memory). RTX 3070, lock 1800 + `--auto-uv`, solo: **128.9 W → 115.5 W at the same
  5.14 GH/s** (memory 810 MHz instead of 6801), about −10 % power. Not applied with `--lock-mclock` / `--moffset`, or when
  the HiveOS OC profile locks the memory; `--no-mem-lock` leaves the memory alone. The old advice `--lock-mclock 810` is
  no longer needed.
- **`--auto-uv` ceiling per card type** instead of +495 for every card: Turing (RTX 20, GTX 16) +225, CMP 50HX +330,
  CMP 30HX / 40HX +150, other cards +495. In 0.2.0 the tuner could take an RTX 2060 SUPER to +260 and crash the driver
  (with 0.2.0 use `--uv-max 225` on Turing).
- **Wallet**: a `&net=…` tail (the Ting ID app copies the account with it) and a `ting:` prefix are cut off. With the
  tail the pool closed the connection and the miner showed 0 GH/s.
- **CPU**: GPU threads sleep while the GPU computes (blocking sync) instead of spinning: ~98 % → ~1 % of a CPU core
  per GPU at the same hash rate (a 2-core rig with 12 GPUs was at 100 % CPU); `FFGT_SPIN=1` restores spinning.
- Efficiency is shown in **GH/W** everywhere (HiveOS stats, log, API).
- Docs: Ting ID — APK from GitHub (not in Google Play) and the web wallet wallet.ting-project.com; the HiveOS
  "Hash algorithm" field stays empty; memory lock and Turing rows.

**Files**: `ffgt-0.2.1_hiveos.tar.gz` (HiveOS), `ffgt-0.2.1-linux-x86_64.tar.gz`, `ffgt-0.2.1-windows-x64.zip`,
`SHA256SUMS`. HiveOS install URL:
`https://github.com/pepsykolya/FreeForGemTing/releases/download/v0.2.1/ffgt-0.2.1_hiveos.tar.gz`

## Русский

Исправления и экономия мощности поверх 0.2.0.

- **Лок памяти по умолчанию (NVIDIA)**: майнер лочит видеопамять на самой низкой частоте, при которой карта сохраняет
  полный диапазон частот ядра (SHA-256 видеопамять не использует). RTX 3070, лок 1800 + `--auto-uv`, соло: **128,9 Вт →
  115,5 Вт при тех же 5,14 GH/s** (память 810 МГц вместо 6801), около −10 % мощности. Не ставится при `--lock-mclock` /
  `--moffset` или если память лочит OC-профиль HiveOS; `--no-mem-lock` — память не трогать. Совет `--lock-mclock 810`
  больше не нужен.
- **Потолок `--auto-uv` по типу карты** вместо +495 для всех: Turing (RTX 20, GTX 16) +225, CMP 50HX +330, CMP 30HX /
  40HX +150, остальные +495. В 0.2.0 подбор мог довести RTX 2060 SUPER до +260 и уронить драйвер (в 0.2.0 на Turing —
  `--uv-max 225`).
- **Кошелёк**: хвост `&net=…` (так адрес копирует Ting ID) и префикс `ting:` отрезаются. С хвостом пул рвал соединение,
  майнер показывал 0 GH/s.
- **CPU**: потоки GPU спят, пока карта считает (blocking sync), а не крутятся в ожидании: ~98 % → ~1 % ядра CPU на
  карту при том же хешрейте (риг на 2-ядерном CPU с 12 картами был загружен на 100 %); `FFGT_SPIN=1` — вернуть старое.
- Эффективность везде в **GH/W** (статистика HiveOS, лог, API).
- Доки: Ting ID — APK с GitHub (в Google Play нет) и веб-кошелёк wallet.ting-project.com; поле «Hash algorithm» в HiveOS
  оставлять пустым; строки про лок памяти и Turing.

# FFGT 0.2.0

## English

First public release of **FFGT (FreeForGem Ting)**: a GPU miner for **Daler (DLR)** on the **Ting** blockchain.

**What it does**
- Mines DLR on crypto-connection.net (Ting stratum, ports 4073 / 4074), solo on your own Ting node (`--node`), or through
  **ffgt-gate** (several rigs → your nodes, each rig mapped to a node and its payout account).
- NVIDIA: CUDA, GTX 10 (sm_61) to RTX 50 (sm_120), including CMP cards. AMD and others: OpenCL.
- HiveOS custom miner `ffgt`, Windows (`start.bat`), Linux.
- Developer fee 1 % (one 60 s slot per 100 min, on crypto-connection.net).

**Measured** (pool mining, kernel t1p unless noted)

| GPU | Settings | GH/s | W | GH/W |
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
