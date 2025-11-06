import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError, ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

part './fixes/avoid_edge_insets_only_fix.dart';

class AvoidEdgeInsetsOnly extends DartLintRule {
  AvoidEdgeInsetsOnly() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_edge_insets_only',
    problemMessage:
        'Use .topOnly, .bottomOnly, .leftOnly, or .rightOnly extensions.',
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
      if (constructorName == 'EdgeInsets.only' ||
          constructorName == 'const EdgeInsets.only') {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_EdgeInsetsOnlyToExtensionFix()];
}
