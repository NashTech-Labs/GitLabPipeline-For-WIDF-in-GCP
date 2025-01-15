#!/bin/bash

echo $WORKLOAD_IDENTITY_TOKEN > $CI_BUILDS_DIR/.workload_identity.jwt
cat << EOF > $GOOGLE_APPLICATION_CREDENTIALS
{
  "type": "external_account",
  "audience": "//iam.googleapis.com/projects/$WORKLOAD_IDENTITY_PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL/providers/$PROVIDER",     
  "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
  "token_url": "https://sts.googleapis.com/v1/token",
  "credential_source": {
    "file": "$CI_BUILDS_DIR/.workload_identity.jwt"
  },
  "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$SERVICE_ACCOUNT:generateAccessToken"
}
EOF
