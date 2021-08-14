## 起動手順

### 1. Dockerのインストール

### 2. Docker networkの作成

`docker network create --internal backend`
`docker network create frontend`

### 3. コンテナ起動

`docker-compose up`

## コミット時の定形（コミッター向け）

コミットメッセージの雛形を以下に定める
```
1: \[変更ステータス] 変更点の要約
2:  # 空行
3: 全体の変更点の要約
---ここから繰り返し---
4:  # 空行
5: (modified | updated | deleted | created):  FILENAME
6: 変更点の説明
---変更ファイル数分繰り返す---
```
- ファイルごとの変更点説明や4行目以降自体を省略しても良い