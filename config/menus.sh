#!/bin/bash
HEADER_MSG="BASH TOOLKIT"

createMenu "mainMenu" "AWS Session Menu"
addMenuItem "mainMenu" "Quit" l8r
addMenuItem "mainMenu" "Show Current AWS Env Vars" showEnv
addMenuItem "mainMenu" "AWS MFA" setAwsMfa
addMenuItem "mainMenu" "Clear AWS Env Vars" clearAws
addMenuItem "mainMenu" "Manual Env Var Menu" loadMenu "awsEnvVarMenu"

# https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
read -r -d '' ENV_VAR_MENU << EOM
  Manual Env Var Management
  - https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html
EOM
createMenu "awsEnvVarMenu" "$ENV_VAR_MENU"
addMenuItem "awsEnvVarMenu" "Quit" l8r
addMenuItem "awsEnvVarMenu" "Show Current AWS Env Vars" showEnv
addMenuItem "awsEnvVarMenu" "AWS_ACCESS_KEY_ID" exportVar "AWS_ACCESS_KEY_ID"
addMenuItem "awsEnvVarMenu" "AWS_SECRET_ACCESS_KEY" exportVar "AWS_SECRET_ACCESS_KEY"
addMenuItem "awsEnvVarMenu" "AWS_SESSION_TOKEN" exportVar "AWS_SESSION_TOKEN"
addMenuItem "awsEnvVarMenu" "AWS_DEFAULT_REGION" exportVar "AWS_DEFAULT_REGION"
addMenuItem "awsEnvVarMenu" "AWS_DEFAULT_OUTPUT" exportVar "AWS_DEFAULT_OUTPUT"
addMenuItem "awsEnvVarMenu" "AWS_PROFILE" exportVar "AWS_PROFILE"
addMenuItem "awsEnvVarMenu" "AWS_CA_BUNDLE" exportVar "AWS_CA_BUNDLE"
addMenuItem "awsEnvVarMenu" "AWS_SHARED_CREDENTIALS_FILE" exportVar "AWS_SHARED_CREDENTIALS_FILE"
addMenuItem "awsEnvVarMenu" "AWS_CONFIG_FILE" exportVar "AWS_CONFIG_FILE"

function showEnv() {
    printf "env | grep 'AWS_'\n\n"
    env | grep 'AWS_'
    printf "aws configure list\n\n"
    aws configure list
    pause
}

function setProfile() {
    echo "grep '\[.*\]' ~/.aws/credentials"
    grep '\[.*\]' ~/.aws/credentials
    echo "Enter the profile name you want to use, without the brackets []"
    echo
    echo "  This should NOT be default, rather another cred config for initial creds"
    echo "  The profile you set here will be used to spawn new session creds under the default profile"
    read -p "  Profile: " spawnProfile
    export AWS_INIT_CREDS="$spawnProfile"
}

# Depends on jq (Command-line JSON Parser)
# https://stedolan.github.io/jq/
function setAwsMfa() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN

    while [[ -z "$AWS_INIT_CREDS" || "$AWS_INIT_CREDS" = "default" ]]; do
        setProfile
    done

    read -p "  Enter MFA Code: " mfaToken
    export AWS_PROFILE="$AWS_INIT_CREDS"
    local mfaSerial="$(aws configure get $AWS_INIT_CREDS.mfa_serial)"
    local stsResponse=$(aws sts get-session-token --serial-number $mfaSerial --token-code $mfaToken --duration-seconds 21600)

    local keyId=$(echo $stsResponse | jq -r ."Credentials"."AccessKeyId")
    local key=$(echo $stsResponse | jq -r ."Credentials"."SecretAccessKey")
    local token=$(echo $stsResponse | jq -r ."Credentials"."SessionToken")

    # set profile back to default to use live creds
    export AWS_PROFILE="default"
    export AWS_ACCESS_KEY_ID=$keyId
    export AWS_SECRET_ACCESS_KEY=$key
    export AWS_SESSION_TOKEN=$token

    # TODO: remove file-writes for better security
    #   when issue is fixed [https://github.com/serverless/serverless/issues/3833#issuecomment-411023823]
    # needed for certain things such as sls deploy that don't work from env vars
    aws configure set default.aws_access_key_id $keyId
    aws configure set default.aws_secret_access_key $key
    aws configure set default.aws_session_token $token

    echo "Setup AWS MFA Session Token"
    pause
}

function clearAws() {
    unset AWS_INIT_CREDS

    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_DEFAULT_REGION
    unset AWS_DEFAULT_OUTPUT
    unset AWS_PROFILE
    unset AWS_CA_BUNDLE
    unset AWS_SHARED_CREDENTIALS_FILE
    unset AWS_CONFIG_FILE
}

function exportVar() {
    echo " Set value, if set to 'unset' (no quotes), the prop will be unset from env"
    read -p "  $1=" value
    if [[ "$value" = "unset" ]]; then
        eval "unset $1"
    else
        eval "export $1=$value"
    fi
}