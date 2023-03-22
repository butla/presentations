.PHONY: build
build:
	poetry run darkslide slides.md --theme void_theme

.PHONY: build_continuously
build_continuously:
	# `darkslide -w` starts looping continuously
	fd '.rst|.md' | entr -c make build

.PHONY: setup_dev
setup_dev:
	poetry install
