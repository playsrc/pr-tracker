#!/bin/bash
HUNKS_PR_COUNT=0

echo "Checking Hunks..."

export CHECK_HUNKS_LINE=":x: \*\*${HUNKS_PR_COUNT}\*\* similar hunk(s) spotted"
export CHECK_HUNKS_DETAILS="check_hunks.sh DETAILS (TODO)"