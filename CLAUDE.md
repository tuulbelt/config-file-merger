# Config File Merger - Development Context

## Tool Overview

**Name:** Config File Merger (`cfgmerge`)
**Purpose:** Merge configuration from ENV variables, config files, and CLI arguments with clear precedence
**Language:** TypeScript
**Test Count:** 144 tests passing
**Version:** 0.1.0

## What This Tool Does

Provides a single unified way to merge configuration from multiple sources:
- Environment variables (with optional prefix filtering)
- Configuration files (JSON, YAML, TOML)
- CLI arguments (key=value format)
- Default values

**Clear Precedence:** CLI > ENV > File > Defaults

## Key Features

- **Source Tracking:** Every config value knows where it came from
- **Type Coercion:** Automatic string → number/boolean conversion
- **Prototype Pollution Prevention:** Filters dangerous keys (`__proto__`, `constructor`, `prototype`)
- **Zero Dependencies:** Uses only Node.js standard library
- **Result Pattern:** All operations return `Result<T>` for clean error handling

## Architecture

**Core Module:** `src/index.ts` (~800 lines)
- `parseEnv()` - Parse environment variables with prefix filtering
- `parseFile()` - Parse JSON/YAML/TOML configuration files
- `parseArgs()` - Parse CLI arguments (key=value format)
- `mergeConfig()` - Merge all sources with clear precedence
- CLI entry point with `--env`, `--file`, `--args`, `--defaults` flags

**Test Coverage:** `test/index.test.ts` (144 tests)
- Env parsing (7 tests)
- File parsing (11 tests)
- Args parsing (6 tests)
- Type coercion (12 tests)
- Config merging (24 tests)
- CLI integration (16 tests)
- Source tracking (9 tests)
- Edge cases (14 tests)
- Result pattern (9 tests)
- Security (9 tests - prototype pollution prevention)

## Development Workflow

### Setup
```bash
git clone https://github.com/tuulbelt/config-file-merger.git
cd config-file-merger
npm install
```

### Testing
```bash
npm test                    # Run all 144 tests
npm run test:watch          # Watch mode
npx tsc --noEmit           # Type check
```

### Building
```bash
npm run build              # TypeScript compilation
```

### CLI Usage
```bash
npm link                   # Install globally
cfgmerge --env --prefix APP_ --file config.json --args "port=3000,debug=true"
```

## Security Considerations

**Prototype Pollution Prevention:**
- Filters dangerous keys: `__proto__`, `constructor`, `prototype`
- Applied to env, file, cli, and defaults sources
- 9 security tests verify filtering works correctly

**No Sensitive Data:**
- Tool doesn't handle secrets (use separate secret management)
- All config values are logged/tracked for debugging

## Common Patterns

**Merge All Sources:**
```typescript
import { mergeConfig, parseEnv, parseFile, parseArgs } from '@tuulbelt/config-file-merger';

const result = mergeConfig({
  env: parseEnv({ prefix: 'APP_' }),
  file: await parseFile('config.json'),
  cli: parseArgs(['port=3000', 'debug=true']),
  defaults: { port: 8080, debug: false }
});

if (!result.ok) {
  console.error(result.error.message);
  process.exit(1);
}

console.log(result.value.config);  // Merged config
console.log(result.value.sources); // Source tracking
```

**Source Tracking for Debugging:**
```typescript
const { config, sources } = result.value;
console.log(`Port ${config.port} came from: ${sources.port}`);
// Output: "Port 3000 came from: cli"
```

## Dogfooding

This tool is used by other Tuulbelt tools for configuration management:
- **test-flakiness-detector** - Configures run count, timeout, verbose mode
- **cli-progress-reporting** - Configures output format, colors, animation

Scripts:
- `scripts/dogfood-flaky.sh` - Validate determinism (135 tests × 10 runs)
- `scripts/dogfood-diff.sh` - Prove config merging produces identical output

See `DOGFOODING_STRATEGY.md` for complete integration details.

## Quality Standards

- ✅ 144/144 tests passing (100% success rate)
- ✅ TypeScript strict mode
- ✅ Zero runtime dependencies
- ✅ Result pattern for all operations
- ✅ Security: Prototype pollution prevention

## Part of Tuulbelt

This tool is part of the [Tuulbelt](https://github.com/tuulbelt/tuulbelt) collection of focused, zero-dependency tools.

**Report issues:** https://github.com/tuulbelt/tuulbelt/issues
