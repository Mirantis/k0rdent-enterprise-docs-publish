.PHONY: help setup serve clean

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Setup Python virtual environment and install dependencies
	python3 -m venv ./mkdocs-env
	./mkdocs-env/bin/pip install -r requirements.txt
	@echo "Setup complete! Use 'make serve' to start the documentation server."

serve: ## Serve documentation locally (requires setup)
	@if [ ! -d "./mkdocs-env" ]; then \
		echo "Virtual environment not found. Running setup first..."; \
		make setup; \
	fi
	./mkdocs-env/bin/mkdocs serve

clean: ## Clean up virtual environment
	rm -rf ./mkdocs-env