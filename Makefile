# Flutter Keypad Package Makefile

# Define the Flutter command
FLUTTER := flutter

# Default target
all: analyze test build

# Analyze the code for issues
analyze:
	$(FLUTTER) analyze

# Run tests
test:
	$(FLUTTER) test

# Build the package
build:
	$(FLUTTER) pub get
	$(FLUTTER) build

# Publish the package to pub.dev (use with caution!)
publish:
	$(FLUTTER) pub publish --dry-run
	$(FLUTTER) pub publish

# Clean build artifacts
clean:
	$(FLUTTER) clean

# Run the example project (if available)
run:
	cd example && $(FLUTTER) run
