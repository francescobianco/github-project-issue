
module issues
module projects

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
    *)
      echo "Unknown command: $1" 1
      ;;
  esac
}