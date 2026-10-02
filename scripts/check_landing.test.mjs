import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';

const root = new URL('../', import.meta.url);

test('approved static landing assets satisfy the source contract', () => {
  const result = spawnSync('python3', ['scripts/check_landing.py'], {
    cwd: root,
    encoding: 'utf8',
  });

  assert.equal(result.error, undefined, result.error?.message);
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  assert.match(result.stdout, /Landing checks passed/u);
});
