import 'package:app_custom_lints/app_custom_lints.dart';
import 'package:app_custom_lints/src/lint_rules/no_hardcoded_strings_rule.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:test/test.dart';

void main() {
  group('CustomLintPlugin Tests', () {
    late CustomLintPlugin plugin;

    setUp(() {
      plugin = CustomLintPlugin();
    });

    test('getLintRules returns NoHardcodedStringsRule', () {
      final rules = plugin.getLintRules(
        const CustomLintConfigs(
          enableAllLintRules: true,
          verbose: false,
          debug: false,
          rules: {},
        ),
      );
      expect(rules.length, 1);
      expect(rules.first, isA<NoHardcodedStringsRule>());
    });

    test('createPlugin returns PluginBase instance', () {
      final plugin = createPlugin();
      expect(plugin, isA<PluginBase>());
    });
  });

  group('Plugin Configuration Tests', () {
    late PluginBase plugin;

    setUp(() {
      plugin = createPlugin();
    });

    test('getLintRules returns empty list when linting is disabled', () {
      const configs = CustomLintConfigs(
        enableAllLintRules: false,
        verbose: false,
        debug: false,
        rules: const {},
      );
      final rules = plugin.getLintRules(configs);
      expect(rules, isEmpty);
    });

    test(
      'getLintRules returns NoHardcodedStringsRule when linting is enabled',
      () {
        const configs = CustomLintConfigs(
          enableAllLintRules: true,
          verbose: false,
          debug: false,
          rules: const {},
        );
        final rules = plugin.getLintRules(configs);
        expect(rules.length, 1);
        expect(rules.first, isA<NoHardcodedStringsRule>());
      },
    );

    test(
      'getLintRules returns NoHardcodedStringsRule when enableAllLintRules is null',
      () {
        const configs = CustomLintConfigs.empty;
        final rules = plugin.getLintRules(configs);
        expect(rules.length, 1);
        expect(rules.first, isA<NoHardcodedStringsRule>());
      },
    );
  });
}
