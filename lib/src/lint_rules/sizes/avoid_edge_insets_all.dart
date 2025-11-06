// lib/src/avoid_edge_insets_all.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError, ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

part './fixes/avoid_edge_insets_all_fix.dart';

class AvoidEdgeInsetsAll extends DartLintRule {
  AvoidEdgeInsetsAll() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_edge_insets_all',
    problemMessage:
        'Use the .allPadding extension instead of EdgeInsets.all(...).',
    correctionMessage: 'Try using .allPadding instead.',
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
      if (constructorName == 'EdgeInsets.all' ||
          constructorName == 'const EdgeInsets.all') {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_EdgeInsetsAllToExtensionFix()];
}
