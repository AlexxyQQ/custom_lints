import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidSizedBoxHeight extends AnalysisRule {
  static const _code = LintCode(
    'avoid_sized_box_height',
    'Use the .verticalGap extension instead of SizedBox(height: ...).',
    correctionMessage: 'Try using .verticalGap instead.',
  );

  AvoidSizedBoxHeight()
      : super(
          name: 'avoid_sized_box_height',
          description: 'Use the .verticalGap extension instead of SizedBox(height: ...).',
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
    final type = node.staticType?.getDisplayString(withNullability: false);
    if (type != 'SizedBox') {
      return;
    }

    final heightArg = node.argumentList.arguments
        .whereType<NamedExpression>()
        .where((arg) => arg.name.label.name == 'height')
        .firstOrNull;

    final widthArg = node.argumentList.arguments
        .whereType<NamedExpression>()
        .where((arg) => arg.name.label.name == 'width')
        .firstOrNull;

    final childArg = node.argumentList.arguments
        .whereType<NamedExpression>()
        .where((arg) => arg.name.label.name == 'child')
        .firstOrNull;

    if (heightArg != null && widthArg == null && childArg == null) {
      rule.reportAtNode(node);
    }
  }
}
