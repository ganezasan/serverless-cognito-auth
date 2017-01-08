#!/bin/bash

# Check if the AWS CLI is in the PATH
found=$(which aws)
if [ -z "$found" ]; then
  echo "Please install the AWS CLI under your PATH: http://aws.amazon.com/cli/"
  exit 1
fi

# Check if jq is in the PATH
found=$(which jq)
if [ -z "$found" ]; then
  echo "Please install jq under your PATH: http://stedolan.github.io/jq/"
  exit 1
fi

# Check dir
if [ ! -d "CognitoUserPool" ]; then
  echo "Please execute the command in the parent directory of CognitoUserPool"
  exit 1
fi

cd CognitoUserPool

# Check config.json file
if [ ! -f "config.json" ]; then
  echo "Please set config.json file"
  exit 1
fi

# check USER_POOL_ID
USER_POOL_ID=$(cat config.json | jq -r '.USER_POOL_ID')
if [ -z "$USER_POOL_ID" ] || [ "$USER_POOL_ID" = "null" ]; then
  echo "Please set USER_POOL_ID in config.json"
  exit 1
fi

# delte User Pool Id
echo "User Pool Id: $USER_POOL_ID"
echo "Removing Cognito User Pool $USER_POOL_ID begin"
aws cognito-idp delete-user-pool --user-pool-id $USER_POOL_ID
echo "Removing Cognito Identity Pool $USER_POOL_ID end"

# delte USER_POOL_ID in config
rm config.json
echo '{}' | jq '.' >> config.json

cd ..
