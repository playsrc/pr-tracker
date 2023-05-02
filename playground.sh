#!/bin/bash

OWNER=mateusabelli
REPOSITORY=pr-tracker
PR_NUMBER=3
MAX_FILE_CHANGES=100
MAX_PR_COUNT=100

FOUND_PR_AMOUNT=0
FOUND_PR_NUMBERS=()

# Query the API rateLimit
rate_limit_remaining=$(gh api graphql -f query="
query {
    rateLimit {
        remaining
    }
}
" | jq '.data.rateLimit.remaining')

echo "Remaining API calls: ${rate_limit_remaining}"

pr_data=$(gh api graphql -f query="
query {
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

echo "${pr_files_changed}"

echo "----"

JS_CODE="
const pathsToSearch = [...${pr_files_changed}.files.nodes].map(file => file.path)
const matchedData = [];

${all_files_changed}.forEach((pr) => {
  const matchedPaths = [];

  pr.files.nodes.forEach((node) => {
    if (pathsToSearch.includes(node.path)) {
      matchedPaths.push(node.path);
    }
  });

  if (matchedPaths.length > 0 && pr.number !== ${PR_NUMBER}) {
    matchedData.push({
      number: pr.number,
      files: matchedPaths
    });
  }
});

console.log(matchedData.map(data => data.number).join('\n'))
"
readarray -t FOUND_PR_NUMBERS <<<"$(node -e "$JS_CODE")"

FOUND_PR_AMOUNT=${#FOUND_PR_NUMBERS[@]}

echo "FOUND PR" "${FOUND_PR_NUMBERS[@]}"
echo "AMOUNT" "${FOUND_PR_AMOUNT}"