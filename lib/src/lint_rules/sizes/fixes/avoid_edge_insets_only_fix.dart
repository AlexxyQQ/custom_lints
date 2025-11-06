part of '../avoid_edge_insets_only.dart';

class _EdgeInsetsOnlyToExtensionFix extends DartFix {
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

      final topArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'top')
          .firstOrNull;

      final bottomArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'bottom')
          .firstOrNull;

      final leftArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'left')
          .firstOrNull;

      final rightArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'right')
          .firstOrNull;

      final args = [
        if (topArg != null) ('top', topArg.expression.toSource()),
        if (bottomArg != null) ('bottom', bottomArg.expression.toSource()),
        if (leftArg != null) ('left', leftArg.expression.toSource()),
        if (rightArg != null) ('right', rightArg.expression.toSource()),
      ];

      if (args.isEmpty) return;

      // If only one argument, use the specific extension
      if (args.length == 1) {
        final (side, value) = args.first;
        final extensionName = '${side}Only';

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Convert to $value.$extensionName',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            error.sourceRange,
            '$value.$extensionName',
          );
        });
      } else {
        // If multiple arguments, chain them
        final replacement = args
            .map((arg) => '(${arg.$2}).${arg.$1}Only')
            .join(' + ');

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Convert to chained extensions',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            error.sourceRange,
            replacement,
          );
        });
      }
    });
  }
}
