#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

# Allow the openclaw user to manage its own global npm package so that
# config-driven auto-update (update.auto.enabled in openclaw.json) and any
# opt-in runtime install below can both succeed without root.
chown openclaw:openclaw /usr/local/lib/node_modules /usr/local/bin 2>/dev/null || true
chown -R openclaw:openclaw /usr/local/lib/node_modules/openclaw 2>/dev/null || true

# Optional runtime version pin / upgrade. Default is no-op: the openclaw version
# baked into the image is used as-is, which keeps boots fast (~25 s saved).
# Set OPENCLAW_VERSION=<semver> in Railway variables to force a specific
# version at boot, or OPENCLAW_VERSION=latest for floating latest.
if [ -n "${OPENCLAW_VERSION:-}" ]; then
  CURRENT="$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
  TARGET="${OPENCLAW_VERSION}"
  if [ "$TARGET" = "latest" ] || [ "$TARGET" != "$CURRENT" ]; then
    echo "[entrypoint] installing openclaw@${TARGET} (current: ${CURRENT:-none})"
    gosu openclaw npm i -g "openclaw@${TARGET}" --no-fund --no-audit --loglevel=error || true
  fi
fi

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
