import 'package:app_custom_lints/src/lint_rules/hardcoded_string/avoid_hardcoded_strings.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_edge_insets_all.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_edge_insets_only.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_edge_insets_symmetric.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_sized_box_height.dart';
import 'package:app_custom_lints/src/lint_rules/sizes/avoid_sized_box_width.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class CustomLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      const AvoidSizedBoxHeight(),
      const AvoidSizedBoxWidth(),
      const AvoidEdgeInsetsAll(),
      const AvoidEdgeInsetsSymmetric(),
      const AvoidEdgeInsetsOnly(),
      const AvoidHardcodedStrings(),
    ];
  }
}

PluginBase createPlugin() => _CustomLints();

class _CustomLints extends PluginBase {
  _CustomLints();

  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final enabled = configs.enableAllLintRules ?? true;
    if (!enabled) {
      return [];
    }

    return [
      const AvoidSizedBoxHeight(),
      const AvoidSizedBoxWidth(),
      const AvoidEdgeInsetsAll(),
      const AvoidEdgeInsetsSymmetric(),
      const AvoidEdgeInsetsOnly(),
      const AvoidHardcodedStrings(),
    ];
  }
}
