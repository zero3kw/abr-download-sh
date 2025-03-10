#!/bin/bash

###############################################################################
# function errecho
#
# 標準エラー出力にメッセージを出力する関数
###############################################################################
function errecho() {
  printf "%s\n" "$*" 1>&2
}

###############################################################################
# function list_items_in_bucket
#
# S3のパブリックバケットから、指定されたプレフィックス以下のオブジェクトを全件取得
#
# Parameters:
#       $1 - バケットURL
#       $2 - (Optional) プレフィックス
#       $3 - (Optional) 出力ディレクトリ
#
# Returns:
#       バケット内の全ファイル一覧
###############################################################################
function list_items_in_bucket() {
  local bucket_url=$1
  local prefix=${2:-""}
  local output_dir=${3:-"s3_structure"}
  local continuation_token=""
  local tmp_list=$(mktemp)

  # CSVヘッダーを追加
  echo "Key,LastModified,ETag,Size" > "$tmp_list"

  # 現在のプレフィックス用のディレクトリを作成
  if [[ -n "$prefix" ]]; then
    local dir_path="${output_dir}/${prefix%/}"
    mkdir -p "$dir_path"
  fi

  while :; do
    # リクエストURLの作成
    local request_url="${bucket_url}/?list-type=2&delimiter=/&max-keys=1000"
    if [[ -n "$prefix" ]]; then
      request_url="${request_url}&prefix=${prefix}"
    fi
    if [[ -n "$continuation_token" ]]; then
      # continuation-tokenはURLエンコードが必要
      encoded_token=$(echo -n "$continuation_token" | jq -sRr @uri)
      request_url="${request_url}&continuation-token=${encoded_token}"
    fi

    echo "Fetching: $request_url"

    # curl で S3 のオブジェクト一覧を取得
    response=$(curl -s "$request_url")

    # エラーチェック
    if [[ $? -ne 0 ]]; then
      errecho "ERROR: Failed to fetch data from S3."
      rm -f "$tmp_list"
      return 1
    fi

    # ファイルとプレフィックスを別々に抽出（名前空間を考慮）
    local contents=$(echo "$response" | xmllint --nowarning --xpath "//*[local-name()='Contents']" - 2>/dev/null || echo "")
    local prefixes=$(echo "$response" | xmllint --nowarning --xpath "//*[local-name()='CommonPrefixes']/*[local-name()='Prefix']/text()" - 2>/dev/null || echo "")
    local is_truncated=$(echo "$response" | xmllint --nowarning --xpath "//*[local-name()='IsTruncated']/text()" - 2>/dev/null || echo "false")
    local next_token=$(echo "$response" | xmllint --nowarning --xpath "//*[local-name()='NextContinuationToken']/text()" - 2>/dev/null || echo "")

    # ファイル情報を抽出してCSVに追加
    if [[ -n "$contents" ]]; then
      echo "$contents" | while read -r content; do
        # XMLから<Key>、<LastModified>、<ETag>、<Size>の値を一度に取得
        # concatでパイプ区切りの1行の文字列として結合
        local parsed_data=$(echo "$content" | xmllint --nowarning --xpath "concat(
          //*[local-name()='Key']/text(), '|',
          //*[local-name()='LastModified']/text(), '|',
          //*[local-name()='ETag']/text(), '|',
          //*[local-name()='Size']/text()
        )" - 2>/dev/null)

        # パイプ区切りの文字列を各変数に分割
        # key: オブジェクトのパス
        # last_modified: 最終更新日時（ISO 8601形式）
        # etag: オブジェクトのハッシュ値
        # size: ファイルサイズ（バイト）
        IFS='|' read -r key last_modified etag size <<< "$parsed_data"

        if [[ -n "$key" && ! "$key" =~ /$ ]]; then
          # S3のフルURLを構築（バケットURL + オブジェクトキー）
          local full_key="${bucket_url}/${key}"
          # ETagからダブルクォートを除去（S3の応答形式に合わせる）
          etag=$(echo "$etag" | sed 's/^"//;s/"$//')
          echo "${full_key},${last_modified},${etag},${size}" >> "$tmp_list"
        fi
      done
    fi

    # プレフィックスを再帰的に処理
    if [[ -n "$prefixes" ]]; then
      echo "$prefixes" | while read -r new_prefix; do
        if [[ -n "$new_prefix" && "$new_prefix" != "$prefix" ]]; then
          echo "Processing prefix: $new_prefix"
          list_items_in_bucket "$bucket_url" "$new_prefix" "$output_dir"
        fi
      done
    fi

    echo "=== Pagination Info ==="
    echo "IsTruncated: $is_truncated"
    echo "NextContinuationToken: $next_token"
    echo "Current file count: $(($(wc -l < "$tmp_list") - 1))"
    echo "==================="

    # ページネーションが終了したらループを抜ける
    if [[ "$is_truncated" != "true" ]] || [[ -z "$next_token" ]]; then
      break
    fi

    continuation_token="$next_token"
  done

  # 最終的なファイルリストを出力
  if [[ -s "$tmp_list" && $(wc -l < "$tmp_list") -gt 1 ]]; then
    if [[ -n "$prefix" ]]; then
      cat "$tmp_list" > "${output_dir}/${prefix%/}/list.txt"
      echo "Created: ${output_dir}/${prefix%/}/list.txt with $(($(wc -l < "$tmp_list") - 1)) files"
    else
      cat "$tmp_list" > "${output_dir}/list.txt"
      echo "Created: ${output_dir}/list.txt with $(($(wc -l < "$tmp_list") - 1)) files"
    fi
  fi

  # 一時ファイルを削除
  rm -f "$tmp_list"
}

###############################################################################
# function create_directory_structure
#
# S3バケットの階層構造を作成し、各階層ごとにlist.txtファイルを生成する
#
# Parameters:
#       $1 - バケットURL
#       $2 - (Optional) ルートプレフィックス
#       $3 - (Optional) 出力ディレクトリ
###############################################################################
function create_directory_structure() {
  local bucket_url=$1
  local root_prefix=${2:-""}
  local output_dir=${3:-"s3_structure"}

  echo "バケット構造を解析中: ${bucket_url}"
  echo "ルートプレフィックス: ${root_prefix}"
  echo "出力ディレクトリ: ${output_dir}"

  # 出力ディレクトリが存在しなければ作成
  mkdir -p "${output_dir}"

  # バケット内のアイテムを取得して処理
  list_items_in_bucket "${bucket_url}" "${root_prefix}" "${output_dir}"

  echo "完了！バケット構造を ${output_dir} に出力しました。"
}

# メイン処理
if [[ $# -lt 1 ]]; then
  errecho "使用方法: $0 <バケットURL> [ルートプレフィックス] [出力ディレクトリ]"
  exit 1
fi

bucket_url=$1
root_prefix=${2:-""}
output_dir=${3:-"s3_structure"}

create_directory_structure "$bucket_url" "$root_prefix" "$output_dir"
