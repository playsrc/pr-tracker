#!/bin/bash

# --- DEBUG DATA ---
# OWNER=mateusabelli
# REPOSITORY=pr-tracker
# PR_NUMBER=4

# Variables initialization
COMPOSED_COMMENT="| Checks | PR Tracker Status |\n|:--:|:---|\n"
COMPOSED_DETAIL=""

# When a PR is found, check_pulls.sh exports FOUND_PR_AMOUNT,
# if it is greater than 0, compose a detailed comment, else compose a simple comment.
if [[ "${FOUND_PR_AMOUNT}" -gt 0 ]]
then
    # Table comment entry (not ok)
    COMPOSED_COMMENT+="| :ballot_box_with_check: | **${FOUND_PR_AMOUNT}** pull request(s) found with the same file(s) |\n"

    # Details comment section title
    COMPOSED_DETAIL+="\n\n### :ballot_box_with_check: Check Pulls\n\n"

    # Details comment section content
    readarray -t pr_number_array<<<"$FOUND_PR_NUMBERS"
    readarray -t pr_file_array<<<"$(echo "$FOUND_PR_FILES" | tr ' ' '\n')"
    readarray -t pr_title_array<<<"$(echo "$FOUND_PR_TITLES" | tr ' ' '\n')"
    arr_index=0

    COMPOSED_DETAIL+="Found other Pull Request(s) with the same file(s) being modified\n\n"
    COMPOSED_DETAIL+="| Number | Pull Request Title |\n|:--:|:---|\n"
    COMPOSED_DETAIL+="$(
    for pr in "${pr_number_array[@]}"
    do
        if [ -z "$pr" ]; then
            return
        else
            echo -e "| #$pr | ${pr_title_array[arr_index]}) |\n"
            ((arr_index++))
        fi
    done
    )"

    COMPOSED_DETAIL+="\n\n**File(s) modified in the PR(s) above:**\n\n"
    COMPOSED_DETAIL+="$(
    for file in "${pr_file_array[@]}"
    do
        if [ -z "$file" ]; then
            return
        else
            echo -e "- \`$file\`"
        fi
    done
    )"
else
    # Table comment entry (ok)
    COMPOSED_COMMENT+="| :white_check_mark: | **0** pull request(s) found with the same file(s) |\n"
fi

# When a conflict is found, check_conflicts.sh exports CONFLICT_PR_AMOUNT,
# if it is greater than 0, compose a detailed comment, else compose a simple comment.
if [[ "${CONFLICT_PR_AMOUNT}" -gt 0 ]]
then
    # Table comment entry (not ok)
    COMPOSED_COMMENT+="| **${CONFLICT_PR_AMOUNT}** conflict(s) detected among them |\n"

    # Details comment section title
    COMPOSED_DETAIL+="\n\n### :heavy_multiplication_x: Check Conflicts\n\n"

    # Details comment section content
    readarray -t pr_number_array<<<"$FOUND_PR_NUMBERS"
    readarray -t pr_branch_array<<<"$FOUND_PR_BRANCHES"
    arr_index=0

    COMPOSED_DETAIL+="Detected merge conflicts with other Pull Request(s)"
    COMPOSED_DETAIL+="| Number | Diff Link |\n|:--:|:---|\n"
    COMPOSED_DETAIL+=$(for pr in "${pr_number_array[@]}";
    do \
        echo -e "| #$pr | [#$PR_NUMBER .. #$pr ↗︎](https://github.com/${OWNER}/${REPOSITORY}/compare/$PR_BRANCH_NAME...${pr_branch_array[arr_index]}) |\n"
        ((arr_index++))
    done)
else
    # Table comment entry (ok)
    COMPOSED_COMMENT+="| :white_check_mark: | **0** conflict(s) detected among them |\n"
fi

# NOTE: Feature temporarily disabled, see check_hunks.sh
# if [ -z "${CHECK_HUNKS_LINE}" ]
# then
#     COMPOSED_COMMENT+="| :white_check_mark: | **(TODO)** duplicated hunk(s) spotted |\n"
# else
#     COMPOSED_DETAIL+="\n\n#### Check Hunks\n\n"

#     COMPOSED_COMMENT+="${CHECK_HUNKS_LINE}\n"
#     COMPOSED_DETAIL+="${CHECK_HUNKS_DETAILS}\n"
# fi

COMPOSED_DETAIL+="\n\n> **Note** Last update at $(node -e "console.log(new Date().toUTCString())")<br>Learn more about [PR Tracker ↗︎](https://github.com/mateusabelli/pr-tracker)\n"

# echo "--- DEBUG START ---"

# echo -e "${COMPOSED_COMMENT}"
# echo -e "
# <details>
# <summary>Details</summary>
# ${COMPOSED_DETAIL}
# </details>"

# echo "--- DEBUG END ---"

gh api -X POST \
https://api.github.com/repos/"${OWNER}"/"${REPOSITORY}"/issues/"${PR_NUMBER}"/comments \
-f body="$(
echo -e "${COMPOSED_COMMENT}"
echo -e "
<details>
<summary>Details</summary>
${COMPOSED_DETAIL}
</details>"
)"