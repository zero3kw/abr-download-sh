FROM ubuntu:latest

# 基本的なツールのインストール
RUN apt-get update && apt-get install -y \
  curl \
  git \
  libxml2-utils \
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /workspace

# スクリプトの実行権限を設定
CMD [ "bash" ]