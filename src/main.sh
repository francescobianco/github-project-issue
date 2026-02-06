
module issues
module projects

usage() {
  echo "Usage: github-project-issue [COMMAND] [OPTIONS]"
  echo ""
  echo "Available options"
  echo "  -V, --version  Print version info and exit"
  echo "  -h, --help     Print help information"
  echo ""
  echo "Available commands"
  echo "  id     Get the project ID from a project URL"
  echo "  new    Create a new issue in a project using a project URL, title, and body"
  echo "  close  Close an issue using its URL"
  echo "  add    Add an existing issue to a project"
}

main() {
  local github_token

  while [ $# -gt 0 ]; do
    case "$1" in
      -*)
        case "$1" in
          -o|--output)
            echo "Handling $1 with value: $2"
            shift
            ;;
          *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        esac
        ;;
      *)
        break
        ;;
    esac
    shift
  done || true

  if [ -n "$GITHUB_TOKEN" ]; then
    github_token=$GITHUB_TOKEN
  fi

  if [ "$#" -eq 0 ]; then
    echo "No arguments supplied" 1
  fi

  case "$1" in
    id)
      github_project_issue_get_project_id "$github_token" "$2"
      ;;
    new)
      github_project_issue_new "$github_token" "$2" "$3" "$4"
      ;;
    close)
      github_project_issue_close "$github_token" "$2"
      ;;
    add)
      echo "Adding issue to project with URL: $2 and issue URL: $3"
      github_project_issue_add "$github_token" "$2" "$3"
      ;;
    *)
      echo "Unknown command: $1" 1
      ;;
  esac
}

