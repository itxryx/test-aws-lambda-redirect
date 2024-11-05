# test-aws-lambda-redirect

AWS Lambdaで任意のURLにリダイレクトを行うテスト。

## 使い方

1. `index.js`を編集
2. `$ make`を実行、`.zip`を生成
3. `$ cd terraform && terraform apply`

## URL

Lambdaから関数URLが発行されるため、以下を実行してURLが確認可能。

```
$ aws lambda get-function-url-config --function-name test-lambda-redirect
```