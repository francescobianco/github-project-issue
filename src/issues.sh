
github_project_issue_new() {
  local github_token="$1"
  local project_url="$2"
  local title="$3"
  local body="$4"
  local project_id mutation_response item_id

  # If body is "-", read from stdin
  if [ "$body" = "-" ]; then
    body=$(cat)
  fi

  # Get the project ID from URL
  project_id=$(github_project_issue_get_project_id "$github_token" "$project_url")

  if [ -z "$project_id" ]; then
    echo "Failed to get project ID" >&2
    return 1
  fi

  # Build JSON payload with jq for proper escaping
  local payload
  payload=$(jq -n \
    --arg projectId "$project_id" \
    --arg title "$title" \
    --arg body "$body" \
    '{
      "query": "mutation($projectId: ID!, $title: String!, $body: String) { addProjectV2DraftIssue(input: {projectId: $projectId, title: $title, body: $body}) { projectItem { id } } }",
      "variables": {
        "projectId": $projectId,
        "title": $title,
        "body": $body
      }
    }')

  # Create the draft item using GraphQL mutation
  mutation_response=$(
    curl -s -H "Authorization: Bearer $github_token" \
      -H "Content-Type: application/json" \
      -X POST \
      -d "$payload" \
      https://api.github.com/graphql
  )

  # Extract the created item ID
  item_id=$(echo "$mutation_response" | jq -r '.data.addProjectV2DraftIssue.projectItem.id')

  if [ "$item_id" = "null" ] || [ -z "$item_id" ]; then
    echo "Failed to create draft. Response: $mutation_response" >&2
    return 1
  fi

  echo "$item_id"
}

github_project_issue_parse_issue_url() {
  local url="$1"
  local owner repo issue_number

  # Format: https://github.com/{owner}/{repo}/issues/{number}
  if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/issues/([0-9]+) ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
    issue_number="${BASH_REMATCH[3]}"
    echo "$owner $repo $issue_number"
  else
    echo "Invalid issue URL format" >&2
    return 1
  fi
}

github_project_issue_get_issue_node_id() {
  local github_token="$1"
  local issue_url="$2"
  local owner repo issue_number
  local response node_id

  # Parse URL
  read -r owner repo issue_number <<< "$(github_project_issue_parse_issue_url "$issue_url")"

  if [ -z "$owner" ] || [ -z "$repo" ] || [ -z "$issue_number" ]; then
    echo "Failed to parse issue URL" >&2
    return 1
  fi

  # Get issue details from REST API
  response=$(
    curl -s \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: Bearer $github_token" \
      "https://api.github.com/repos/$owner/$repo/issues/$issue_number"
  )

  node_id=$(echo "$response" | jq -r '.node_id')

  if [ "$node_id" = "null" ] || [ -z "$node_id" ]; then
    echo "Failed to get issue node ID. Response: $response" >&2
    return 1
  fi

  echo "$node_id"
}

github_project_issue_add() {
  local github_token="$1"
  local issue_url="$2"
  local project_url="$3"
  local content_id project_id mutation_response item_id

  # Get the issue's node ID
  content_id=$(github_project_issue_get_issue_node_id "$github_token" "$issue_url")

  if [ -z "$content_id" ]; then
    echo "Failed to get issue node ID" >&2
    return 1
  fi

  # Get the project ID
  project_id=$(github_project_issue_get_project_id "$github_token" "$project_url")

  if [ -z "$project_id" ]; then
    echo "Failed to get project ID" >&2
    return 1
  fi

  # Build JSON payload with jq for proper escaping
  local payload
  payload=$(jq -n \
    --arg projectId "$project_id" \
    --arg contentId "$content_id" \
    '{
      "query": "mutation($projectId: ID!, $contentId: ID!) { addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) { item { id } } }",
      "variables": {
        "projectId": $projectId,
        "contentId": $contentId
      }
    }')

  # Add the issue to the project using GraphQL mutation
  mutation_response=$(
    curl -s -H "Authorization: Bearer $github_token" \
      -H "Content-Type: application/json" \
      -X POST \
      -d "$payload" \
      https://api.github.com/graphql
  )

  # Extract the created item ID
  item_id=$(echo "$mutation_response" | jq -r '.data.addProjectV2ItemById.item.id')

  if [ "$item_id" = "null" ] || [ -z "$item_id" ]; then
    echo "Failed to add issue to project. Response: $mutation_response" >&2
    return 1
  fi

  echo "$item_id"
}

github_project_issue_close() {
  local github_token="$1"
  local issue_url="$2"
  local owner repo issue_number
  local response

  # Parse URL
  read -r owner repo issue_number <<< "$(github_project_issue_parse_issue_url "$issue_url")"

  if [ -z "$owner" ] || [ -z "$repo" ] || [ -z "$issue_number" ]; then
    echo "Failed to parse issue URL" >&2
    return 1
  fi

  # Close the issue using REST API
  response=$(
    curl -s -X PATCH \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: Bearer $github_token" \
      -d '{"state":"closed","state_reason":"completed"}' \
      "https://api.github.com/repos/$owner/$repo/issues/$issue_number"
  )

  # Check if successful by looking for the state in response
  local state
  state=$(echo "$response" | jq -r '.state')

  if [ "$state" = "closed" ]; then
    echo "Issue #$issue_number closed successfully"
  else
    echo "Failed to close issue. Response: $response" >&2
    return 1
  fi
}

