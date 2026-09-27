#!/usr/bin/env bash
# Runs the RFM query against a throwaway Postgres and checks the segments it returns.
set -euo pipefail
PSQL="psql -v ON_ERROR_STOP=1 -q -X"

echo "→ loading sample data"
$PSQL -f sql/00_sample_data.sql

echo "→ running rfm.sql"
ACTUAL=$($PSQL -t -A -F',' -f sql/rfm.sql | sed '/^$/d' | sort)

echo "→ checking output"
EXPECTED=$(sort tests/expected_segments.csv)

if [ "$ACTUAL" = "$EXPECTED" ]; then
  echo "✓ segments match expected output"
else
  echo "✗ output changed:"
  diff <(echo "$EXPECTED") <(echo "$ACTUAL") || true
  exit 1
fi
