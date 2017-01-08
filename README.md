# serverless-cognito-auth

Sample code for using Cognito User Pools with CUSOTOM AUTH of API Gateway.

# Cognito User Pools

## create Cognito Pools
```
$ POOL_NAME=sample STAGE=dev sh CognitoUserPool/bin/create_user_pool.sh
```

## delete Cognito Pools

* This script using config.json, it was created from create_user_pool.sh
```
$ sh CognitoUserPool/bin/create_user_pool.sh
```

## create User
```
$ aws cognito-idp admin-create-user --cli-input-json file://CognitoUserPool/user.json
```

## get token

```
$ aws cognito-idp admin-initiate-auth --cli-input-json file://CognitoUserPool/signIn.json
```

# API deploy
## install serverless
Please use serverless version 1.5 or more.

```
npm install serverless -g
```
or
```
npm upgrade serverless -g
```

## deploy
```
serverless deploy
```

## test
Please change `<apiId>` and `<IdToken>`.

```
curl -X POST https://<apiId>.execute-api.ap-northeast-1.amazonaws.com/dev/auth/hello -H "Authorization: <IdToken>
> {"Message":"Hello World!"}
```
