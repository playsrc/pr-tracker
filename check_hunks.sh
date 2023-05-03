#!/bin/bash
HUNKS_PR_COUNT=0

echo "Checking Hunks..."

export CHECK_HUNKS_LINE=":mag_right: Spotted ${HUNKS_PR_COUNT} similar hunk(s)"
export CHECK_HUNKS_DETAILS="check_hunks.sh DETAILS (TODO)"