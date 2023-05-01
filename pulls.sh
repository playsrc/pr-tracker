#!/bin/bash

# Query the API rateLimit
rate_limit_remaining=$(gh api graphql -f query="
query {
    rateLimit {
        remaining
    }
}
" | jq '.data.rateLimit.remaining')

# Get the number of PRs
pr_count=$(gh api graphql -f query="
query {
    repository(owner: \"${OWNER}\", name: \"${NAME}\") {
        pullRequests(states: OPEN) {
            totalCount
        }
    }
}
" | jq '.data.repository.pullRequests.totalCount')

echo "Remaining API calls: ${rate_limit_remaining}"
echo "Pull Requests: ${pr_count}"