SCRATCH_DIR=$(mktemp -d)
trap "rm -rf $SCRATCH_DIR" EXIT

git clone --depth 1 --branch main --single-branch --filter=blob:none --sparse \
  https://github.com/iron-claw-972/FRC2026.git "$SCRATCH_DIR"

cd "$SCRATCH_DIR"
git sparse-checkout set src/main/java/frc/robot/subsystems
