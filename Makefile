# VFox Makefile
.PHONY: build build-dev clean install test lint fmt help

# Build variables
BINARY_NAME=vfox
MAIN_FILE=main.go
LDFLAGS=-ldflags="-s -w"
CGO_ENABLED=0

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the vfox binary (production)
	CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -o $(BINARY_NAME) $(MAIN_FILE)

build-dev: ## Build the vfox binary (development)
	CGO_ENABLED=$(CGO_ENABLED) go build -o $(BINARY_NAME) $(MAIN_FILE)

install: build ## Install vfox to /usr/local/bin
	sudo cp $(BINARY_NAME) /usr/local/bin/

clean: ## Clean build artifacts
	rm -f $(BINARY_NAME)
	go clean -cache

test: ## Run tests
	CGO_ENABLED=$(CGO_ENABLED) go test -v ./...

lint: ## Run linter
	golangci-lint run

fmt: ## Format code
	go fmt ./...

deps: ## Download dependencies
	go mod download
	go mod tidy

ci: ## CI pipeline
	$(MAKE) fmt
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) build

release: ## Build release binaries for all platforms
	@echo "Building release binaries..."
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -o $(BINARY_NAME)-darwin-amd64 $(MAIN_FILE)
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -o $(BINARY_NAME)-darwin-arm64 $(MAIN_FILE)
	GOOS=linux GOARCH=amd64 CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -o $(BINARY_NAME)-linux-amd64 $(MAIN_FILE)
	GOOS=linux GOARCH=arm64 CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -o $(BINARY_NAME)-linux-arm64 $(MAIN_FILE)
	GOOS=windows GOARCH=amd64 CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -o $(BINARY_NAME)-windows-amd64.exe $(MAIN_FILE)
	@echo "Release binaries built successfully"

# Development shortcuts
b: build ## Shortcut for build
bd: build-dev ## Shortcut for build-dev
t: test ## Shortcut for test
c: clean ## Shortcut for clean