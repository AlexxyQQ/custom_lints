part of '../avoid_edge_insets_all.dart';

class _EdgeInsetsAllToExtensionFix extends DartFix {
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

      final constructorName = node.constructorName.toSource();
      if (constructorName != 'EdgeInsets.all' &&
          constructorName != 'const EdgeInsets.all') {
        return;
      }

      final value = node.argumentList.arguments.firstOrNull?.toSource();
      if (value == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to ${value}.allPadding',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(error.sourceRange, '$value.allPadding');
      });
    });
  }
}
