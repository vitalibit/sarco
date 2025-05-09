.PHONY: build run test clean lint  dev  test-unit test-verbose test-coverage

# Include .env file if it exists (improved handling for comments)
ifneq (,$(wildcard .env))
include .env
endif

# Build and run settings
APP_NAME=kbot
CMD_PATH=./cmd/
BUILD_DIR=./build

# Migrations settings
MIGRATIONS_DIR=./migrations

# Test settings
TEST_PACKAGES?=./...
COVERAGE_FILE=coverage.out


build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@go build -o $(BUILD_DIR)/$(APP_NAME) .
	@chmod +x $(BUILD_DIR)/$(APP_NAME)
	@echo "Build completed: $(BUILD_DIR)/$(APP_NAME)"

run: build
	@echo "Running $(APP_NAME)..."
	TELE_TOKEN=$(TELE_TOKEN) $(BUILD_DIR)/$(APP_NAME) $(ARGS)

test: test-deps
	@echo "Running tests..."
	@go test -race $(TEST_PACKAGES)

test-verbose: test-deps
	@echo "Running tests in verbose mode..."
	@go test -v -race $(TEST_PACKAGES)

test-coverage: test-deps
	@echo "Running tests with coverage report..."
	@go test -race -coverprofile=$(COVERAGE_FILE) $(TEST_PACKAGES)
	@go tool cover -html=$(COVERAGE_FILE)
	@rm $(COVERAGE_FILE)

test-deps:
	@echo "Checking for testify dependency..."
	@if ! grep -q "github.com/stretchr/testify" go.mod; then \
		echo "Installing testify package..."; \
		go get github.com/stretchr/testify; \
	fi
	@go mod tidy

lint:
	@command -v golangci-lint > /dev/null || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "Running linter..."
	@golangci-lint run


setup: 
	@if [ -f .env ]; then \
		echo "A .env file already exists."; \
		read -p "Do you want to overwrite it? (y/n): " CONFIRM; \
		if [ "$$CONFIRM" != "y" ]; then \
			echo "Setup aborted."; \
			exit 1; \
		fi; \
	fi
	@if [ -f .env.example ]; then \
		echo "Creating .env file from .env.example..."; \
		cp .env.example .env; \
		echo ".env file created successfully. You may want to edit it with your specific values."; \
	else \
		echo "Error: .env.example file not found."; \
		exit 1; \
	fi
