# 家計簿アプリ
これは何の変哲もないシンプルな家計簿アプリ  
想定としては支出の管理のみ可能

## 環境構築
以下のコマンドを一つずつ順番に実行
```
$ docker-compose build
$ docker-compsoe up -d
$ docker-compose exec app rails db:create
$ docker-compose exec app rails db:migrate
```