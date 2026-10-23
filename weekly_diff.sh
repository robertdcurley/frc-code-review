#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Target path to isolate subsystem logic
PATH_FILTER="src/main/java/frc/robot/subsystems/"
DAYS=${1:-7} # Default to 7 days, or pass a custom number of days: ./weekly_diff.sh 14

echo "============================================================"
echo " Subsystem Branch Audit Report (Last $DAYS Days)"
echo " Path Scope: $PATH_FILTER"
echo "============================================================"

# Fetch latest branches and tags from remote silently
git fetch origin --prune --quiet

# Find remote feature branches updated within the time window (excluding main/HEAD)
# Using git for-each-ref for reliable cross-platform date filtering
CUTOFF_DATE=$(date -d "$DAYS days ago" +%s 2>/dev/null || date -v-${DAYS}d +%s) # Supports both Linux and macOS date commands

BRANCHES=$(git for-each-ref --format='%(committerdate:unix) %(refname:short)' refs/remotes/origin | \
    grep -v -E 'origin/main|origin/HEAD' | \
    awk -v cutoff="$CUTOFF_DATE" '$1 >= cutoff {print $2}')

if [ -z "$BRANCHES" ]; then
    echo "No feature branches with commits in the last $DAYS days."
    exit 0
fi

ACTIVE_COUNT=0

for branch in $BRANCHES; do
    clean_branch=$(echo "$branch" | sed 's/origin\///')
    
    # Check if there are unique commits on this branch compared to main within PATH_FILTER
    commit_count=$(git rev-list --count origin/main.."$branch" -- "$PATH_FILTER")
    
    if [ "$commit_count" -gt 0 ]; then
        ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
        echo ""
        echo "------------------------------------------------------------"
        echo " Branch: $clean_branch ($commit_count subsystem commit(s) ahead of main)"
        echo "------------------------------------------------------------"
        
        # Output the diff between main and the feature branch for subsystem code
        git diff origin/main.."$branch" -- "$PATH_FILTER"
    fi
done

if [ "$ACTIVE_COUNT" -eq 0 ]; then
    echo "Branches exist, but none have modified '$PATH_FILTER' relative to main."
fi
