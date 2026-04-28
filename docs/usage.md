# Usage Guide — mule-cicd-templates

## Overview

This repository provides reusable GitHub Actions workflows for deploying MuleSoft applications to CloudHub 2.0. Workflows are consumed via `workflow_call`, meaning your application repositories never need to duplicate pipeline logic.

---

## Prerequisites

1. **Connected App** created in Anypoint Platform with the following scopes:
   - `Exchange Contributor`
   - `CloudHub Network Operator`
   - `CloudHub Developer` (or `Runtime Manager` equivalent for CH2)

2. **GitHub Secrets** configured in your application repository:

   | Secret name             | Description                                      |
   |-------------------------|--------------------------------------------------|
   | `CONNECTED_APP_ID`      | Connected App client ID (Exchange + deploy auth) |
   | `CONNECTED_APP_SECRET`  | Connected App client secret                      |
   | `ANYPOINT_CLIENT_ID`    | Anypoint Platform client ID (API Manager)        |
   | `ANYPOINT_CLIENT_SECRET`| Anypoint Platform client secret                  |
   | `SECURE_KEY`            | MuleSoft Secure Properties encryption key        |

3. Your `pom.xml` must include:
   - `mule-maven-plugin` (≥ 4.x) with a `<cloudHubDeployment>` configuration
   - `distributionManagement` pointing to your Exchange endpoint with server id `anypoint-exchange`

---

## Calling the reusable deploy workflow

Create a workflow file in your application repository, for example `.github/workflows/deploy-qa.yml`:

```yaml
name: Deploy to QA

on:
  push:
    branches:
      - develop

jobs:
  deploy:
    uses: org/mule-cicd-templates/.github/workflows/mule-deploy.yml@v1
    secrets: inherit
```

Replace `org` with your GitHub organisation or username.

---

## Calling the reusable build workflow

```yaml
name: Build & Test

on:
  pull_request:
    branches:
      - develop
      - main

jobs:
  build:
    uses: org/mule-cicd-templates/.github/workflows/mule-build.yml@v1
    secrets: inherit
```

---

## Full end-to-end example (build + deploy)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - develop

jobs:
  build:
    uses: org/mule-cicd-templates/.github/workflows/mule-build.yml@v1
    secrets: inherit

  deploy:
    needs: build
    uses: org/mule-cicd-templates/.github/workflows/mule-deploy.yml@v1
    secrets: inherit
```

---

## Workflow steps (mule-deploy.yml)

| Step | Description |
|------|-------------|
| Checkout repository | Checks out the calling repo's code |
| Setup Java 17 | Installs Eclipse Temurin JDK 17 with Maven cache |
| Create .maven/settings.xml | Generates settings.xml at runtime — no secrets committed |
| Publish to Exchange | Runs `mvn deploy` to publish the asset to Anypoint Exchange |
| Deploy to CloudHub 2.0 | Runs `mvn mule:deploy` to deploy to the target CloudHub 2.0 environment |

---

## Customising deploy parameters

The deploy step passes all CloudHub 2.0 parameters as Maven `-D` flags. To override any of them, fork this template or create a wrapper workflow:

```yaml
jobs:
  deploy-prod:
    uses: org/mule-cicd-templates/.github/workflows/mule-deploy.yml@v1
    secrets: inherit
    # Note: workflow_call does not support overriding run steps directly.
    # For environment-specific overrides, add `with:` inputs to the
    # reusable workflow (see inputs section below).
```

For per-environment flexibility, add `inputs:` blocks to `mule-deploy.yml` and pass values with `with:` from the caller:

```yaml
# In mule-deploy.yml on: workflow_call:
    inputs:
      environment:
        required: true
        type: string
      mule_env:
        required: true
        type: string
      replicas:
        required: false
        type: number
        default: 1
      vcores:
        required: false
        type: string
        default: '0.1'

# In your caller workflow:
jobs:
  deploy:
    uses: org/mule-cicd-templates/.github/workflows/mule-deploy.yml@v1
    with:
      environment: PROD
      mule_env: prod
      replicas: 2
      vcores: '0.2'
    secrets: inherit
```

---

## Local development

Generate a local `.maven/settings.xml` (excluded from git via `.gitignore`):

```bash
./scripts/create-settings.sh
# or pass credentials via env:
CONNECTED_APP_ID=xxx CONNECTED_APP_SECRET=yyy ./scripts/create-settings.sh
```

Then run Maven locally:

```bash
mvn clean test --settings .maven/settings.xml \
  -Danypoint.connectedAppId="$CONNECTED_APP_ID" \
  -Danypoint.connectedAppSecret="$CONNECTED_APP_SECRET"
```

---

## Tagging a new release

```bash
git tag v1
git push origin v1
```

Callers pinned to `@v1` will automatically use this tag.
