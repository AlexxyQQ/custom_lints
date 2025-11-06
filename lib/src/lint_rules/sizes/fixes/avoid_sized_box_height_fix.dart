part of '../avoid_sized_box_height.dart';

class _SizedBoxHeightToExtensionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError error,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // Find the node that matches the error
      if (!error.sourceRange.intersects(node.sourceRange)) return;

      final heightArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'height')
          .firstOrNull;

      if (heightArg == null) return;

      // Get the value inside height: e.g., "8.h" or "12"
      final heightValue = heightArg.expression.toSource();

      // Clean the value: "8.h" -> "8", "12" -> "12"
      String numberValue = heightValue
          .replaceAll('.h', '')
          .replaceAll('.w', '');

      // Remove parentheses if present
      numberValue = numberValue.replaceAll('(', '').replaceAll(')', '');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to $numberValue.verticalGap',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        // Replace the entire SizedBox(...) with the extension
        builder.addSimpleReplacement(
          error.sourceRange,
          '$numberValue.verticalGap',
        );
      });
    });
  }
}
