# mule-cicd-templates

Reusable GitHub Actions workflows for MuleSoft CloudHub 2.0 deployments.

## Repository structure

```
mule-cicd-templates/
├── .github/
│   └── workflows/
│       ├── mule-deploy.yml   # Reusable: publish to Exchange + deploy to CloudHub 2.0
│       └── mule-build.yml    # Reusable: build and run MUnit tests
├── .maven/
│   └── settings.xml          # Reference template (generated at runtime in CI)
├── scripts/
│   └── create-settings.sh    # Local dev helper to generate .maven/settings.xml
├── docs/
│   └── usage.md              # Full usage guide and examples
└── README.md
```

## Quick start

### 1. Tag this repository

```bash
git tag v1
git push origin v1
```

### 2. Add secrets to your application repository

In your application repo → **Settings → Secrets and variables → Actions**, add:

| Secret | Description |
|--------|-------------|
| `CONNECTED_APP_ID` | Connected App client ID |
| `CONNECTED_APP_SECRET` | Connected App client secret |
| `ANYPOINT_CLIENT_ID` | Anypoint Platform client ID |
| `ANYPOINT_CLIENT_SECRET` | Anypoint Platform client secret |
| `SECURE_KEY` | Secure Properties encryption key |

### 3. Call the workflow from your application repository

```yaml
# .github/workflows/deploy.yml  (in your application repo)
name: Deploy to CloudHub 2.0

on:
  push:
    branches:
      - develop

jobs:
  deploy:
    uses: org/mule-cicd-templates/.github/workflows/mule-deploy.yml@v1
    secrets: inherit
```

## What the deploy workflow does

1. **Checkout** — checks out the calling repository
2. **Setup Java 17** — installs Eclipse Temurin JDK 17 with Maven dependency cache
3. **Create `.maven/settings.xml`** — generates the settings file at runtime using secrets; nothing is committed
4. **Publish to Exchange** — runs `mvn deploy` to publish the artifact to Anypoint Exchange
5. **Deploy to CloudHub 2.0** — runs `mvn mule:deploy` to deploy to CloudHub 2.0 (EU control plane, non-prod, QA environment)

## Requirements

- MuleSoft `mule-maven-plugin` ≥ 4.x in your application `pom.xml`
- `distributionManagement` configured with server id `anypoint-exchange`
- A Connected App with Exchange Contributor and CloudHub deployment scopes

## Documentation

See [docs/usage.md](docs/usage.md) for the full usage guide including environment-specific overrides, local development setup, and end-to-end pipeline examples.

## License

MIT
