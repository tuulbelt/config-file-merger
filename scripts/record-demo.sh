#!/bin/bash
# Record Configuration File Merger demo
source "$(dirname "$0")/lib/demo-framework.sh"

TOOL_NAME="config-file-merger"
SHORT_NAME="cfgmerge"
LANGUAGE="typescript"

# GIF parameters
GIF_COLS=100
GIF_ROWS=30
GIF_SPEED=1.0
GIF_FONT_SIZE=14

demo_setup() {
  # Create sample files for the demo
  echo '{"port": 3000, "host": "localhost"}' > /tmp/config-demo.json
  echo '{"debug": false, "timeout": 30}' > /tmp/defaults-demo.json
}

demo_cleanup() {
  # Clean up sample files
  rm -f /tmp/config-demo.json /tmp/defaults-demo.json
  unset APP_PORT APP_DEBUG 2>/dev/null || true
}

demo_commands() {
  # ═══════════════════════════════════════════
  # Configuration File Merger / cfgmerge - Tuulbelt
  # ═══════════════════════════════════════════

  # Step 1: Installation
  echo "# Step 1: Install globally"
  sleep 0.5
  echo "$ npm link"
  sleep 1

  # Step 2: View help
  echo ""
  echo "# Step 2: View available commands"
  sleep 0.5
  echo "$ cfgmerge --help"
  sleep 0.5
  cfgmerge --help | head -25
  sleep 3

  # Step 3: Merge config file with defaults
  echo ""
  echo "# Step 3: Merge config with defaults"
  sleep 0.5
  echo "$ cfgmerge --defaults /tmp/defaults-demo.json --file /tmp/config-demo.json"
  sleep 0.5
  cfgmerge --defaults /tmp/defaults-demo.json --file /tmp/config-demo.json
  sleep 2

  # Step 4: Override with environment variables
  echo ""
  echo "# Step 4: Override with environment variables"
  sleep 0.5
  export APP_PORT=8080
  export APP_DEBUG=true
  echo "$ export APP_PORT=8080 APP_DEBUG=true"
  echo "$ cfgmerge --env --prefix APP_ --file /tmp/config-demo.json"
  sleep 0.5
  cfgmerge --env --prefix APP_ --file /tmp/config-demo.json
  sleep 2

  # Step 5: CLI args take highest precedence
  echo ""
  echo "# Step 5: CLI args override everything"
  sleep 0.5
  echo "$ cfgmerge --file /tmp/config-demo.json --args \"port=9000,debug=true\""
  sleep 0.5
  cfgmerge --file /tmp/config-demo.json --args "port=9000,debug=true"
  sleep 2

  # Step 6: Track sources
  echo ""
  echo "# Step 6: Track value sources"
  sleep 0.5
  echo "$ cfgmerge --file /tmp/config-demo.json --args \"port=9000\" --track-sources"
  sleep 0.5
  cfgmerge --file /tmp/config-demo.json --args "port=9000" --track-sources
  sleep 3

  echo ""
  echo "# Done! Merge configs with: cfgmerge --file config.json"
  sleep 1
}

run_demo
