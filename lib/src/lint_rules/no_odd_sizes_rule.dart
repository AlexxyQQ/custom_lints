import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as analyzer;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A lint rule that flags the use of odd number literals with UI-related
/// extensions from `NumExtensionX`.
///
/// **Why it's a problem:** To maintain a consistent design system and avoid
/// rendering issues on some screens, UI values like padding, spacing, and
/// radius should be even numbers. This rule enforces that constraint at
/// compile time.
///
/// ---
///
/// ### ❌ Bad Code
///
/// ```dart
/// Padding(padding: 7.allPadding) // LINT
/// 9.horizontalGap // LINT
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: 15.rounded, // LINT
///   ),
/// )
/// ```
///
/// ### ✅ Good Code
///
/// ```dart
/// Padding(padding: 8.allPadding)
/// 10.horizontalGap
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: 16.rounded,
///   ),
/// )
/// ```
class AvoidOddNumbersInUIExtensions extends DartLintRule {
  const AvoidOddNumbersInUIExtensions() : super(code: _code);

  static const _name = 'avoid_odd_numbers_in_ui_extensions';

  static const _code = LintCode(
    name: _name,
    problemMessage: 'UI values must be even numbers to maintain consistency.',
    correctionMessage: 'Please change this to an even number (e.g., 8, 16).',
    errorSeverity: analyzer.ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // A Set containing all the getter names from your extension that are
    // used for UI sizing and should only be used with even numbers.
    const uiGetters = {
      'roundShape',
      'borderCircular',
      'circular',
      'rounded',
      'roundedTop',
      'roundedBottom',
      'allPadding',
      'bottomOnly',
      'topOnly',
      'leftOnly',
      'rightOnly',
      'horizontalPadding',
      'verticalPadding',
      'horizontalGap',
      'verticalGap',
      'hBox',
      'vBox',
    };

    // This registry callback will run for every method invocation in the code.
    // An extension getter like `8.verticalGap` is parsed as a method invocation.
    context.registry.addMethodInvocation((node) {
      // We are only interested in invocations on integer literals, e.g., `8.sp` or `15.verticalGap`.
      final target = node.target;
      if (target is! IntegerLiteral) {
        return; // Exit if the target is not a number literal.
      }

      // Check if the invoked method name is one of our UI getters.
      final getterName = node.methodName.name;
      if (!uiGetters.contains(getterName)) {
        return; // Exit if it's not a UI-related getter.
      }

      // Finally, check if the integer's value is odd.
      final value = target.value;
      if (value != null && value % 2 != 0) {
        // If it's odd, report an error at the location of the number.
        reporter.atNode(target, _code);
      }
    });
  }
}
