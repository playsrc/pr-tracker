#!/bin/bash

echo "Checking Hunks..."

# Variables initialization
HUNKS_PR_COUNT=0

# check_pulls.sh exports two variables FOUND_PR_NUMBERS and FOUND_PR_AMOUNT
# if FOUND_PR_NUMBERS is empty, do nothing, else start checking the hunks
if [[ -z "${FOUND_PR_NUMBERS}" ]]
then
    echo "No PRs to scan for duplicates..."
else
    # Bash doesn't exports arrays, so we have to convert it from string
    readarray -t pr_array <<<"$FOUND_PR_NUMBERS"

    # Query the API for the hunks on the PR
    # the regex on the grep will return the following:
    # .github/workflows/test.yml  -1,4 +1,5   README.md  -1 +1,2
    PR_HUNKS=$(gh api \
    -H "Accept: application/vnd.github.diff" \
    /repos/"${OWNER}"/"${REPOSITORY}"/pulls/"${PR_NUMBER}" \
    | grep -oP "(---\sa\/\S+|(?<=\@\@)(.*?)(?=\@\@))")

    # Convert the result from the query to a valid Bash array
    readarray -t PR_HUNKS_RAW_ARRAY <<<"${PR_HUNKS}"

    # The JS code will format the array to merge the file name with
    # the change lines. This should allow for more precise checking.
    readarray -t PR_HUNKS_ARRAY <<<"$(node -e "
    formatedArray = \"${PR_HUNKS_RAW_ARRAY[*]}\"
        .split(/---\sa\//)
        .filter(item => item.length > 0);

    console.log(formatedArray.join('\n'));
    ")"

    echo "[DEBUG] PR_HUNKS_ARRAY: ${PR_HUNKS_ARRAY[*]}"

    # Loop through each PR found and fetch their diffs to compare and check
    # if there are duplicates with the hunks of the PR.
    for pr in "${pr_array[@]}"
    do
        echo "[DEBUG] Checking hunks on PR: $pr..."

        # Query the API for the hunks on each PR found
        # the regex on the grep will return the following:
        # .github/workflows/test.yml  -1,4 +1,5   README.md  -1 +1,2
        COMPARE_HUNKS=$(gh api \
        -H "Accept: application/vnd.github.diff" \
        /repos/"${OWNER}"/"${REPOSITORY}"/pulls/"${pr}" \
        | grep -oP "(---\sa\/\S+|(?<=\@\@)(.*?)(?=\@\@))")

        # Convert the result from the query to a valid Bash array
        readarray -t COMPARE_HUNKS_RAW_ARRAY <<<"${COMPARE_HUNKS}"

        # The JS code will format the array to merge the file name with
        # the change lines. This should allow for more precise checking.
        readarray -t COMPARE_HUNKS_ARRAY <<<"$(node -e "
        formatedArray = \"${COMPARE_HUNKS_RAW_ARRAY[*]}\"
            .split(/---\sa\//)
            .filter(item => item.length > 0);

        console.log(formatedArray.join('\n'));
        ")"

        echo "[DEBUG] COMPARE_HUNKS_ARRAY: ${COMPARE_HUNKS_ARRAY[*]}"

        # This loop will compare the hunks from the new PR with the ones
        # from the PRs found in the previous checks.
        for pr_hunk in "${PR_HUNKS_ARRAY[@]}"; do
            for compare_hunk in "${COMPARE_HUNKS_ARRAY[@]}"; do
                if [[ "$pr_hunk" == "$compare_hunk" ]]; then
                    echo "[DEBUG] Duplicate hunk found on PR $pr"
                    echo "[DEBUG] Details: $pr_hunk"
                    ((HUNKS_PR_COUNT++))
                fi
            done
        done

        # Sleep for 2 seconds to avoid suspicious behaviour
        echo "[DEBUG] Waiting 2 seconds..."
        sleep 2
    done
fi

# By default this condition is false and it won't run, unless
# a duplicated hunk has been detected, and incremented the variable count.
if [[ "${HUNKS_PR_COUNT}" -gt 0 ]]; then
    echo "[DEBUG] HUNKS_PR_COUNT: ${HUNKS_PR_COUNT}"

    # Exports comment parts to be assembled in comment.sh
    export CHECK_HUNKS_LINE="| :x: | **${HUNKS_PR_COUNT}** duplicated hunk(s) spotted |"
    export CHECK_HUNKS_DETAILS=":x: Spotted duplicated hunks (TODO)"
fi