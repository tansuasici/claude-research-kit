#!/usr/bin/env node
//
// claude-research-kit — npx entry point (crk)
//
// Thin Node shim over the shell implementation, so the kit installs and
// self-checks the same way whether invoked via npx or a git clone.
//
//   npx @tansuasici/claude-research-kit init [--upgrade|--gitignore|--dry-run]
//   npx @tansuasici/claude-research-kit doctor
//   npx @tansuasici/claude-research-kit bench
//   npx @tansuasici/claude-research-kit --version
//
'use strict';

const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const PKG_ROOT = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
const cmd = args[0];
const rest = args.slice(1);

function version() {
  try {
    return fs.readFileSync(path.join(PKG_ROOT, 'VERSION'), 'utf8').trim();
  } catch {
    return '0.0.0';
  }
}

function run(script, scriptArgs, opts = {}) {
  const r = spawnSync('bash', [path.join(PKG_ROOT, script), ...scriptArgs], {
    stdio: 'inherit',
    cwd: opts.cwd || process.cwd(),
  });
  process.exit(r.status == null ? 1 : r.status);
}

function listSkills() {
  const candidates = [
    path.join(process.cwd(), '.claude', 'skills'),
    path.join(PKG_ROOT, '.claude', 'skills'),
  ];
  const base = candidates.find((d) => {
    try { return fs.statSync(d).isDirectory(); } catch { return false; }
  });
  if (!base) {
    console.log('No .claude/skills/ found (run `crk init` first).');
    process.exit(0);
  }
  const names = fs.readdirSync(base).filter((n) => {
    try { return fs.statSync(path.join(base, n, 'SKILL.md')).isFile(); } catch { return false; }
  }).sort();
  console.log(`Available skills (${names.length}) — invoke with /<name>:\n`);
  for (const name of names) {
    let desc = '';
    try {
      const m = fs.readFileSync(path.join(base, name, 'SKILL.md'), 'utf8').match(/^description:\s*(.+)$/m);
      if (m) desc = m[1].trim();
    } catch { /* ignore */ }
    console.log(desc ? `  /${name}\n      ${desc}` : `  /${name}`);
  }
  process.exit(0);
}

switch (cmd) {
  case 'init':
  case 'install':
    // Install into the caller's current directory.
    run('install.sh', [process.cwd(), ...rest]);
    break;
  case 'doctor':
    // Health-check the installation in the current directory.
    run('scripts/doctor.sh', [process.cwd()]);
    break;
  case 'bench':
    // Run the bench against the kit's own source.
    run('scripts/run-bench.sh', rest, { cwd: PKG_ROOT });
    break;
  case 'convert':
    // Export the CURRENT project's CLAUDE.md to AGENTS.md / other tools.
    run('scripts/convert.sh', rest);
    break;
  case 'skills':
    listSkills();
    break;
  case '--version':
  case '-v':
    console.log(version());
    break;
  case undefined:
  case '--help':
  case '-h':
  default:
    console.log(`claude-research-kit ${version()}

Usage:
  crk init [--upgrade|--gitignore|--dry-run]   Install the kit into the current dir
  crk doctor                                    Check installation health
  crk skills                                    List available /skills
  crk convert [all|agents-md|cursor|windsurf|aider]   Export CLAUDE.md to other tools
  crk bench                                      Run ResearchKitBench
  crk --version                                  Print version

Docs: https://github.com/tansuasici/ClaudeResearchKit`);
    process.exit(cmd && !['--help', '-h'].includes(cmd) ? 2 : 0);
}
