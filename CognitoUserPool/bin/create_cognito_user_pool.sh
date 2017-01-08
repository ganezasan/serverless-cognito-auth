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

# Check env
if [ -z "$STAGE" ] || [ -z "$POOL_NAME" ]; then
  echo "Please set STAGE env, $ POOL_NAME=sample STAGE=dev sh CognitoUserPool/bin/create_user_pool.sh"
  exit 1
fi

cd CognitoUserPool

if [ -d "edit" ]; then
  rm edit/*
else
  mkdir edit
fi

# files
userPoolFileName='userPool.json'
userPoolClientFileName='userPoolClient.json'

USER_POOL_NAME="${POOL_NAME}-${STAGE}"
USER_POOL_CLIENT_NAME="${POOL_NAME}-${STAGE}"

# Create Cognito User Pool
# find User pool id
USER_POOL_ID=$(aws cognito-idp list-user-pools --max-results 60 \
    | jq -r '.UserPools[] | select( .Name == "'$USER_POOL_NAME'").Id')

echo "Editing $userPoolFileName begin..."
sed -e "s/<PoolName>/$USER_POOL_NAME/g" \
  $userPoolFileName > edit/$userPoolFileName
echo "Editing $userPoolFileName end\n"

# if USER_POOL_NAME is aleady existed, this script don't create user pool
if [ -z "$USER_POOL_ID" ]; then
  # Create Cognito User Pool
  echo "Creating Cognito User Pool $USER_POOL_NAME begin..."
  USER_POOL_ID=$(aws cognito-idp create-user-pool --cli-input-json file://edit/$userPoolFileName | jq -r '.UserPool.Id')

  echo "Identity Pool Id: $USER_POOL_ID"
  echo "Creating Cognito Identity Pool $USER_POOL_NAME end\n"
else
  echo $USER_POOL_ID
  echo "Using previous user pool with name $USER_POOL_NAME\n"
fi

# Create Cognito User Pool Client
# find User pool client id
USER_POOL_CLIENT_ID=$(aws cognito-idp list-user-pool-clients --user-pool-id $USER_POOL_ID \
  --max-results 60 | jq -r '.UserPoolClients[] | select( .ClientName == "'$USER_POOL_CLIENT_NAME'").ClientId')

echo "Editing $userPoolClientFileName begin..."
sed -e "s/<UserPoolId>/$USER_POOL_ID/g" \
  -e "s/<ClientName>/$USER_POOL_CLIENT_NAME/g" \
  $userPoolClientFileName > edit/$userPoolClientFileName
echo "Editing $userPoolClientFileName end\n"

if [ -z "$USER_POOL_CLIENT_ID" ]; then
  # Create Cognito User Pool
  echo "Creating Cognito User Pool Client $USER_POOL_CLIENT_NAME begin..."
  USER_POOL_CLIENT_ID=$(aws cognito-idp create-user-pool-client --cli-input-json file://edit/$userPoolClientFileName | jq -r '.UserPoolClient.ClientId')
  echo "Identity Pool Id: $USER_POOL_CLIENT_ID"
  echo "Creating Cognito Identity Pool $USER_POOL_CLIENT_NAME end\n"
else
  echo $USER_POOL_CLIENT_ID
  echo "Using previous user pool with name $USER_POOL_CLIENT_NAME\n"
fi

# Init or Updating Cognito User Pool in config file
if [ ! -f "config.json" ]; then
  touch config.json
  echo '{}' | jq '.' >> config.json
fi

mv config.json config.org
jq '.'USER_POOL_ID'="'"$USER_POOL_ID"'"' config.org \
  | jq '.'USER_POOL_CLIENT_ID'="'"$USER_POOL_CLIENT_ID"'"' > config.json
rm config.org

cd ..
