#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

# Allow the openclaw user to write to its global node_modules so
# config-driven auto-update (update.auto.enabled in openclaw.json) can apply
# package upgrades at runtime.
chown -R openclaw:openclaw /usr/local/lib/node_modules/openclaw 2>/dev/null || true

# Bring the openclaw CLI to the latest stable on every (re)deploy so the
# Docker image's pinned version doesn't roll back the runtime.
gosu openclaw npm i -g openclaw@latest --no-fund --no-audit --loglevel=error || true

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
