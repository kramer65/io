PACKAGES=$(shell go list ./... | grep -v /vendor)

help:   ## Print help text.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install:  # Install depencies.
	@go get -u github.com/stretchr/testify/assert
	@go get -u golang.org/x/exp/io/i2c
	@go get -u golang.org/x/exp/io/i2c/driver
	@go get -u golang.org/x/exp/io/spi
	@go get -u golang.org/x/exp/io/spi/driver

lint:   ## Check code using various linters and static checkers.
	@echo "Running gofmt..."
	@gofmt -d $(shell find . -type f -name '*.go' -not -path "./vendor/*")

	@echo "Running go vet..."
	@for package in $(PACKAGES);  do \
	    go vet -v $$package || exit 1; \
	done

	@echo "Running golint..."
	@for package in $(PACKAGES); do \
	    golint -set_exit_status $$package || exit 1; \
	done

	@echo "Running errcheck..."
	@for package in $(PACKAGES); do \
	    errcheck -ignore 'Close' -ignoretests $$package || exit 1; \
	done

test:   ## Run unit tests and print test coverage.
	@touch .coverage.out
	@for package in $(PACKAGES); do \
	    go test -coverprofile .coverage.out $$package && go tool cover -func=.coverage.out || exit 1; \
	done


.PHONY: help install lint test
