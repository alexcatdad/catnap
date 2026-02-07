APP_NAME = Catnap
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
CONTENTS = $(APP_BUNDLE)/Contents
MACOS = $(CONTENTS)/MacOS

.PHONY: build bundle codesign run clean test lint

build:
	swift build -c release

bundle: build
	mkdir -p $(MACOS)
	cp $(BUILD_DIR)/$(APP_NAME) $(MACOS)/$(APP_NAME)
	cp SupportFiles/Info.plist $(CONTENTS)/Info.plist

codesign: bundle
	codesign --force --sign - $(APP_BUNDLE)

run: codesign
	open $(APP_BUNDLE)

test:
	swift test

lint:
	swift build -Xswiftc -warnings-as-errors

clean:
	rm -rf .build $(APP_BUNDLE)
