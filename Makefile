test_before_publish:
	flutter pub get
	flutter test
	flutter analyze
	flutter pub publish --dry-run