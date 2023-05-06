#!/bin/bash

echo "Checking Pull Requests..."

# --- DEBUG DATA ---
# OWNER=mateusabelli
# REPOSITORY=pr-tracker
# PR_NUMBER=2

MAX_FILE_CHANGES=100
MAX_PR_COUNT=100

# Variables initialization
FOUND_PR_AMOUNT=0
FOUND_PR_NUMBERS=""

# This variable receives a JSON response from a GraphQL query
# to the GitHub API, using the gh cli command.
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

# Using jq for parsing the JSON response, we can assign to each
# variable, only their specific data.
pr_files_changed=$(echo "${pr_data}" | jq '.data.repository.pullRequest')
all_files_changed=$(echo "${pr_data}" | jq '.data.repository.pullRequests.nodes')
rate_limit_remaining=$(echo "${pr_data}" | jq '.data.rateLimit.remaining')

echo "[ DEBUG ] Remaining API calls: ${rate_limit_remaining}"
echo "[ DEBUG ] ${pr_files_changed}"

# This JavaScript code will check if the files changed on the current PR has
# also been changed on another open PR. If it does, it logs an array of entries.
JS_CODE="
// This variable receives the array of files changed on the PR
// and it maps through it to return a clean formatted output like this:
// ['file1.txt', 'dir/file2.txt', 'file3.txt']
const pathsToSearch = [...${pr_files_changed}.files.nodes].map(file => file.path);
const matchedData = [];

// Loop through the formatted array to find matching files, if it finds
// then, assigns the PR number and an array of the files matched to a variable.
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

// That .join('\n') at the end will convert
// an array like this [5, 6] to the following:
// 5
// 6
const result = matchedData?.map(data => data.number).join('\n');

// Logs the data to be exported, only if there are values in it.
if (result?.length > 0) {
    console.log(result);
}
"
# Assigns the returned result of the JavaScript code, or an empty string
FOUND_PR_NUMBERS="$(node -e "${JS_CODE}")"

# If the variable is empty, then set the found amount to zero, else set the amount
# to the length of the array of entries.
if [[ -z "${FOUND_PR_NUMBERS}" ]]; then
    FOUND_PR_AMOUNT=0
else
    # This will convert the string to an array so we can get it's length
    readarray -t pr_array <<<"$FOUND_PR_NUMBERS"
    FOUND_PR_AMOUNT=${#pr_array[@]}
fi

# By default this condition is false and it won't run, unless
# one or more pull request has been found.
if [[ "${FOUND_PR_AMOUNT}" -gt 0 ]]; then
    echo "[ DEBUG ] FOUND_PR_AMOUNT: ${FOUND_PR_AMOUNT}"
    echo "[ DEBUG ] FOUND_PR_NUMBERS: ${FOUND_PR_NUMBERS}"

    # Exports external variables to be used with other scripts
    # FOUND_PR_NUMBERS is exported as a string to be converted elsewhere.
    export FOUND_PR_AMOUNT=${FOUND_PR_AMOUNT}
    export FOUND_PR_NUMBERS=${FOUND_PR_NUMBERS}

    # Exports comment parts to be assembled in comment.sh
    export CHECK_PULLS_LINE="| :ballot_box_with_check: | **${FOUND_PR_AMOUNT}** pull request(s) found with the same file(s) |"
    export CHECK_PULLS_DETAILS=":ballot_box_with_check: Found other Pull Request(s) with the same file(s) being modified (TODO)"
fi