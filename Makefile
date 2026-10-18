# Lint and format with swift-format, which ships with Xcode (config: .swift-format).
SOURCES := Tuner scripts/check-pitch

.PHONY: lint format

lint:
	xcrun swift-format lint --strict --recursive --parallel $(SOURCES)

format:
	xcrun swift-format format --in-place --recursive --parallel $(SOURCES)
