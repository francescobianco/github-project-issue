
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
