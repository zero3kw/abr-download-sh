# abr-download-sh

[![Daily S3 List](https://github.com/zero3kw/abr-download-sh/actions/workflows/daily_s3_list.yml/badge.svg)](https://github.com/zero3kw/abr-download-sh/actions/workflows/daily_s3_list.yml)

# Download Command
```
# 地番データを全国分ダウンロード
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel/city/list.txt" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O

# 地番位置参照データを全国分ダウンロード
curl -s "https://raw.githubusercontent.com/zero3kw/abr-download-sh/refs/heads/main/gov-csv-export-public/mt_parcel_pos/city/list.txt" | awk -F "," 'NR > 1 {print $1}' | xargs -P 0 -n 1 curl -s -O
```