# Makefile for running tests from command line

PROJECT = macCANable.xcodeproj
SCHEME = "macCANable (All Tests)"
DESTINATION = platform=macOS,arch=x86_64

default:
	@echo
	@echo "Targets:"
	@echo "  test ....... run unit tests"
	@echo "  test-ui .... run only UI tests"
	@echo "  test-all ... run all tests"
	@echo

test:
	xcodebuild test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination $(DESTINATION) \
	-only-testing macCANableTests

test-ui:
	xcodebuild test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination $(DESTINATION) \
	-only-testing macCANableUITests

test-all:
	xcodebuild test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination $(DESTINATION)
