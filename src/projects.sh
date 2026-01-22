
github_project_issue_parse_project_url() {
  local url="$1"
  local owner_type owner_name project_number

  # Format: https://github.com/users/{username}/projects/{number}
  # Format: https://github.com/orgs/{orgname}/projects/{number}
  if [[ "$url" =~ github\.com/(users|orgs)/([^/]+)/projects/([0-9]+) ]]; then
    owner_type="${BASH_REMATCH[1]}"
    owner_name="${BASH_REMATCH[2]}"
    project_number="${BASH_REMATCH[3]}"
    echo "$owner_type $owner_name $project_number"
  else
    echo "Invalid project URL format" >&2
    return 1
  fi
}

github_project_issue_get_project_id() {
  local github_token="$1"
  local project_url="$2"
  local owner_type owner_name project_number
  local project_id query_response query

  # Parse URL
  read -r owner_type owner_name project_number <<< "$(github_project_issue_parse_project_url "$project_url")"

  if [ -z "$owner_name" ] || [ -z "$project_number" ]; then
    echo "Failed to parse project URL" >&2
    return 1
  fi

  # Determine the query based on owner type
  if [ "$owner_type" = "users" ]; then
    query="query(\$owner: String!, \$number: Int!) { user(login: \$owner) { projectV2(number: \$number) { id } } }"
  else
    query="query(\$owner: String!, \$number: Int!) { organization(login: \$owner) { projectV2(number: \$number) { id } } }"
  fi

  query_response=$(
    curl -s -H "Authorization: Bearer $github_token" \
      -H "Content-Type: application/json" \
      -X POST \
      -d '{
        "query": "'"$query"'",
        "variables": {
          "owner": "'"$owner_name"'",
          "number": '"$project_number"'
        }
      }' \
      https://api.github.com/graphql
  )

  # Extract the ID based on owner type
  if [ "$owner_type" = "users" ]; then
    project_id=$(echo "$query_response" | jq -r '.data.user.projectV2.id')
  else
    project_id=$(echo "$query_response" | jq -r '.data.organization.projectV2.id')
  fi

  if [ "$project_id" = "null" ] || [ -z "$project_id" ]; then
    echo "Failed to get project ID. Response: $query_response" >&2
    return 1
  fi

  echo "$project_id"
}

