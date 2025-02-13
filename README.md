# Unifa App

## Version
- Ruby 3.4.1
- Rails 7.1.5
- PostgreSQL

## セットアップ手順
### 前提
- 共有されたmaster.keyを/config/master.keyに配置してください。

```
$ docker-compose build

$ docker-compose run web bundle exec rails db:create

$ docker-compose run web bundle exec rails db:migrate

$ docker-compose run web bundle exec rails db:seed

$ docker-compose up
```

## ログイン
http://localhost:3000/login
```
ログインID： user1
パスワード： password123*
```

## テスト
```
$ docker-compose run web bundle exec rails db:migrate RAILS_ENV=test

$ docker-compose run web bundle exec rails test
```
