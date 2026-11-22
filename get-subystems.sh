mkdir -p ~/scratch-dir/repo ~/scratch-dir/out && \
cd ~/scratch-dir/repo && \
([ -d .git ] || git init) && \
(git remote get-url origin >/dev/null 2>&1 || git remote add origin git@github.com:iron-claw-972/FRC2026.git) && \
git fetch --depth=1 origin main && \
git ls-tree -d --name-only origin/main:src/main/java/frc/robot/subsystems | xargs -n 1 basename > ~/scratch-dir/out/subsystems.txt
