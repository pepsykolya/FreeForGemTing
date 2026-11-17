# FFGT on HiveOS / FFGT в HiveOS

FFGT (FreeForGem Ting) mines **Daler (DLR)** on the **Ting** blockchain on NVIDIA (GTX 10 and newer, incl. CMP) and AMD
(OpenCL) GPUs. Developer fee 1 %.

- [English](#english)
- [Русский](#русский)

---

## English

### 1. You need

- A Ting account (64 hex characters) to receive DLR: create it with the Ting ID Android app (it is not in Google Play: install
  `Ting-ID.apk` from [ting-id releases](https://github.com/ting-organization/ting-id/releases)), with the web wallet
  [wallet.ting-project.com](https://wallet.ting-project.com), or with `ting wallet create` of
  [ting-miner](https://github.com/ting-organization/ting-miner). In Ting ID / the web wallet use the **Spending** account — only the 64 hex characters, without `&net=…` that the app adds to a shared address —
  (Receive) and add the 12-word recovery phrase in Identity (it becomes active after 7 days). A `ting wallet create` account
  is a `wallet.json` file with a password (no phrase; keep both safe — nobody can restore them); it cannot be imported into
  Ting ID or the web wallet, its DLR are sent only with `ting wallet send` through a node. To use
  [Ting Swap](https://ting-organization.github.io/ting-swap/) (DLR ↔ LTC atomic swap, early testing) you need Ting ID or
  the web wallet.
- HiveOS with an NVIDIA driver (any recent one) or an AMD driver with OpenCL.

### 2. Flight sheet

Create a new flight sheet: **Coin** — write `DLR` (any name; HiveOS does not know the coin), **Wallet** — your Ting
account, **Pool** — "Configure in miner", **Miner** — "Custom", then *Setup Miner Config*:

| Field | Value |
|---|---|
| Miner name | `ffgt` (filled in automatically from the URL) |
| Installation URL | `<link to ffgt-VERSION_hiveos.tar.gz>` |
| Hash algorithm | leave empty (`----`): HiveOS has no Ting algorithm in its list, the miner reports it by itself |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `crypto-connection.net:4073` (GPUs) or `crypto-connection.net:4074` (farms, higher start difficulty) |
| Pass | `x` |
| Extra config arguments | see below |

Several pool URLs separated by commas are a failover list: the first is the primary, the miner returns to it after 10 min
on a backup.

**Extra config arguments** (examples):

| Card | Recommended |
|---|---|
| RTX 3070 / 3060 Ti / 3080 | `--lock-cclock 1500 --auto-uv` (best GH/W) |
| any NVIDIA, max speed | nothing (stock clocks) |
| CMP 50HX / 90HX | `--lock-cclock 1500 --auto-uv` (1470 is a bit more efficient) |
| RTX 20xx (Turing) | `--lock-cclock 1500 --auto-uv` (0.2.1 caps the undervolt at +225 on Turing by itself; with 0.2.0 add `--uv-max 225` and `--lock-mclock 810`) |
| AMD | nothing (`--backend opencl` is chosen automatically when there is no NVIDIA GPU) |

**Memory lock is automatic (0.2.1)**: on NVIDIA the miner locks the video memory at the lowest clock that keeps the full
core clock range (810 MHz on an RTX 3070). SHA-256 does not use the video memory, so the hash rate stays the same and the
card draws less: RTX 3070 at a 1800 lock + `--auto-uv` 129 → 115.5 W at the same 5.14 GH/s. It is skipped when you set
`--lock-mclock` / `--moffset` yourself or the HiveOS OC profile locks the memory; `--no-mem-lock` leaves the memory alone.

Flags set here win over the HiveOS OC profile (a locked clock in the miner is re-applied if HiveOS changes it), and every
clock / offset is put back when the miner stops.

### 3. Solo through ffgt-gate (your own Ting node)

If you run a Ting node with `ffgt --gate gate.json` beside it, set **Pool URL** = `GATE-IP:4173`, **Wallet template** =
`%WORKER_NAME%` (anything works), **Pass** = the rig's gate password. The blocks pay the payout account of the node the gate
maps this rig to (`ting miner payout <account>` on that node).

### 4. Expected hash rate (measured)

| GPU | Settings | GH/s | W | GH/W |
|---|---|---:|---:|---:|
| RTX 3070 | lock 1500 + `--auto-uv` (HiveOS, 4 cards) | 4.06–4.09 | 58–67 | 0.066 |
| RTX 3070 | lock 1500, no undervolt | 4.06 | 99 | 0.041 |
| RTX 3070 | stock (≈2100 MHz) | 5.98 | ≈158 | 0.038 |
| CMP 50HX | lock 1500 + `--auto-uv` (HiveOS, 5 cards) | 5.0 | 119–123 | 0.042 |
| CMP 50HX | lock 1470 + `--auto-uv` | 4.9 | 102–109 | 0.046 |
| CMP 50HX | lock 1800 + `--auto-uv` (max speed; offset limited by the voltage floor) | 6.0–6.15 | 171–195 | 0.033 |
| RTX 4070 Laptop | stock | 5.0–5.2 | 90–100 | 0.052 |

Pool mining (kernel t1p); solo through a node or ffgt-gate is about 4 % faster at the same clock (kernel t1). Hash rate
grows linearly with the core clock; the undervolt (`--auto-uv`) saves 30–40 % of the power at the same hash rate.
For comparison, the official ting-miner (wgpu) does 2.04 GH/s on an RTX 4070 Laptop where FFGT does 5.0, and its GPU
search does not run on HiveOS at all (no Vulkan driver library there).

### 5. Check

- HiveOS shows the hash rate in GH/s (as kH/s × 10⁶ internally), accepted / rejected shares and the efficiency next to
  the version (`0.2.1 0.0610 GH/W`).
- Miner log: `miner log` or `/var/log/miner/ffgt/ffgt.log`; the line every 10 s:
  `[ 60s] GPU0 4.273 (70 W, 0.0610 GH/W) ... | total ... | user sub 9 acc 9 rej 0 ... | fee sub 0 acc 0 rej 0`.
- Pool statistics: `https://crypto-connection.net` → Daler → your account. Minimum payout 100 DLR, after 30 confirmations.
- Local API on the rig: `curl 127.0.0.1:4068/summary` (`/gpus`, `/metrics`).

---

## Русский

### 1. Что нужно

- Аккаунт Ting (64 шестнадцатеричных символа), на который придут DLR: создаётся в Android-приложении Ting ID (в Google Play его нет:
  `Ting-ID.apk` — на странице [релизов ting-id](https://github.com/ting-organization/ting-id/releases)), в веб-кошельке
  [wallet.ting-project.com](https://wallet.ting-project.com) или командой `ting wallet create` из
  [ting-miner](https://github.com/ting-organization/ting-miner). В Ting ID и веб-кошельке берите счёт **Spending** (кнопка
  Receive) — только 64 символа, без хвоста `&net=…`, и сразу добавьте фразу из 12 слов во вкладке Identity (она начинает действовать через 7 дней). Аккаунт от
  `ting wallet create` — это файл `wallet.json` с паролем (фразы нет; храните оба надёжно — восстановить нельзя); в Ting ID и
  веб-кошелёк он не импортируется, его DLR отправляются только командой `ting wallet send` через ноду. Для обмена в
  [Ting Swap](https://ting-organization.github.io/ting-swap/) (атомарный своп DLR ↔ LTC, ранняя версия) нужен Ting ID или
  веб-кошелёк.
- HiveOS с драйвером NVIDIA (любой свежий) или AMD с OpenCL.

### 2. Полётный лист (Flight sheet)

Новый полётный лист: **Coin** — впишите `DLR` (любое название, HiveOS монету не знает), **Wallet** — ваш аккаунт Ting,
**Pool** — «Configure in miner», **Miner** — «Custom», затем *Setup Miner Config*:

| Поле | Значение |
|---|---|
| Miner name | `ffgt` (подставится сам по ссылке) |
| Installation URL | `<ссылка на ffgt-ВЕРСИЯ_hiveos.tar.gz>` |
| Hash algorithm | оставить пустым (`----`): алгоритма Ting в списке HiveOS нет, майнер сообщает его сам |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `crypto-connection.net:4073` (видеокарты) или `crypto-connection.net:4074` (фермы, выше стартовая сложность) |
| Pass | `x` |
| Extra config arguments | см. ниже |

Несколько адресов пула через запятую — резервный список: первый основной, на него майнер возвращается через 10 мин работы
на резервном.

**Extra config arguments** (примеры):

| Карта | Рекомендация |
|---|---|
| RTX 3070 / 3060 Ti / 3080 | `--lock-cclock 1500 --auto-uv` (лучшие GH/W) |
| любая NVIDIA, максимум скорости | ничего (стоковые частоты) |
| CMP 50HX / 90HX | `--lock-cclock 1500 --auto-uv` (1470 чуть экономичнее) |
| RTX 20xx (Turing) | `--lock-cclock 1500 --auto-uv` (0.2.1 сам ограничивает андервольт на Turing до +225; в 0.2.0 добавьте `--uv-max 225` и `--lock-mclock 810`) |
| AMD | ничего (`--backend opencl` выбирается сам, если NVIDIA нет) |

**Лок памяти — автоматически (0.2.1)**: на NVIDIA майнер лочит видеопамять на самой низкой частоте, при которой карта
сохраняет полный диапазон частот ядра (на RTX 3070 — 810 МГц). SHA-256 видеопамять не использует, поэтому хешрейт тот же,
а мощность ниже: RTX 3070 на локе 1800 + `--auto-uv` 129 → 115,5 Вт при тех же 5,14 GH/s. Не ставится, если вы сами
задали `--lock-mclock` / `--moffset` или память лочит OC-профиль HiveOS; `--no-mem-lock` — память не трогать.

Флаги майнера главнее OC-профиля HiveOS (лок частоты возвращается, если HiveOS его поменял); все частоты и оффсеты
возвращаются как были при остановке майнера.

### 3. Соло через ffgt-gate (своя нода Ting)

Если рядом с вашей нодой Ting запущен `ffgt --gate gate.json`: **Pool URL** = `IP-ШЛЮЗА:4173`, **Wallet template** =
`%WORKER_NAME%` (подойдёт что угодно), **Pass** = пароль этого рига в шлюзе. Блоки платят на payout-аккаунт той ноды, к
которой шлюз привязал риг (`ting miner payout <аккаунт>` на этой ноде).

### 4. Ожидаемый хешрейт (замеры)

| GPU | Настройки | GH/s | Вт | GH/W |
|---|---|---:|---:|---:|
| RTX 3070 | лок 1500 + `--auto-uv` (HiveOS, 4 карты) | 4,06–4,09 | 58–67 | 0,066 |
| RTX 3070 | лок 1500, без андервольта | 4,06 | 99 | 0,041 |
| RTX 3070 | сток (≈2100 МГц) | 5,98 | ≈158 | 0,038 |
| CMP 50HX | лок 1500 + `--auto-uv` (HiveOS, 5 карт) | 5,0 | 119–123 | 0,042 |
| CMP 50HX | лок 1470 + `--auto-uv` | 4,9 | 102–109 | 0,046 |
| CMP 50HX | лок 1800 + `--auto-uv` (максимум скорости; оффсет упирается в минимум напряжения) | 6,0–6,15 | 171–195 | 0,033 |
| RTX 4070 Laptop | сток | 5,0–5,2 | 90–100 | 0,052 |

Майнинг в пул (ядро t1p); соло через ноду или ffgt-gate примерно на 4 % быстрее на той же частоте (ядро t1). Хешрейт растёт
линейно с частотой ядра; андервольт (`--auto-uv`) экономит 30–40 % мощности при том же хешрейте.
Для сравнения: официальный ting-miner
(wgpu) на RTX 4070 Laptop даёт 2,04 GH/s против 5,0 у FFGT, а в HiveOS его GPU-поиск не запускается вовсе (нет
Vulkan-библиотеки драйвера).

### 5. Проверка

- HiveOS показывает хешрейт в GH/s, принятые/отклонённые шары и эффективность рядом с версией (`0.2.1 0.0610 GH/W`).
- Лог майнера: `miner log` или `/var/log/miner/ffgt/ffgt.log`; строка раз в 10 с:
  `[ 60s] GPU0 4.273 (70 W, 0.0610 GH/W) ... | total ... | user sub 9 acc 9 rej 0 ... | fee sub 0 acc 0 rej 0`.
- Статистика пула: `https://crypto-connection.net` → Daler → ваш аккаунт. Минимальная выплата 100 DLR, после 30 подтверждений.
- Локальный API на риге: `curl 127.0.0.1:4068/summary` (`/gpus`, `/metrics`).
