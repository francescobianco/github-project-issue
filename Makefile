
push:
	@git add .
	@git commit -m "update" || true
	@git push origin main

test-id:
	@mush run -- id https://github.com/users/francescobianco/projects/60

test-new:
	@mush run -- new https://github.com/users/francescobianco/projects/60 test test

test-new-stdin:
	@cat tests/fixtures/complex-body.md | mush run -- new https://github.com/users/francescobianco/projects/60 "Complex Body Test" -