# App Custom Lints

[](https://opensource.org/licenses/MIT)
[](https://pub.dev/packages/custom_lint)
[](https://flutter.dev)

A collection of opinionated custom lint rules for Dart & Flutter projects. This package enforces a consistent design system by replacing verbose Flutter spacing/padding constructors with fluent extension methods, promotes an even-number grid system (e.g. 8pt grid), and catches hardcoded UI strings that should be extracted or localized.

---

## Features

- **Consistent spacing** — Replace `SizedBox(height/width: ...)` with `.verticalGap` / `.horizontalGap` extensions.
- **Consistent padding** — Replace `EdgeInsets.all/only/symmetric(...)` with `.allPadding`, `.topOnly`, `.horizontalPadding`, etc.
- **Hardcoded string detection** — Warn when display strings are written directly in widget constructors instead of being extracted or localized.
- **Automatic fixes** — Every rule ships with a quick-fix so your IDE can auto-migrate code.
- **Configurable** — Enable/disable rules or change severity per project.

---

## Prerequisites — Extension Methods

All lint rules encourage you to use a `NumExtensionX` extension on `num`. Add the following to your project (e.g. `lib/core/extensions/size.extension.dart`):

```dart
extension NumExtensionX on num {
  // ── Spacing ──────────────────────────────────────────────
  Widget get horizontalGap => SizedBox(width: _even.toDouble());
  Widget get verticalGap   => SizedBox(height: _even.toDouble());

  // ── Padding ──────────────────────────────────────────────
  EdgeInsets get allPadding         => EdgeInsets.all(_even.toDouble());
  EdgeInsets get topOnly            => EdgeInsets.only(top: _even.toDouble());
  EdgeInsets get bottomOnly         => EdgeInsets.only(bottom: _even.toDouble());
  EdgeInsets get leftOnly           => EdgeInsets.only(left: _even.toDouble());
  EdgeInsets get rightOnly          => EdgeInsets.only(right: _even.toDouble());
  EdgeInsets get horizontalPadding  => EdgeInsets.symmetric(horizontal: _even.toDouble());
  EdgeInsets get verticalPadding    => EdgeInsets.symmetric(vertical: _even.toDouble());

  // ── Radius ───────────────────────────────────────────────
  BorderRadius get borderCircular => BorderRadius.all(Radius.circular(_even.toDouble()));
  BorderRadius get rounded        => BorderRadius.circular(_even.toDouble());

  // Enforces even numbers (rounds odd values up)
  num get _even => isOdd ? this + 1 : this;
}
```

> **Note:** The `_even` getter silently rounds odd values up to the nearest even number, keeping your design grid intact.

---

## Installation

1. **Add dependencies** to `pubspec.yaml`:

    ```yaml
    dev_dependencies:
      custom_lint: ^0.8.1
      app_custom_lints:
        git:
          url: https://github.com/AlexxyQQ/custom_lints.git
          ref: main
    ```

2. **Fetch packages:**

    ```bash
    flutter pub get
    ```

3. **Enable the plugin** in `analysis_options.yaml`:

    ```yaml
    analyzer:
      plugins:
        - custom_lint
    ```

---

## Available Rules

### 1. `avoid_sized_box_height`

**Severity:** error
**Fix:** Converts `SizedBox(height: value)` → `value.verticalGap`

Use the `.verticalGap` extension instead of a bare `SizedBox` with only a `height` argument.

#### Bad

```dart
// Triggers: "Use the .verticalGap extension instead of SizedBox(height: ...)."
const SizedBox(height: 16),
SizedBox(height: 24),
SizedBox(height: 8.0),
```

#### Good

```dart
16.verticalGap,
24.verticalGap,
8.verticalGap,
```

#### Auto-fix examples

| Before | After |
|--------|-------|
| `SizedBox(height: 16)` | `16.verticalGap` |
| `SizedBox(height: 24.0)` | `24.0.verticalGap` |
| `const SizedBox(height: 8)` | `8.verticalGap` |

> **Does NOT trigger** when both `height` and `width` are present (e.g. `SizedBox(height: 16, width: 16)`), or when a `child` is present — a `SizedBox` with a child is a sizing container, not a gap.

---

### 2. `avoid_sized_box_width`

**Severity:** error
**Fix:** Converts `SizedBox(width: value)` → `value.horizontalGap`

Use the `.horizontalGap` extension instead of a bare `SizedBox` with only a `width` argument.

#### Bad

```dart
// Triggers: "Use the .horizontalGap extension instead of SizedBox(width: ...)."
const SizedBox(width: 12),
SizedBox(width: 20),
SizedBox(width: 4.0),
```

#### Good

```dart
12.horizontalGap,
20.horizontalGap,
4.horizontalGap,
```

#### Auto-fix examples

| Before | After |
|--------|-------|
| `SizedBox(width: 12)` | `12.horizontalGap` |
| `SizedBox(width: 20.0)` | `20.0.horizontalGap` |
| `const SizedBox(width: 4)` | `4.horizontalGap` |

> **Does NOT trigger** when both `height` and `width` are present, or when a `child` is present.

---

### 3. `avoid_edge_insets_all`

**Severity:** error
**Fix:** Converts `EdgeInsets.all(value)` → `value.allPadding`

Use the `.allPadding` extension instead of `EdgeInsets.all(...)`.

#### Bad

```dart
// Triggers: "Use the .allPadding extension instead of EdgeInsets.all(...)."
Padding(padding: EdgeInsets.all(16)),
Padding(padding: const EdgeInsets.all(8)),
Container(
  padding: EdgeInsets.all(12.0),
  child: Text('Hello'),
),
```

#### Good

```dart
Padding(padding: 16.allPadding),
Padding(padding: 8.allPadding),
Container(
  padding: 12.allPadding,
  child: Text('Hello'),
),
```

#### Auto-fix examples

| Before | After |
|--------|-------|
| `EdgeInsets.all(16)` | `16.allPadding` |
| `const EdgeInsets.all(8)` | `8.allPadding` |
| `EdgeInsets.all(12.0)` | `12.0.allPadding` |

---

### 4. `avoid_edge_insets_only`

**Severity:** error
**Fix:** Converts `EdgeInsets.only(...)` → directional extensions (`.topOnly`, `.bottomOnly`, `.leftOnly`, `.rightOnly`)

Use directional extensions instead of `EdgeInsets.only(...)`.

#### Bad

```dart
// Triggers: "Use .topOnly, .bottomOnly, .leftOnly, or .rightOnly extensions."
Padding(padding: EdgeInsets.only(top: 16)),
Padding(padding: EdgeInsets.only(bottom: 8)),
Padding(padding: EdgeInsets.only(left: 12)),
Padding(padding: EdgeInsets.only(right: 4)),

// Multiple sides also trigger
Padding(padding: EdgeInsets.only(top: 16, bottom: 8)),
Padding(padding: EdgeInsets.only(left: 12, right: 4)),
Padding(padding: EdgeInsets.only(top: 8, left: 16)),
```

#### Good

```dart
Padding(padding: 16.topOnly),
Padding(padding: 8.bottomOnly),
Padding(padding: 12.leftOnly),
Padding(padding: 4.rightOnly),

// Multiple sides are chained with +
Padding(padding: 16.topOnly + 8.bottomOnly),
Padding(padding: 12.leftOnly + 4.rightOnly),
Padding(padding: 8.topOnly + 16.leftOnly),
```

#### Auto-fix examples

| Before | After |
|--------|-------|
| `EdgeInsets.only(top: 16)` | `16.topOnly` |
| `EdgeInsets.only(bottom: 8)` | `8.bottomOnly` |
| `EdgeInsets.only(left: 12)` | `12.leftOnly` |
| `EdgeInsets.only(right: 4)` | `4.rightOnly` |
| `EdgeInsets.only(top: 16, bottom: 8)` | `16.topOnly + 8.bottomOnly` |
| `EdgeInsets.only(left: 12, right: 4)` | `12.leftOnly + 4.rightOnly` |
| `EdgeInsets.only(top: 8, left: 16, right: 4)` | `8.topOnly + 16.leftOnly + 4.rightOnly` |

---

### 5. `avoid_edge_insets_symmetric`

**Severity:** error
**Fix:** Converts `EdgeInsets.symmetric(...)` → `.horizontalPadding` / `.verticalPadding`

Use `.horizontalPadding` or `.verticalPadding` extensions instead of `EdgeInsets.symmetric(...)`.

#### Bad

```dart
// Triggers: "Use .horizontalPadding or .verticalPadding extensions instead."
Padding(padding: EdgeInsets.symmetric(horizontal: 16)),
Padding(padding: EdgeInsets.symmetric(vertical: 8)),
Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
Padding(padding: const EdgeInsets.symmetric(horizontal: 24)),
```

#### Good

```dart
Padding(padding: 16.horizontalPadding),
Padding(padding: 8.verticalPadding),
Padding(padding: 16.horizontalPadding + 8.verticalPadding),
Padding(padding: 24.horizontalPadding),
```

#### Auto-fix examples

| Before | After |
|--------|-------|
| `EdgeInsets.symmetric(horizontal: 16)` | `16.horizontalPadding` |
| `EdgeInsets.symmetric(vertical: 8)` | `8.verticalPadding` |
| `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` | `16.horizontalPadding + 8.verticalPadding` |
| `const EdgeInsets.symmetric(horizontal: 24)` | `24.horizontalPadding` |

---

### 6. `avoid_hardcoded_strings`

**Severity:** warning
**Fix:** Add `// ignore` comment, or extract the string to a `const` variable

Flags string literals written directly inside Widget constructors as display text. Hardcoded UI strings make localization harder and scatter copy across the codebase.

#### Bad

```dart
// Triggers: "Hardcoded string detected. Use a variable or localized string instead."
Text('Hello World'),
Text('Submit'),
AppBar(title: Text('My App')),
ElevatedButton(child: Text('Sign in')),
MyWidget(title: 'Welcome back'),
SnackBar(content: Text('Something went wrong')),
AlertDialog(title: Text('Are you sure?')),
```

#### Good

```dart
// Extracted to a constant
const greeting = 'Hello World';
Text(greeting),

// Using a localization key (easy_localization / gen-l10n)
Text(LocaleKeys.greeting.tr()),
Text(AppLocalizations.of(context)!.greeting),

// Suppressed when intentional (e.g. debug-only widget)
// ignore: avoid_hardcoded_strings
Text('DEV ONLY — remove before release'),
```

#### Auto-fix options

| Fix | Result |
|-----|--------|
| Add ignore comment | Inserts `// ignore: avoid_hardcoded_strings` above the line |
| Extract to `const varName` | Hoists the string to a `const` at the top of the current function |

#### What is intentionally skipped

| Category | Example | Reason |
|----------|---------|--------|
| Route / path names | `'/home'`, `':id'` | Navigation identifiers, not display text |
| `snake_case` strings | `'en_US'`, `'api_key'` | Locale codes, config keys |
| `SCREAMING_CASE` strings | `'PUSH_NOTIFICATION'` | Constant identifiers |
| Asset / package paths | `'assets/logo.png'`, `'package:foo'` | Resource references |
| URLs | `'https://example.com'` | Technical values |
| Hex colors | `'#FF0000'` | CSS/design tokens |
| Map keys | `{'name': value}` | Data structures |
| Non-display named params | `fontFamily: 'Roboto'`, `semanticsLabel: 'close'`, `heroTag: 'fab'` | Non-UI parameters |
| Strings ≤ 2 characters | `'OK'`, `'or'` | Too short to localize meaningfully |
| Variable/constant declarations | `const label = 'Submit'` | Already a variable |

> **Positional arguments** to any Widget constructor are also checked — not just known widgets like `Text`. Custom widgets with display string positional args will be caught too.

> **Named parameters** are only flagged when they match a known display-text list: `text`, `label`, `title`, `subtitle`, `hint`, `hintText`, `labelText`, `helperText`, `errorText`, `message`, `description`, `content`, `tooltip`, `placeholder`, `buttonText`, `confirmText`, `cancelText`, `emptyText`, `prefixText`, `suffixText`, `counterText`.

---

## Real-World Before / After

```dart
// ── BEFORE ──────────────────────────────────────────────────
Column(
  children: [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.star),
          SizedBox(width: 8),
          Text('Favorites'),
          SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Chip(label: Text('New')),
          ),
        ],
      ),
    ),
    SizedBox(height: 24),
    Padding(
      padding: EdgeInsets.all(16),
      child: Text('Description'),
    ),
  ],
),

// ── AFTER ───────────────────────────────────────────────────
Column(
  children: [
    Padding(
      padding: 16.horizontalPadding + 8.verticalPadding,
      child: Row(
        children: [
          Icon(Icons.star),
          8.horizontalGap,
          Text('Favorites'),
          12.horizontalGap,
          Padding(
            padding: 4.topOnly + 4.bottomOnly,
            child: Chip(label: Text('New')),
          ),
        ],
      ),
    ),
    24.verticalGap,
    Padding(
      padding: 16.allPadding,
      child: Text('Description'),
    ),
  ],
),
```

---

## Rule Configuration

Enable/disable rules or override severity in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - avoid_sized_box_height: true
    - avoid_sized_box_width: true
    - avoid_edge_insets_all: true
    - avoid_edge_insets_only: true
    - avoid_edge_insets_symmetric: true
    - avoid_hardcoded_strings: true

    # Override severity for a specific rule
    - avoid_sized_box_height:
        severity: warning
    - avoid_hardcoded_strings:
        severity: info   # downgrade to info if you want non-blocking feedback
```

Valid severity values: `error`, `warning`, `info`.

---

## Contributing

Contributions are welcome! If you have an idea for a new rule or an improvement, please follow these steps:

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add some amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
