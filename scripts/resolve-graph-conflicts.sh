#!/usr/bin/env bash
# Merges BASE into the checked-out branch when graphify's generated files are its only conflicts,
# which GitHub can't merge on its own: graph.json is union-merged, then the graph and report are rebuilt.
# Any other conflict is left for a person. Needs graphify on PATH.
#
#   scripts/resolve-graph-conflicts.sh origin/develop
set -euo pipefail
BASE=${1:?usage: scripts/resolve-graph-conflicts.sh <base-ref>}
cd "$(dirname "$0")/.."

# Without the merge drivers configured this sees the same conflicts GitHub does.
STATUS=0
FILES=$(git merge-tree --write-tree --name-only --no-messages HEAD "$BASE") || STATUS=$?
if [ "$STATUS" -eq 0 ]; then
  echo "No conflicts with $BASE"
  exit 0
fi
[ "$STATUS" -eq 1 ] || exit "$STATUS"
FILES=$(tail -n +2 <<<"$FILES")
if grep -qv '^graphify-out/' <<<"$FILES"; then
  echo "Conflicts with $BASE outside graphify-out need resolving by hand:"
  echo "$FILES"
  exit 0
fi

git config merge.graphify.driver 'graphify merge-driver %O %A %B'
git config merge.graphify-report.driver true
# Branches cut before .gitattributes existed don't have it in their working tree.
git show "$BASE:.gitattributes" >"$(git rev-parse --git-path info/attributes)"
git merge --no-edit "$BASE"
graphify update .
git add graphify-out/graph.json graphify-out/GRAPH_REPORT.md
git commit --amend --no-edit
echo "Merged $BASE and rebuilt the graph"
