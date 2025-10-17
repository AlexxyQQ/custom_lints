import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as analyzer;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoHardcodedStringsRule extends DartLintRule {
  /// The constructor for our lint rule.
  /// It passes the lint's metadata (`_code`) to the superclass.
  const NoHardcodedStringsRule() : super(code: _code);

  /// A unique identifier for this lint rule.
  /// This is used for configuration files (e.g., `analysis_options.yaml`)
  /// and for suppressing the lint with `// ignore: ...` comments.
  static const _name = 'no_hardcoded_strings_in_text';

  /// The metadata for the lint rule, which defines how it appears in the IDE.
  /// This includes the error message, a suggested correction, and severity.
  static const _code = LintCode(
    name: _name,
    // The message that developers will see when the lint is triggered.
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
    // The severity of the lint. Can be Error, Warning, or Info.
    errorSeverity: analyzer.DiagnosticSeverity.WARNING,
  );

  /// This method is the core of the lint rule. It is called by the analyzer
  /// to inspect the source code.
  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    // We want to inspect the code for every instance of a widget being created.
    // `addInstanceCreationExpression` registers a callback that runs whenever
    // the analyzer encounters a constructor call, like `Text('...')`.
    context.registry.addInstanceCreationExpression((node) {
      // First, we check if the widget being created is a `Text` widget.
      // We get the name of the class from the constructor (`node.constructorName.type`).
      // We ignore other widgets to keep the lint focused.
      if (node.constructorName.type.name.toString() != 'Text') {
        return;
      }

      // If it is a `Text` widget, we iterate through all the arguments
      // passed to its constructor.
      for (final argument in node.argumentList.arguments) {
        // A string literal can be a positional argument, like `Text('Hello')`,
        // or a named argument, like `Text(data: 'Hello')`.

        // Case 1: The argument is a direct string literal (positional).
        // Example: Text('This is a positional argument')
        if (argument is StringLiteral) {
          // If we find a hardcoded string, we report it.
          // `reporter.atNode` highlights the specific string literal in the IDE
          // and displays the `_code` metadata (problem message, etc.).
          reporter.atNode(argument, _code);
        }
        // Case 2: The argument is a named expression.
        // Example: Text(data: 'This is a named argument')
        else if (argument is NamedExpression) {
          // We check if the value part of the named argument is a string literal.
          final expression = argument.expression;
          if (expression is StringLiteral) {
            // If it is, we report it.
            reporter.atNode(expression, _code);
          }
        }
      }
    });
  }
}
