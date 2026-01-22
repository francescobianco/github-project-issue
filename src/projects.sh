
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

  # Check for errors in the response
  local error_type error_message
  error_type=$(echo "$query_response" | jq -r '.errors[0].type // empty')
  error_message=$(echo "$query_response" | jq -r '.errors[0].message // empty')

  if [ -n "$error_type" ]; then
    case "$error_type" in
      NOT_FOUND)
        echo "Error: Project #$project_number not found for '$owner_name'." >&2
        echo "This could mean:" >&2
        echo "  - The project does not exist" >&2
        echo "  - You don't have permission to access this project" >&2
        echo "  - The project is private and your token lacks the 'project' or 'read:project' scope" >&2
        ;;
      FORBIDDEN)
        echo "Error: Access denied to project #$project_number." >&2
        echo "Your token doesn't have permission to access this project." >&2
        echo "Make sure your GITHUB_TOKEN has the 'project' scope." >&2
        ;;
      INSUFFICIENT_SCOPES)
        echo "Error: Insufficient token permissions." >&2
        echo "Your GITHUB_TOKEN needs the 'project' or 'read:project' scope." >&2
        ;;
      *)
        echo "Error: $error_type - $error_message" >&2
        ;;
    esac
    return 1
  fi

  # Extract the ID based on owner type
  if [ "$owner_type" = "users" ]; then
    project_id=$(echo "$query_response" | jq -r '.data.user.projectV2.id')
  else
    project_id=$(echo "$query_response" | jq -r '.data.organization.projectV2.id')
  fi

  if [ "$project_id" = "null" ] || [ -z "$project_id" ]; then
    echo "Error: Could not retrieve project ID." >&2
    echo "Unexpected response from GitHub API." >&2
    return 1
  fi

  echo "$project_id"
}

