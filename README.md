# github-project-issue

A lightweight command-line tool for creating draft issues in GitHub Projects using the GraphQL API v2.

## Why This Tool?

GitHub Projects API v2 (GraphQL-based) is **constantly evolving**. The API surface, available fields, and mutation schemas undergo frequent changes as GitHub continues to develop and improve the Projects feature.

For this reason, we chose to create a **standalone, independent tool** that:

- **Is easily testable** in isolation, without complex CI/CD dependencies
- **Can be quickly updated** when API changes occur
- **Provides a clean interface** for integration into GitHub Actions or other automation workflows
- **Keeps complexity contained** rather than embedded directly in workflow files

This approach allows you to validate and debug the GitHub Projects integration independently before incorporating it into your CI/CD pipelines.

## Features

- Create draft issues in GitHub Projects (both user and organization projects)
- Simple CLI interface
- Supports multi-line body content via stdin
- Proper JSON escaping for special characters, unicode, and code blocks
- Minimal dependencies (just `curl`, `jq`, and `bash`)

## Installation

### Prerequisites

- `bash` (with regex support)
- `curl`
- `jq`
- A GitHub Personal Access Token with `project` scope

### Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/github-project-issue.git
cd github-project-issue

# Build the release binary
make build

# Install (optional)
make install
```

The compiled binary will be available at `bin/github-project-issue`.

## Usage

### Set up authentication

```bash
export GITHUB_TOKEN="your_github_personal_access_token"
```

### Get Project ID

Retrieve the GraphQL ID of a GitHub Project:

```bash
github-project-issue id "https://github.com/users/USERNAME/projects/1"
# or for organizations
github-project-issue id "https://github.com/orgs/ORGNAME/projects/1"
```

### Create a Draft Issue

```bash
github-project-issue new "https://github.com/users/USERNAME/projects/1" "Issue Title" "Issue body content"
```

### Create a Draft Issue with Multi-line Body

For complex body content, use stdin:

```bash
cat << 'EOF' | github-project-issue new "https://github.com/users/USERNAME/projects/1" "Issue Title" -
## Description

This is a multi-line body with:
- Markdown formatting
- Code blocks
- Special characters: "quotes", 'apostrophes', \backslashes\

```code
function example() {
    return true;
}
```
EOF
```

Or from a file:

```bash
cat body.md | github-project-issue new "https://github.com/orgs/ORGNAME/projects/1" "Issue Title" -
```

## Integration with GitHub Actions

Once tested locally, you can integrate this tool into your GitHub Actions workflows:

```yaml
- name: Create Project Issue
  env:
    GITHUB_TOKEN: ${{ secrets.PROJECT_TOKEN }}
  run: |
    ./bin/github-project-issue new \
      "https://github.com/orgs/myorg/projects/1" \
      "Automated Issue: ${{ github.event.pull_request.title }}" \
      "Created from PR #${{ github.event.pull_request.number }}"
```

## Project Structure

```
github-project-issue/
├── src/
│   ├── main.sh        # Entry point & CLI routing
│   ├── projects.sh    # Project URL parsing & ID resolution
│   └── issues.sh      # Draft issue creation
├── bin/               # Compiled executable
├── tests/fixtures/    # Test fixtures
├── Makefile           # Build automation
├── Manifest.toml      # Mush package configuration
└── LICENSE            # MIT License
```

## Development

### Running Tests

```bash
# Test project ID retrieval
make test-id

# Test issue creation
make test-new

# Test with complex body from stdin
make test-new-stdin
```

### Build System

This project uses [Mush](https://github.com/javanile/mush) as its build system, which compiles multiple shell script modules into a single executable.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

Francesco Bianco ([@francescobianco](https://github.com/francescobianco))