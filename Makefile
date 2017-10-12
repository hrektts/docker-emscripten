all: build

build:
	@docker build --build-arg version=1.37.21 -t hrektts/emscripten:latest .

release: build
	@docker tag hrektts/emscripten:latest hrektts/emscripten:1.37.21
