import 'package:app_custom_lints/src/lint_rules/hardcoded_string/no_hardcoded_strings_rule.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_edge_insets_all.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_edge_insets_only.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_edge_insets_symmetric.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_sized_box_height.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_sized_box_width.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A custom lint plugin that provides lint rules for analyzing Dart code
class CustomLintPlugin extends PluginBase {
  /// Returns a list of lint rules to be applied during analysis
  ///
  /// [configs] - Configuration options for the lint rules
  ///
  /// Returns a list containing the [NoHardcodedStringsRule]
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      const HardcodedStringLintRule(),
      // const EvenNumbersOnlyLintRule(),
      AvoidSizedBoxHeight(),
      AvoidSizedBoxWidth(),
      AvoidEdgeInsetsAll(),
      AvoidEdgeInsetsSymmetric(),
      AvoidEdgeInsetsOnly(),
    ];
  }
}

/// Creates and returns a new instance of the custom lint plugin
///
/// This plugin analyzes dart files and raises warnings for string literals
/// that are declared inside classes extending Widget or State
///
/// Returns a [PluginBase] instance configured with the custom lint rules
PluginBase createPlugin() => _CustomLints();

/// Internal implementation of the custom lint plugin
class _CustomLints extends PluginBase {
  /// Creates a new instance of [_CustomLints]
  _CustomLints();

  /// Returns the list of lint rules based on configuration
  ///
  /// [configs] - Configuration options for the lint rules
  ///
  /// Returns an empty list if linting is disabled, otherwise returns
  /// a list containing [NoHardcodedStringsRule]
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final enabled = configs.enableAllLintRules ?? true;
    if (!enabled) {
      return [];
    }

    return [
      const HardcodedStringLintRule(),
      // const EvenNumbersOnlyLintRule(),
      AvoidSizedBoxHeight(),
      AvoidSizedBoxWidth(),
      AvoidEdgeInsetsAll(),
      AvoidEdgeInsetsSymmetric(),
      AvoidEdgeInsetsOnly(),
    ];
  }
}
