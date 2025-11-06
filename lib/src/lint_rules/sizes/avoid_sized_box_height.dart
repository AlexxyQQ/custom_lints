import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError, ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

part './fixes/avoid_sized_box_height_fix.dart';

class AvoidSizedBoxHeight extends DartLintRule {
  AvoidSizedBoxHeight() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_sized_box_height',
    problemMessage:
        'Use the .verticalGap extension instead of SizedBox(height: ...).',
    correctionMessage: 'Try using .verticalGap instead.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // Check if it's a SizedBox
      final type = node.staticType?.getDisplayString(withNullability: false);
      if (type != 'SizedBox') {
        return;
      }

      // Check for a 'height' argument and no 'width' argument
      final heightArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'height')
          .firstOrNull;

      final widthArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'width')
          .firstOrNull;

      if (heightArg != null && widthArg == null) {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_SizedBoxHeightToExtensionFix()];
}
