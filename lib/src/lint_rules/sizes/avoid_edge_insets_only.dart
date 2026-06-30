import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidEdgeInsetsOnly extends AnalysisRule {
  static const _code = LintCode(
    'avoid_edge_insets_only',
    'Use .topOnly, .bottomOnly, .leftOnly, or .rightOnly extensions.',
  );

  AvoidEdgeInsetsOnly()
      : super(
          name: 'avoid_edge_insets_only',
          description: 'Use .topOnly, .bottomOnly, .leftOnly, or .rightOnly extensions.',
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
    if (constructorName == 'EdgeInsets.only' ||
        constructorName == 'const EdgeInsets.only') {
      rule.reportAtNode(node);
    }
  }
}
