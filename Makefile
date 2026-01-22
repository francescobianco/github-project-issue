
build:
	@mush build --release

install:
	@mush install --path .

push:
	@git add .
	@git commit -m "update" || true
	@git push origin main

release: build push
	@echo "Release completed."

test-id:
	@mush run -- id https://github.com/users/francescobianco/projects/60

test-new:
	@mush run -- new https://github.com/users/francescobianco/projects/60 test test

test-new-stdin:
	@cat tests/fixtures/complex-body.md | mush run -- new https://github.com/users/francescobianco/projects/60 "Complex Body Test" -

test-close: build
	@mush run -- close https://github.com/francescobianco/github-project-issue/issues/1
	@./bin/github-project-issue close https://github.com/francescobianco/github-project-issue/issues/1
