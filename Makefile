# VERSION ?= $(shell git describe --tags --abbrev=0)
# NEW_VERSION ?= $(shell powershell -Command "$version = '$(VERSION)'; Write-Host 'Version: ' $version; $parts = $version.Split('.'); if ($parts.Length -ge 3) { $parts[2] = [int]$parts[2] + 1; } else { $parts += '0'; }; $parts -join '.'")

CURRENT_TAG := $(shell git describe --tags --abbrev=0 || echo "v0.0.0")
NEW_VERSION := $(shell powershell -NoProfile -Command "$$current = '$(CURRENT_TAG)'; $$parts = $$current.Split('.'); if ($$parts.Length -ge 3) { $$parts[2] = [int]$$parts[2] + 1; }; $$parts -join '.'")


# Rules
.PHONY: all
all: help

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  release     - Create a new release and tag it"
	@echo "  tag VERSION=<version> - Create a specific tag (default: $(NEW_VERSION))"
	@echo "  rollback VERSION=<version> - Rollback to a specific tag using git revert"

.PHONY: release
release:
	@echo "Creating a new release..."
	@make tag VERSION=$(NEW_VERSION)

.PHONY: tag
tag:
	@echo "Creating tag $(VERSION)..."
	@git tag -f $(VERSION) -m "Release $(VERSION)"
	@git push origin $(VERSION)

.PHONY: rollback
rollback:
	@if [ -z "$(VERSION)" ]; then echo "VERSION is required. Use: make rollback VERSION=<version>"; exit 1; fi
	@echo "Rolling back to tag $(VERSION) using git revert..."
	@git checkout main
	@git revert --no-commit $(VERSION)..HEAD
	@git commit -m "Revert changes from tag $(VERSION)"
	@git tag -f $(VERSION) -m "Reverted to $(VERSION)"
	@git push -u origin $(VERSION) --force
