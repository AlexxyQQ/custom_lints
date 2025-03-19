<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# App Custom Lints

A collection of custom lint rules for Flutter/Dart projects, focusing on enforcing best practices and code quality. Currently includes a powerful rule to detect and prevent hardcoded strings in Flutter widgets.

## Features

- 🔍 **No Hardcoded Strings Rule**: Detects and warns against string literals in Text widgets
- 🌍 **Internationalization Support**: Enforces proper i18n practices
- 🚀 **Easy Integration**: Simple setup with custom_lint
- ⚡ **Performance**: Minimal impact on analysis time

## Installation

Add the package to your `pubspec.yaml` in the `dev_dependencies` section:

```yaml
dev_dependencies:
  custom_lint: ^latest_version
  app_custom_lints:
    git:
      url: https://github.com/AlexxyQQ/custom_lints.git
      ref: main # or specify a commit hash/tag
```

Then run:

```bash
flutter pub get
```

Create or update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## Available Rules

### avoid_string_literals_inside_widget

Detects hardcoded string literals inside Flutter widgets to enforce proper internationalization practices.

#### ❌ What it catches:

```dart
// These will trigger the lint
Text('Hello World');
Text(data: 'Welcome User');
```

#### ✅ Correct usage:

Using Easy Localization:

```dart
// 1. Define keys in locale_keys.g.dart
abstract class LocaleKeys {
  static const hello_world = 'hello_world';
}

// 2. Add translations in assets/translations/en.json
{
  "hello_world": "Hello World"
}

// 3. Use in your code
Text(LocaleKeys.hello_world.tr());
```

Using Flutter gen-l10n:

```dart
// In your ARB files (app_en.arb)
{
  "helloWorld": "Hello World"
}

// In your code
Text(AppLocalizations.of(context)!.helloWorld);
```

## Rule Configuration

The rules can be configured in your `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - avoid_string_literals_inside_widget:
        severity: error # or warning
```

## Best Practices

1. Always use localization keys instead of hardcoded strings
2. Keep translation files organized and up-to-date
3. Use code generation tools for managing localization keys
4. Consider using enums for string comparisons instead of hardcoded strings

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

Need help? Here's how to get support:

- 📖 Check out the [example](example) directory for more usage examples
- 🐛 File an issue on [GitHub](https://github.com/AlexxyQQ/custom_lints/issues)
- 💡 Suggest new lint rules or improvements

## Troubleshooting

If you encounter any issues:

1. Make sure you have the latest version by updating your `pubspec.yaml` and running `flutter pub get`
2. Check that your `analysis_options.yaml` is properly configured
3. Try running `flutter clean` and then `flutter pub get`
4. Restart your IDE and/or Flutter analysis server

## Acknowledgments

- Built with [custom_lint](https://pub.dev/packages/custom_lint)
- Inspired by real-world Flutter development challenges
- Thanks to all contributors who help improve this package
