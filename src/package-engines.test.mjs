import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const PKG_PATH = path.join(import.meta.dirname, "..", "package.json");

test("package.json declares Node engine >=24", () => {
  const pkg = JSON.parse(fs.readFileSync(PKG_PATH, "utf8"));
  assert.ok(pkg.engines?.node, "missing engines.node");
  assert.match(
    pkg.engines.node,
    />=2[4-9]|>=[3-9]\d/,
    `engines.node "${pkg.engines.node}" must require Node 24+`,
  );
});

test("running Node satisfies engines.node", () => {
  const pkg = JSON.parse(fs.readFileSync(PKG_PATH, "utf8"));
  const major = Number.parseInt(process.versions.node.split(".")[0], 10);
  const minMatch = pkg.engines.node.match(/(\d+)/);
  assert.ok(minMatch, "could not parse engines.node");
  const min = Number.parseInt(minMatch[1], 10);
  assert.ok(
    major >= min,
    `running Node ${process.versions.node} is below engines.node ${pkg.engines.node}`,
  );
});
