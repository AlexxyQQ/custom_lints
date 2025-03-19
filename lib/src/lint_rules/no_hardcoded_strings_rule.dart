import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:analyzer/error/error.dart' as analyzer;

/// A lint rule that detects hardcoded string literals inside Flutter widgets.
///
/// This rule helps enforce proper internationalization practices by warning when
/// string literals are used directly in Text widgets. It encourages using
/// localization instead of hardcoded strings.
///
/// Example of incorrect code:
/// ```dart
/// Text('Hello World'); // This will trigger the lint
/// ```
///
/// Example of correct code using localization:
/// ```dart
/// // 1. First generate localization keys using your preferred tool
/// // e.g. with easy_localization_generator:
/// // locale_keys.g.dart
/// abstract class LocaleKeys {
///   static const hello_world = 'hello_world';
/// }
///
/// // 2. Add translations to your locale files:
/// // assets/translations/en.json
/// {
///   "hello_world": "Hello World"
/// }
///
/// // 3. Use the generated keys in your widgets:
/// Text(LocaleKeys.hello_world.tr()); // Using easy_localization
/// // or
/// Text(AppLocalizations.of(context)!.helloWorld); // Using Flutter gen-l10n
/// ```
class NoHardcodedStringsRule extends DartLintRule {
  /// Default const constructor
  const NoHardcodedStringsRule() : super(code: _code);

  /// Metadata about the warning that will show-up in the IDE.
  /// This is used for `// ignore: code` and enabling/disabling the lint
  static const _code = LintCode(
    name: _name,
    problemMessage:
        'String literals should not be declared inside a widget '
        'class. '
        'If this string is used for presentation, such as in a Text widget, '
        'it will make harder adding l10n support. '
        'If this string is used for comparison, such as: membership == "free", '
        'it is a sign of primitive obsession.\n\n'
        'Example of correct usage:\n'
        '- Using easy_localization: Text(LocaleKeys.some_key.tr())\n'
        '- Using Flutter gen-l10n: Text(AppLocalizations.of(context)!.someKey)',
    correctionMessage:
        'If this is for presentation:\n'
        '1. Use a localization package (easy_localization or Flutter gen-l10n)\n'
        '2. Generate localization keys\n'
        '3. Add translations to locale files\n'
        '4. Use generated keys instead of hardcoded strings\n\n'
        'If this is for comparison, consider using an enum instead.',
    errorSeverity: analyzer.ErrorSeverity.ERROR,
    uniqueName: _name,
  );

  /// The unique name identifier for this lint rule
  static const _name = 'avoid_string_literals_inside_widget';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Register a callback to analyze instance creation expressions
    context.registry.addInstanceCreationExpression((node) {
      // Check if the widget being created is Text widget
      if (node.constructorName.type.toString() == 'Text') {
        // Analyze all arguments passed to the Text widget
        node.argumentList.arguments.forEach((argument) {
          if (argument is NamedExpression) {
            // Check named arguments (e.g., Text(data: "some string"))
            final expression = argument.expression;
            if (expression is StringLiteral) {
              reporter.atNode(expression, _code);
            }
          } else if (argument is StringLiteral) {
            // Check positional arguments (e.g., Text("some string"))
            reporter.atNode(argument, _code);
          }
        });
      }
    });
  }
}
