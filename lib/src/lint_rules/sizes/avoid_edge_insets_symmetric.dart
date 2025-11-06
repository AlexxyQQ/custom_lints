// lib/src/avoid_edge_insets_symmetric.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError, ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

part './fixes/avoid_edge_insets_symmetric_fix.dart';

class AvoidEdgeInsetsSymmetric extends DartLintRule {
  AvoidEdgeInsetsSymmetric() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_edge_insets_symmetric',
    problemMessage:
        'Use .horizontalPadding or .verticalPadding extensions instead.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName.toSource();
      if (constructorName == 'EdgeInsets.symmetric' ||
          constructorName == 'const EdgeInsets.symmetric') {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_EdgeInsetsSymmetricToExtensionFix()];
}
