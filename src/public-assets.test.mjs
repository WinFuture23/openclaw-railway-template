import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const PUBLIC_DIR = path.join(import.meta.dirname, "public");

const REQUIRED_ASSETS = [
  "setup.html",
  "loading.html",
  "logs.html",
  "tui.html",
  "styles.css",
];

for (const asset of REQUIRED_ASSETS) {
  test(`public asset ${asset} exists and is non-empty`, () => {
    const filePath = path.join(PUBLIC_DIR, asset);
    const stat = fs.statSync(filePath);
    assert.ok(stat.isFile(), `${filePath} is not a regular file`);
    assert.ok(stat.size > 0, `${filePath} is empty`);
  });
}
