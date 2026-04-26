#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

# Allow the openclaw user to manage its own global npm package so that
# config-driven auto-update (update.auto.enabled in openclaw.json) and the
# boot-time `npm i -g openclaw@latest` below can both succeed without root.
# - /usr/local/lib/node_modules: needed for atomic rename during reinstall
# - /usr/local/lib/node_modules/openclaw: package directory itself
# - /usr/local/bin: needed for the openclaw bin-symlink update
chown openclaw:openclaw /usr/local/lib/node_modules /usr/local/bin 2>/dev/null || true
chown -R openclaw:openclaw /usr/local/lib/node_modules/openclaw 2>/dev/null || true

# Install Playwright/Chromium system libraries so the OpenClaw `browser` plugin
# can actually launch its bundled chromium. Skipped if already installed (cheap).
if ! dpkg -s libnss3 >/dev/null 2>&1; then
  echo "[entrypoint] installing chromium runtime libraries…"
  DEBIAN_FRONTEND=noninteractive apt-get update -qq || true
  DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
    libnss3 libnspr4 \
    libatk1.0-0 libatk-bridge2.0-0 libatspi2.0-0 \
    libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libasound2 libcups2 libdbus-1-3 \
    libgbm1 libxkbcommon0 || echo "[entrypoint] WARN: chromium libs install failed (browser plugin may not work)"
fi

# Bring the openclaw CLI to the latest stable on every (re)deploy so the
# Docker image's pinned version doesn't roll back the runtime.
gosu openclaw npm i -g openclaw@latest --no-fund --no-audit --loglevel=error || true

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
