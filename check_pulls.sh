#!/bin/bash

# --- DEBUG DATA ---
# OWNER=mateusabelli
# REPOSITORY=pr-tracker
# PR_NUMBER=2

MAX_FILE_CHANGES=100
MAX_PR_COUNT=100

FOUND_PR_AMOUNT=null
FOUND_PR_NUMBERS=null

pr_data=$(gh api graphql -f query="
query {
    rateLimit {
        remaining
    }
    repository(owner: \"${OWNER}\", name: \"${REPOSITORY}\") {
        pullRequests(states: OPEN, last: ${MAX_PR_COUNT}) {
            nodes {
                number
                files(last: ${MAX_FILE_CHANGES}) {
                    nodes {
                        path
                    }
                }
            }
        }
        pullRequest(number: ${PR_NUMBER}) {
            files(last: ${MAX_FILE_CHANGES}) {
                nodes {
                    path
                }
            }
        }
    }
}")

pr_files_changed=$(echo "${pr_data}" | jq '.data.repository.pullRequest')
all_files_changed=$(echo "${pr_data}" | jq '.data.repository.pullRequests.nodes')
rate_limit_remaining=$(echo "${pr_data}" | jq '.data.rateLimit.remaining')

echo "--- DEBUG START ---"

echo "Remaining API calls: ${rate_limit_remaining}"
echo "${pr_files_changed}"

# echo "--- DEBUG END ---"

JS_CODE="
const pathsToSearch = [...${pr_files_changed}.files.nodes].map(file => file.path);
const matchedData = [];

${all_files_changed}?.forEach((pr) => {
    const matchedPaths = [];

    pr.files.nodes.forEach((node) => {
        if (pathsToSearch.includes(node.path)) {
            matchedPaths.push(node.path);
        }
    })

    if (matchedPaths.length > 0 && pr.number !== ${PR_NUMBER}) {
        matchedData.push({
            number: pr.number,
            files: matchedPaths
        })
    }
});

const result = matchedData?.map(data => data.number).join('\n');

if (result?.length > 0) {
    console.log(result);
}
"
FOUND_PR_NUMBERS="$(node -e "${JS_CODE}")"

if [[ ${#FOUND_PR_NUMBERS[@]} -eq 1 && ( -z "${FOUND_PR_NUMBERS[0]}" || "${FOUND_PR_NUMBERS[0]}" = " " ) ]]; then
    FOUND_PR_AMOUNT=0
else
    FOUND_PR_AMOUNT=${#FOUND_PR_NUMBERS[@]}
fi

if [[ "${FOUND_PR_AMOUNT}" -gt 0 ]]; then
    echo "FOUND_PR_AMOUNT: ${FOUND_PR_AMOUNT}"
    echo "FOUND_PR_NUMBERS: ${FOUND_PR_NUMBERS}"

    echo "--- DEBUG END ---"

    export FOUND_PR_AMOUNT=${FOUND_PR_AMOUNT}
    export FOUND_PR_NUMBERS=${FOUND_PR_NUMBERS}

    export CHECK_PULLS_LINE="| :ballot_box_with_check: | **${FOUND_PR_AMOUNT}** pull request(s) found with the same file(s) |"
    export CHECK_PULLS_DETAILS=":ballot_box_with_check: Found other Pull Request(s) with the same file(s) being modified (TODO)"
fi