
push:
	@git add .
	@git commit -m "update" || true
	@git push origin main

test-id:
	@mush run -- id https://github.com/users/francescobianco/projects/60

test-new:
	@mush run -- new https://github.com/users/francescobianco/projects/60 test test

test-new-stdin:
	@echo "This is the body from stdin.\nWith multiple lines." | mush run -- new https://github.com/users/francescobianco/projects/60 "Title from stdin test" -