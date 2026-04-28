#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# create-settings.sh
# Generates .maven/settings.xml for local development.
# Never commit the generated file — it is listed in .gitignore.
# ---------------------------------------------------------------------------
set -euo pipefail

SETTINGS_DIR="$(cd "$(dirname "$0")/.." && pwd)/.maven"
SETTINGS_FILE="${SETTINGS_DIR}/settings.xml"

echo "=== MuleSoft settings.xml generator ==="
echo "Output: ${SETTINGS_FILE}"
echo ""

# Read credentials interactively or from environment variables
if [[ -z "${CONNECTED_APP_ID:-}" ]]; then
  read -rp "Connected App ID     : " CONNECTED_APP_ID
fi

if [[ -z "${CONNECTED_APP_SECRET:-}" ]]; then
  read -rsp "Connected App Secret : " CONNECTED_APP_SECRET
  echo ""
fi

mkdir -p "${SETTINGS_DIR}"

cat > "${SETTINGS_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>anypoint-exchange</id>
      <username>~~~Client~~~</username>
      <password>${CONNECTED_APP_ID}~?~${CONNECTED_APP_SECRET}</password>
    </server>
  </servers>
</settings>
EOF

echo ""
echo "settings.xml written to: ${SETTINGS_FILE}"
echo "Run Maven with:  mvn <goal> --settings .maven/settings.xml"
