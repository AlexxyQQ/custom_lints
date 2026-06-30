import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/lint_rules/hardcoded_string/avoid_hardcoded_strings.dart';
import 'src/lint_rules/sizes/avoid_edge_insets_all.dart';
import 'src/lint_rules/sizes/avoid_edge_insets_only.dart';
import 'src/lint_rules/sizes/avoid_edge_insets_symmetric.dart';
import 'src/lint_rules/sizes/avoid_sized_box_height.dart';
import 'src/lint_rules/sizes/avoid_sized_box_width.dart';

final plugin = CustomLintPlugin();

class CustomLintPlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(AvoidSizedBoxHeight())
      ..registerWarningRule(AvoidSizedBoxWidth())
      ..registerWarningRule(AvoidEdgeInsetsAll())
      ..registerWarningRule(AvoidEdgeInsetsSymmetric())
      ..registerWarningRule(AvoidEdgeInsetsOnly())
      ..registerWarningRule(AvoidHardcodedStrings());
  }

  @override
  String get name => 'app_custom_lints';
}
