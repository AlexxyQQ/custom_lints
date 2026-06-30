import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidEdgeInsetsSymmetric extends AnalysisRule {
  static const _code = LintCode(
    'avoid_edge_insets_symmetric',
    'Use .horizontalPadding or .verticalPadding extensions instead.',
  );

  AvoidEdgeInsetsSymmetric()
      : super(
          name: 'avoid_edge_insets_symmetric',
          description: 'Use .horizontalPadding or .verticalPadding extensions instead.',
        );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constructorName = node.constructorName.toSource();
    if (constructorName == 'EdgeInsets.symmetric' ||
        constructorName == 'const EdgeInsets.symmetric') {
      rule.reportAtNode(node);
    }
  }
}
