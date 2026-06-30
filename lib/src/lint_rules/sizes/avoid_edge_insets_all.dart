import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidEdgeInsetsAll extends AnalysisRule {
  static const _code = LintCode(
    'avoid_edge_insets_all',
    'Use the .allPadding extension instead of EdgeInsets.all(...).',
    correctionMessage: 'Try using .allPadding instead.',
  );

  AvoidEdgeInsetsAll()
      : super(
          name: 'avoid_edge_insets_all',
          description: 'Use the .allPadding extension instead of EdgeInsets.all(...).',
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
    if (constructorName == 'EdgeInsets.all' ||
        constructorName == 'const EdgeInsets.all') {
      rule.reportAtNode(node);
    }
  }
}
