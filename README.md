# GitLab Pipeline for WIDF Authentication in GCP

This GitLab CI/CD pipeline integrates **Workload Identity Federation (WIDF)** authentication for Google Cloud Platform (GCP). It enables authentication with GCP using external identities and Service Account impersonation.

## Setup

### Prerequisites

- A GCP project with **Workload Identity Federation (WIDF)** configured.
- A GitLab repository containing the necessary files for pipeline execution.
- Service account with proper permissions for impersonation.

### Environment Variables

Make sure the following environment variables are set:

- `GCP_PROJECT_NUMBER`: Your GCP project number.
- `WORKLOAD_IDENTITY_POOL_ID`: The Workload Identity Pool ID.
- `WORKLOAD_IDENTITY_PROVIDER_ID`: The Workload Identity Provider ID.
- `SERVICE_ACCOUNT_EMAIL`: The service account email used for impersonation.

### Files

1. **GitLab Pipeline Configuration (gitlab-ci.yml)**: Defines the pipeline stages and the steps for authentication.
2. **Authentication Script (auth.sh)**: Script that configures Workload Identity Federation authentication and generates the necessary credentials for GCP.

### Usage

1. The pipeline has one stage `auth`, which handles GCP authentication using **Workload Identity Federation**.
2. The `gcp_authentication` job authenticates using the Google Cloud SDK and creates an external account credential file using the generated token.

### GitLab CI Pipeline Example

```yaml
stages:
  - auth

gcp_authentication:
  stage: auth
  image: google/cloud-sdk:latest
  variables:
    WORKLOAD_IDENTITY_PROJECT_NUMBER: "<GCP_PROJECT_NUMBER>"
    POOL: "<WORKLOAD_IDENTITY_POOL_ID>"
    PROVIDER: "<WORKLOAD_IDENTITY_PROVIDER_ID>"
    SERVICE_ACCOUNT: "<SERVICE_ACCOUNT_EMAIL>"
    GOOGLE_APPLICATION_CREDENTIALS: "$CI_BUILDS_DIR/.workload_identity.wlconfig"
  id_tokens:
    WORKLOAD_IDENTITY_TOKEN:
      aud: "https://iam.googleapis.com/projects/$WORKLOAD_IDENTITY_PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL/providers/$PROVIDER"

  script:
    - chmod +x auth.sh
    - ./auth.sh
    - gcloud auth login --cred-file=$GOOGLE_APPLICATION_CREDENTIALS
```
## ```auth.sh``` Script
This script creates a JWT token and generates the credential file for GCP authentication.
```
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
```
## Conclusion
Once the pipeline executes successfully, you will be authenticated with GCP using Workload Identity Federation, allowing seamless interaction with GCP services using the specified service account.
