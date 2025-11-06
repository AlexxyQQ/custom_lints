// lib/src/avoid_sized_box_width_fix.dart

part of '../avoid_sized_box_width.dart';

class _SizedBoxWidthToExtensionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError error,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!error.sourceRange.intersects(node.sourceRange)) return;

      final widthArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'width')
          .firstOrNull;

      if (widthArg == null) return;

      final widthValue = widthArg.expression.toSource();
      String numberValue = widthValue.replaceAll('.w', '').replaceAll('.h', '');

      // Remove parentheses if present
      numberValue = numberValue.replaceAll('(', '').replaceAll(')', '');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to $numberValue.horizontalGap',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          error.sourceRange,
          '$numberValue.horizontalGap',
        );
      });
    });
  }
}
