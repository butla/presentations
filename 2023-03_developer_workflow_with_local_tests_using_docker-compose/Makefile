.PHONY: build
build:
	npx slidev export --dark --output dev_workflow_with_local_tests_using_docker_compose_PL slides_pl.md
	npx slidev export --dark --output dev_workflow_with_local_tests_using_docker_compose_EN slides_en.md

.PHONY: run
run_pl:
	npx slidev slides_pl.md

run_en:
	npx slidev slides_en.md

.PHONY: setup_dev
setup_dev:
	# poetry install
	npm install
