# BywordEditor — developer shortcuts for Swift Package Manager on macOS

SWIFT      := xcrun swift
PACKAGE    := Package.swift
EXECUTABLE := BywordEditor

.PHONY: help build test run clean xcode

.DEFAULT_GOAL := help

help: ## Show available targets
	@echo "BywordEditor — available targets:"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo ""

build: ## Build the project (xcrun swift build)
	$(SWIFT) build

test: ## Run unit tests (xcrun swift test)
	$(SWIFT) test

run: build ## Build and run the BywordEditor executable
	@bin_dir="$$($(SWIFT) build --show-bin-path)"; \
	echo "Launching $$bin_dir/$(EXECUTABLE)…"; \
	exec "$$bin_dir/$(EXECUTABLE)"

clean: ## Remove build artifacts (swift package clean)
	$(SWIFT) package clean

xcode: ## Open Package.swift in Xcode
	open $(PACKAGE)

release-local: ## Build versioned .app zip locally (VERSION=1.0.0 make release-local)
	chmod +x Scripts/build-app.sh
	./Scripts/build-app.sh $(if $(VERSION),$(VERSION),$(shell cat VERSION | tr -d '[:space:')) $(if $(ARCH),$(ARCH),arm64)
