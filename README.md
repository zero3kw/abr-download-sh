# abr-download-sh
[![Daily S3 List](https://github.com/zero3kw/abr-download-sh/actions/workflows/daily_s3_list.yml/badge.svg)](https://github.com/zero3kw/abr-download-sh/actions/workflows/daily_s3_list.yml)

## 全国一括ダウンロード

### 町字位置参照（mt_town_pos）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_town_pos/pref/list.txt
" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```

### 住居表示-街区（mt_rsdtdsp_blk）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_rsdtdsp_blk/pref/list.txt
" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```

### 住居表示-街区位置参照（mt_rsdtdsp_blk_pos）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_rsdtdsp_blk_pos/pref/list.txt
" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```

### 住居表示-住居（mt_rsdtdsp_rsdt）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_rsdtdsp_rsdt/pref/list.txt
" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```

### 住居表示-住居位置参照（mt_rsdtdsp_rsdt_pos）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_rsdtdsp_rsdt_pos/pref/list.txt
" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```


### 地番（mt_parcel）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel/city/list.txt" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```

### 地番位置参照（mt_parcel_pos）

```bash
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel_pos/city/list.txt" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```

## 都道府県ごとのダウンロード

以下のスクリプトを使用して、特定の都道府県のデータのみをダウンロードすることができます。都道府県コードは先頭2桁で表されます（例：01は北海道、47は沖縄県）。

### 地番マスター（mt_parcel）

```bash
# 特定の都道府県の地番データをダウンロード（例：北海道[01]）
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel/city/list.txt" | awk -F "," 'NR > 1 && $1 ~ /mt_parcel_city01/ {print $1}' | xargs -P 0 -n 1 curl -s -O

# 特定の都道府県の地番データをダウンロード（例：東京都[13]）
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel/city/list.txt" | awk -F "," 'NR > 1 && $1 ~ /mt_parcel_city13/ {print $1}' | xargs -P 0 -n 1 curl -s -O
```

### 地番位置参照データ（mt_parcel_pos）

```bash
# 特定の都道府県の地番位置参照データをダウンロード（例：北海道[01]）
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel_pos/city/list.txt" | awk -F "," 'NR > 1 && $1 ~ /mt_parcel_pos_city01/ {print $1}' | xargs -P 0 -n 1 curl -s -O

# 特定の都道府県の地番位置参照データをダウンロード（例：東京都[13]）
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel_pos/city/list.txt" | awk -F "," 'NR > 1 && $1 ~ /mt_parcel_pos_city13/ {print $1}' | xargs -P 0 -n 1 curl -s -O
```

## 都道府県コード一覧

| コード | 都道府県 |
|--------|----------|
| 01 | 北海道 |
| 02 | 青森県 |
| 03 | 岩手県 |
| 04 | 宮城県 |
| 05 | 秋田県 |
| 06 | 山形県 |
| 07 | 福島県 |
| 08 | 茨城県 |
| 09 | 栃木県 |
| 10 | 群馬県 |
| 11 | 埼玉県 |
| 12 | 千葉県 |
| 13 | 東京都 |
| 14 | 神奈川県 |
| 15 | 新潟県 |
| 16 | 富山県 |
| 17 | 石川県 |
| 18 | 福井県 |
| 19 | 山梨県 |
| 20 | 長野県 |
| 21 | 岐阜県 |
| 22 | 静岡県 |
| 23 | 愛知県 |
| 24 | 三重県 |
| 25 | 滋賀県 |
| 26 | 京都府 |
| 27 | 大阪府 |
| 28 | 兵庫県 |
| 29 | 奈良県 |
| 30 | 和歌山県 |
| 31 | 鳥取県 |
| 32 | 島根県 |
| 33 | 岡山県 |
| 34 | 広島県 |
| 35 | 山口県 |
| 36 | 徳島県 |
| 37 | 香川県 |
| 38 | 愛媛県 |
| 39 | 高知県 |
| 40 | 福岡県 |
| 41 | 佐賀県 |
| 42 | 長崎県 |
| 43 | 熊本県 |
| 44 | 大分県 |
| 45 | 宮崎県 |
| 46 | 鹿児島県 |
| 47 | 沖縄県 |