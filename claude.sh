#!/usr/bin/env bash
set -euo pipefail

# Defaults to "drivetrain" if no argument is passed (e.g. ./test_audit.sh shooter)
SUBSYSTEM="${1:-drivetrain}"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "▶ Cloning sparse FRC2026 repo (with 14-day history) for: ${SUBSYSTEM}..."
git clone --branch main --single-branch --filter=blob:none --no-checkout --shallow-since="14 days ago" \
  https://github.com/iron-claw-972/FRC2026.git "$TEMP_DIR"

cd "$TEMP_DIR"
git sparse-checkout set "src/main/java/frc/robot/subsystems/${SUBSYSTEM}"

echo "▶ Bundling .java files and recent commit history..."
CODE_BUNDLE=$(find "src/main/java/frc/robot/subsystems/${SUBSYSTEM}" -name "*.java" -exec head -n 2000 {} +)

if [ -z "$CODE_BUNDLE" ]; then
  echo "❌ Error: No Java files found in subsystems/${SUBSYSTEM}!"
  exit 1
fi

RECENT_HISTORY=$(git log -p --since="14 days ago" -- "src/main/java/frc/robot/subsystems/${SUBSYSTEM}")

FULL_CONTENT="Attached is the current code and recent 14-day commit history for our FRC team's ${SUBSYSTEM} subsystem.
Analyze both the full subsystem architecture and the recent changes to identify:
1. Any new regressions, bugs, or unintended side effects introduced by recent commits.
2. Garbage collection hazards or non-zero allocations in periodic() / 50 Hz loops (e.g., new objects, stream/lambda captures).
3. Potential hardware control or safety issues.
4. Maintainability / AdvantageKit IO abstraction patterns.

Provide a concise summary highlighting any high-priority fixes for our student developers.

=== RECENT COMMIT HISTORY & DIFFS (LAST 14 DAYS) ===
\`\`\`diff
${RECENT_HISTORY:-No commits in the last 14 days.}
\`\`\`

=== CURRENT FULL SUBSYSTEM CODE ===
\`\`\`java
${CODE_BUNDLE}
\`\`\`"

echo "▶ Sending payload to Anthropic Claude API..."
RESPONSE=$(jq -n \
  --arg model "claude-sonnet-4-6" \
  --arg content "$FULL_CONTENT" \
  '{
    model: $model,
    max_tokens: 2048,
    messages: [{ role: "user", content: $content }]
  }' | curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d @-)

# Extract the report text (or print the raw API error if something failed)
REPORT=$(echo "$RESPONSE" | jq -r '.content[0].text // empty')

if [ -z "$REPORT" ]; then
  echo "❌ API Error:"
  echo "$RESPONSE" | jq .
  exit 1
fi

echo ""
echo "=============================="
echo " CLAUDE AUDIT REPORT (${SUBSYSTEM})"
echo "=============================="
echo "$REPORT"
