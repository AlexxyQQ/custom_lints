// lib/src/avoid_sized_box_width.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError, ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

part 'fixes/avoid_sized_box_width_fix.dart';

class AvoidSizedBoxWidth extends DartLintRule {
  AvoidSizedBoxWidth() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_sized_box_width',
    problemMessage:
        'Use the .horizontalGap extension instead of SizedBox(width: ...).',
    correctionMessage: 'Try using .horizontalGap instead.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType?.getDisplayString(withNullability: false);
      if (type != 'SizedBox') {
        return;
      }

      final heightArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'height')
          .firstOrNull;

      final widthArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'width')
          .firstOrNull;

      if (widthArg != null && heightArg == null) {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_SizedBoxWidthToExtensionFix()];
}
