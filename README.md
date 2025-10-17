# App Custom Lints

[](https://opensource.org/licenses/MIT)
[](https://pub.dev/packages/custom_lint)
[](https://flutter.dev)

A collection of opinionated custom lint rules for Dart & Flutter projects. This package is designed to enforce a strict and consistent design system, improve code quality, and promote best practices like internationalization.

---

## Features

- 🌍 **Enforce Internationalization (i18n)**: The `avoid_string_literals_inside_widget` rule detects hardcoded strings in `Text` widgets, pushing you to use a proper localization flow.
- 📐 **Enforce Design System Consistency**: The `avoid_odd_numbers_in_ui_extensions` rule ensures all spacing, padding, and radius values are even, helping maintain a consistent grid system (e.g., 8pt grid).
- 🚀 **Easy Integration**: Simple to set up in any project using the official `custom_lint` package.
- ⚡ **Fast Analysis**: Written to have a minimal impact on IDE performance and analysis time.

## Installation

1.  **Add dependencies**

    Add `custom_lint` and this package to your `pubspec.yaml` under `dev_dependencies`.

    ```yaml
    dev_dependencies:
      custom_lint: ^0.6.4 # Use the latest version
      app_custom_lints:
        git:
          url: https://github.com/AlexxyQQ/custom_lints.git
          ref: main # You can also pin to a specific commit hash or tag
    ```

2.  **Get packages**

    Run the command to fetch the packages.

    ```bash
    flutter pub get
    ```

3.  **Enable the plugin**

    Create or update your `analysis_options.yaml` file to enable the `custom_lint` plugin.

    ```yaml
    analyzer:
      plugins:
        - custom_lint
    ```

## Available Rules

### `avoid_string_literals_inside_widget`

This rule detects hardcoded string literals inside `Text` widgets to enforce proper internationalization practices. This makes your app easier to translate and maintain.

#### ❌ Bad Code:

```dart
// These will trigger the lint
Text('Hello World');
Text(data: 'Welcome User');
```

#### ✅ Good Code:

**Using Flutter gen-l10n:**

```dart
// In your ARB file (e.g., app_en.arb)
// { "helloWorld": "Hello World" }

// In your widget
Text(AppLocalizations.of(context)!.helloWorld);
```

**Using easy_localization:**

```dart
// In your JSON file (e.g., assets/translations/en.json)
// { "hello_world": "Hello World" }

// In your widget
Text(LocaleKeys.hello_world.tr());
```

---

### `avoid_odd_numbers_in_ui_extensions`

This rule enforces an even-numbered design system by flagging odd numbers used for UI dimensions like padding, spacing, and corner radii. This is especially useful when using a sizing extension on `num`.

#### ❌ Bad Code:

```dart
// These will trigger the lint
Padding(padding: 7.allPadding);
SizedBox(width: 9.w);
Container(
  decoration: BoxDecoration(
    borderRadius: 15.rounded,
  ),
);
```

#### ✅ Good Code:

```dart
// Use even numbers for consistency
Padding(padding: 8.allPadding);
SizedBox(width: 10.w);
Container(
  decoration: BoxDecoration(
    borderRadius: 16.rounded,
  ),
);
```

## Rule Configuration

You can enable/disable rules or change their severity in your `analysis_options.yaml` file.

```yaml
custom_lint:
  rules:
    # Enable a rule (defaults to a warning)
    - avoid_string_literals_inside_widget: true
    # Enable a rule and set its severity to error
    - avoid_odd_numbers_in_ui_extensions:
        severity: error
```

## Contributing

Contributions are welcome\! If you have an idea for a new rule or an improvement, please follow these steps:

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add some amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.
