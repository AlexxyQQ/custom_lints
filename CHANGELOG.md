## 2.0.0

- **Breaking:** Migrated entirely from `custom_lint_builder` and `custom_lint` to Dart's official `analysis_server_plugin` architecture.
- **Breaking:** Removed auto-fixes (quick fixes) temporarily as part of the migration to the new plugin system API (`CorrectionProducer`).
- Rules now run natively inside `dart analyze` and the Dart Analysis Server without needing a separate `dart run custom_lint` command.
- Updated minimum Dart SDK constraint to `^3.10.0`.

## 1.2.0

- **New rule:** `avoid_hardcoded_strings` — warns when a string literal is used directly as display text inside a Widget constructor. Ships with two quick-fixes: add an ignore comment, or extract the string to a `const` variable.
- Smart exclusions: route names, `snake_case`/`SCREAMING_CASE` identifiers, asset paths, URLs, hex colors, map keys, non-display named parameters (`fontFamily`, `semanticsLabel`, `heroTag`, etc.), and strings ≤ 2 characters are all silently skipped.

## 1.1.0

- **Fix:** `avoid_sized_box_height` and `avoid_sized_box_width` no longer trigger on `SizedBox` instances that have a `child` argument. A `SizedBox` with a child is a sizing container, not a gap, and should not be replaced with `.verticalGap` / `.horizontalGap`.

## 1.0.0

- Initial release with five lint rules:
  - `avoid_sized_box_height` — replace `SizedBox(height: n)` with `n.verticalGap`
  - `avoid_sized_box_width` — replace `SizedBox(width: n)` with `n.horizontalGap`
  - `avoid_edge_insets_all` — replace `EdgeInsets.all(n)` with `n.allPadding`
  - `avoid_edge_insets_only` — replace `EdgeInsets.only(...)` with directional extensions
  - `avoid_edge_insets_symmetric` — replace `EdgeInsets.symmetric(...)` with `.horizontalPadding` / `.verticalPadding`
