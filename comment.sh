#!/bin/bash

# --- DEBUG DATA ---
# OWNER=mateusabelli
# REPOSITORY=pr-tracker
# PR_NUMBER=4

COMPOSED_COMMENT="| Checks | PR Tracker Status |\n|:--:|:---|\n"
COMPOSED_DETAIL=""

if [ -z "${CHECK_PULLS_LINE}" ]
then
    COMPOSED_COMMENT+="| :white_check_mark: | **0** pull request(s) found with the same file(s) |\n"
else
    COMPOSED_DETAIL+="\n\n#### Check Pulls\n\n"

    COMPOSED_COMMENT+="${CHECK_PULLS_LINE}\n"
    COMPOSED_DETAIL+="${CHECK_PULLS_DETAILS}\n"
fi

if [ -z "${CHECK_CONFLICTS_LINE}" ]
then
    COMPOSED_COMMENT+="| :white_check_mark: | **0** conflict(s) detected among them |\n"
else
    COMPOSED_COMMENT+="${CHECK_CONFLICTS_LINE}\n"
    COMPOSED_DETAIL+="${CHECK_CONFLICTS_DETAILS}\n"
fi

if [ -z "${CHECK_HUNKS_LINE}" ]
then
    COMPOSED_COMMENT+="| :white_check_mark: | **0** similar hunk(s) spotted |\n"
else
    COMPOSED_COMMENT+="${CHECK_HUNKS_LINE}\n"
    COMPOSED_DETAIL+="${CHECK_HUNKS_DETAILS}\n"
fi

COMPOSED_DETAIL+="\n> **Note** Last update at $(node -e "console.log(new Date().toUTCString())")<br>Learn more about [PR Tracker ↗︎](https://github.com/mateusabelli/pr-tracker)\n"

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