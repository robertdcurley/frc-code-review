#!/usr/bin/env bash
set -euo pipefail

# Choose a subsystem to test (e.g., shooter or drivetrain)
SUBSYSTEM="${1:-shooter}"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "▶ Cloning sparse FRC2026 repo for subsystem: ${SUBSYSTEM}..."
git clone --depth 1 --branch main --single-branch --filter=blob:none --no-checkout \
  https://github.com/iron-claw-972/FRC2026.git "$TEMP_DIR"

cd "$TEMP_DIR"
git sparse-checkout set "src/main/java/frc/robot/subsystems/${SUBSYSTEM}"

echo "▶ Bundling .java files..."
# Concatenate all Java files in the subsystem folder
CODE_BUNDLE=$(find "src/main/java/frc/robot/subsystems/${SUBSYSTEM}" -name "*.java" -exec head -n 2000 {} +)

if [ -z "$CODE_BUNDLE" ]; then
  echo "❌ Error: No Java files found in subsystems/${SUBSYSTEM}!"
  exit 1
fi

PROMPT="Attached is the code for our FRC team's ${SUBSYSTEM} subsystem. Please analyze this code for:
1. Garbage collection hazards or non-zero allocations in periodic() / 50 Hz loops (e.g., new objects, stream/lambda captures).
2. Potential hardware control or safety issues.
3. Maintainability / AdvantageKit IO abstraction patterns.
Provide a concise summary highlighting any high-priority fixes for our student developers."

FULL_CONTENT="${PROMPT}

\`\`\`java
${CODE_BUNDLE}
\`\`\`"

echo "▶ Sending payload to Anthropic Claude API..."
REPORT=$(jq -n \
  --arg model "claude-3-5-sonnet-20241022" \
  --arg content "$FULL_CONTENT" \
  '{
    model: $model,
    max_tokens: 2048,
    messages: [{ role: "user", content: $content }]
  }' | curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d @- | jq -r '.content[0].text')

echo ""
echo "=============================="
echo " CLAUDE AUDIT REPORT (${SUBSYSTEM})"
echo "=============================="
echo "$REPORT"
