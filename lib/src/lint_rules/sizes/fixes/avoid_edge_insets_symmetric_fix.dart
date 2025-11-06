part of '../avoid_edge_insets_symmetric.dart';

class _EdgeInsetsSymmetricToExtensionFix extends DartFix {
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

      final horizontalArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'horizontal')
          .firstOrNull;

      final verticalArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'vertical')
          .firstOrNull;

      if (horizontalArg != null && verticalArg == null) {
        final value = horizontalArg.expression.toSource();
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Convert to $value.horizontalPadding',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            error.sourceRange,
            '$value.horizontalPadding',
          );
        });
      } else if (verticalArg != null && horizontalArg == null) {
        final value = verticalArg.expression.toSource();
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Convert to $value.verticalPadding',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            error.sourceRange,
            '$value.verticalPadding',
          );
        });
      } else if (horizontalArg != null && verticalArg != null) {
        final hValue = horizontalArg.expression.toSource();
        final vValue = verticalArg.expression.toSource();
        final changeBuilder = reporter.createChangeBuilder(
          message:
              'Convert to $hValue.horizontalPadding + $vValue.verticalPadding',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            error.sourceRange,
            '$hValue.horizontalPadding + $vValue.verticalPadding',
          );
        });
      }
    });
  }
}
