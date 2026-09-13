PROJECT            := Snoopy.AI/Snoopy.AI.xcodeproj
SCHEME             := Snoopy.AI
CONFIGURATION      := Debug
BUNDLE_ID          := com.glroland.Snoopy-AI
APP_NAME           := Snoopy.AI.app
DERIVED_DATA       := $(CURDIR)/build/DerivedData

# Override on the command line if these aren't installed, e.g.:
#   make run-iphone IPHONE_SIMULATOR="iPhone 16"
IPHONE_SIMULATOR   ?= iPhone 17
IPAD_SIMULATOR     ?= iPad Pro 13-inch (M5)

MACOS_APP_PATH     := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/$(APP_NAME)
IPHONE_APP_PATH    := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)-iphonesimulator/$(APP_NAME)
IPAD_APP_PATH      := $(IPHONE_APP_PATH)

.DEFAULT_GOAL := help

.PHONY: help clean build test \
	build-macos build-iphone build-ipad \
	run run-macos run-iphone run-ipad

help:
	@echo "Targets:"
	@echo "  make clean        Remove build output and package caches"
	@echo "  make build        Build for macOS, iPhone Simulator, and iPad Simulator"
	@echo "  make test         Run the SnoopyCore unit test suite"
	@echo "  make run          Build and launch on macOS, iPhone Simulator, and iPad Simulator"
	@echo "  make build-macos  Build the macOS app"
	@echo "  make build-iphone Build for the iPhone Simulator"
	@echo "  make build-ipad   Build for the iPad Simulator"
	@echo "  make run-macos    Build and launch the macOS app"
	@echo "  make run-iphone   Build, boot, install, and launch on the iPhone Simulator"
	@echo "  make run-ipad     Build, boot, install, and launch on the iPad Simulator"

clean:
	xcodebuild clean -project "$(PROJECT)" -scheme "$(SCHEME)"
	rm -rf "$(DERIVED_DATA)"
	rm -rf SnoopyCore/.build

build: build-macos build-iphone build-ipad

build-macos:
	xcodebuild build \
		-project "$(PROJECT)" -scheme "$(SCHEME)" -configuration "$(CONFIGURATION)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		-destination "platform=macOS"

build-iphone:
	xcodebuild build \
		-project "$(PROJECT)" -scheme "$(SCHEME)" -configuration "$(CONFIGURATION)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		-destination "platform=iOS Simulator,name=$(IPHONE_SIMULATOR)"

build-ipad:
	xcodebuild build \
		-project "$(PROJECT)" -scheme "$(SCHEME)" -configuration "$(CONFIGURATION)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		-destination "platform=iOS Simulator,name=$(IPAD_SIMULATOR)"

# Business logic lives in the local SnoopyCore package; that's where the
# tests are (see spec/*.md acceptance criteria), not in the app target.
test:
	cd SnoopyCore && swift test

run: run-macos run-iphone run-ipad

run-macos: build-macos
	open "$(MACOS_APP_PATH)"

run-iphone: build-iphone
	xcrun simctl boot "$(IPHONE_SIMULATOR)" 2>/dev/null || true
	open -a Simulator --args -CurrentDeviceUDID "$(IPHONE_SIMULATOR)"
	xcrun simctl bootstatus "$(IPHONE_SIMULATOR)" -b
	xcrun simctl install "$(IPHONE_SIMULATOR)" "$(IPHONE_APP_PATH)"
	xcrun simctl launch "$(IPHONE_SIMULATOR)" "$(BUNDLE_ID)"

run-ipad: build-ipad
	xcrun simctl boot "$(IPAD_SIMULATOR)" 2>/dev/null || true
	open -a Simulator --args -CurrentDeviceUDID "$(IPAD_SIMULATOR)"
	xcrun simctl bootstatus "$(IPAD_SIMULATOR)" -b
	xcrun simctl install "$(IPAD_SIMULATOR)" "$(IPAD_APP_PATH)"
	xcrun simctl launch "$(IPAD_SIMULATOR)" "$(BUNDLE_ID)"
