#!/usr/bin/env npx tsx
/**
 * Dogfood: Output Consistency Validation
 *
 * Verifies that mergeConfig produces identical output for identical input.
 * This proves the tool is deterministic - same input always produces same output.
 */

import { mergeConfig, parseCliArgs, type MergeOptions } from '../src/index.ts';
import { strictEqual } from 'node:assert';

// Test cases with various merge scenarios
const testCases: MergeOptions[] = [
  // Basic merge
  {
    defaults: { port: 8080, debug: false },
    cli: { port: { value: 3000, source: 'cli' } },
  },
  // All sources
  {
    defaults: { port: 8080, debug: false, host: 'localhost' },
    file: { port: { value: 9000, source: 'file' }, timeout: { value: 30, source: 'file' } },
    env: { DEBUG: { value: true, source: 'env' } },
    cli: { host: { value: '0.0.0.0', source: 'cli' } },
  },
  // Empty defaults
  {
    defaults: {},
    cli: { key: { value: 'value', source: 'cli' } },
  },
  // CLI args parsing
  {
    defaults: { port: 8080, enabled: true, ratio: 0.5 },
    cli: parseCliArgs('port=3000,enabled=false,ratio=0.75'),
  },
  // Only defaults
  {
    defaults: { a: 1, b: 2, c: 3 },
  },
];

const RUNS = 100;

console.log('Dogfood: Output Consistency Validation');
console.log(`Running ${testCases.length} test cases × ${RUNS} iterations = ${testCases.length * RUNS} comparisons\n`);

let passed = 0;
let failed = 0;

for (let i = 0; i < testCases.length; i++) {
  const options = testCases[i];
  const label = `Test case ${i + 1}`;

  // Get baseline result
  const baseline = mergeConfig(options);
  const baselineJson = JSON.stringify(baseline);

  // Run multiple times and compare
  let allMatch = true;
  for (let run = 0; run < RUNS; run++) {
    const result = mergeConfig(options);
    const resultJson = JSON.stringify(result);

    if (baselineJson !== resultJson) {
      allMatch = false;
      console.error(`FAIL: ${label} - output mismatch at run ${run}`);
      console.error(`  Baseline: ${baselineJson}`);
      console.error(`  Run ${run}: ${resultJson}`);
      break;
    }
  }

  if (allMatch) {
    passed++;
    console.log(`✓ ${label} - ${RUNS} runs identical`);
  } else {
    failed++;
  }
}

console.log(`\n${'='.repeat(60)}`);
console.log(`Results: ${passed}/${testCases.length} passed, ${failed} failed`);

if (failed > 0) {
  console.error('\n❌ OUTPUT CONSISTENCY VALIDATION FAILED');
  console.error('The tool produced different output for identical input.');
  process.exit(1);
}

console.log('\n✅ OUTPUT CONSISTENCY VALIDATED');
console.log('All test cases produced identical output across all runs.');
process.exit(0);
