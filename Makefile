all: build

build:
	@docker build -t hrektts/emscripten:latest .

release: build
	@docker build -t hrektts/emscripten:$(shell cat Dockerfile | \
		grep version | \
		sed -e 's/[^"]*"\([^"]*\)".*/\1/') .
