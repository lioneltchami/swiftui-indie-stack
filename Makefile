.PHONY: build test lint lint-fix format format-check clean help beta certificates

# Default target
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the iOS app for simulator
	cd ios && xcodebuild -project MyApp.xcodeproj \
		-scheme MyApp \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-quiet \
		build

test: ## Run unit tests
	cd ios && xcodebuild test \
		-project MyApp.xcodeproj \
		-scheme MyApp \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-enableCodeCoverage YES \
		-quiet

lint: ## Run SwiftLint
	swiftlint lint

lint-fix: ## Run SwiftLint with auto-fix
	swiftlint lint --fix

format: ## Run SwiftFormat
	swiftformat ios/Sources/

format-check: ## Check formatting without modifying files
	swiftformat ios/Sources/ --lint

clean: ## Clean Xcode derived data
	cd ios && xcodebuild clean -project MyApp.xcodeproj -scheme MyApp
	rm -rf ~/Library/Developer/Xcode/DerivedData/MyApp-*

beta: ## Build and deploy to TestFlight via Fastlane
	cd ios && fastlane beta

certificates: ## Sync code signing certificates via Fastlane Match
	cd ios && fastlane certificates
