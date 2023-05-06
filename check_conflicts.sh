#!/bin/bash
CONFLICT_PR_AMOUNT=0

echo "Checking Conflicts..."

# check_pulls.sh exports two variables FOUND_PR_NUMBERS and FOUND_PR_AMOUNT
# if FOUND_PR_NUMBERS is empty, do nothing, else start checking for conflicts
if [[ -z "${FOUND_PR_NUMBERS}" ]]
then
    echo "No conflicts found!"
else
    # Bash doesn't exports arrays, so we have to convert it from string
    readarray -t pr_array <<<"$FOUND_PR_NUMBERS"

    for pr in "${pr_array[@]}"
    do
        echo -e "PR $pr"
    done
fi

# By default this condition is false and it won't run, unless
# a conflict has been detected, and incremented the variable count
if [[ "${CONFLICT_PR_AMOUNT}" -gt 0 ]]; then
    echo "--- DEBUG START ---"
    
    # TESTING IF GIT DETECTS A CONFLICT
    # I MODIFIED TWO LINES!

    echo "FOUND_PR_AMOUNT: ${FOUND_PR_AMOUNT}"
    echo "FOUND_PR_NUMBERS: ${FOUND_PR_NUMBERS}"

    echo "--- DEBUG END ---"
    # Exports comment parts to be assembled in comment.sh
    export CHECK_CONFLICTS_LINE="| :heavy_multiplication_x: | **${CONFLICT_PR_AMOUNT}** conflict(s) detected among them |"
    export CHECK_CONFLICTS_DETAILS="check_conflicts.sh DETAILS (TODO)"
fi
