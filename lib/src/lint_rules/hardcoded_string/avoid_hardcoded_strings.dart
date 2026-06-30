import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidHardcodedStrings extends AnalysisRule {
  AvoidHardcodedStrings()
    : super(
        name: 'avoid_hardcoded_strings',
        description: 'Detects hardcoded strings in widget constructors.',
      );

  static const LintCode _code = LintCode(
    'avoid_hardcoded_strings',
    'Hardcoded string detected. Use a variable or localized string instead.',
    correctionMessage:
        'Extract this string to a constant variable or use a localization key.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry
      ..addSimpleStringLiteral(this, visitor)
      ..addStringInterpolation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  /// Named parameters whose values are user-visible display text.
  static const _displayParams = {
    'data', // Text widget positional parameter name
    'text',
    'label',
    'title',
    'subtitle',
    'hint',
    'hintText',
    'labelText',
    'helperText',
    'errorText',
    'counterText',
    'prefixText',
    'suffixText',
    'message',
    'description',
    'content',
    'placeholder',
    'buttonText',
    'confirmText',
    'cancelText',
    'emptyText',
    'tooltip',
  };

  /// Named parameters that are NOT user-visible display text — skip these.
  static const _nonDisplayParams = {
    'semanticsLabel',
    'restorationId',
    'heroTag',
    'debugLabel',
    'fontFamily',
    'package',
    'name',
    'initialRoute',
    'routeName',
    'id',
    'key',
    'tag',
    'barrierLabel',
    'textDirection',
    'locale',
    'clipBehavior',
    'curve',
  };

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _handleStringLiteral(node);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _handleStringLiteral(node);
  }

  void _handleStringLiteral(StringLiteral node) {
    if (_shouldSkip(node)) return;
    rule.reportAtNode(node);
  }

  bool _shouldSkip(StringLiteral node) {
    final value = node.stringValue;

    // Skip null, empty, or whitespace-only strings
    if (value == null || value.trim().isEmpty) return true;

    // Skip very short strings (single chars, abbreviations, operators)
    if (value.trim().length <= 2) return true;

    // Skip route/path strings  ('/home', '/login', ':id')
    if (_isRouteName(value)) return true;

    // Skip strings that are clearly technical (URLs, hex, snake_case keys…)
    if (_isTechnicalString(value)) return true;

    // Skip map literal keys  ({'key': value}) and index access (map['key'])
    if (_isMapKeyOrIndex(node)) return true;

    // Skip non-display named parameters (fontFamily, semanticsLabel, etc.)
    if (_isNonDisplayNamedParam(node)) return true;

    // Only flag strings that are in a widget display context
    if (!_isInWidgetDisplayContext(node)) return true;

    return false;
  }

  /// Route paths start with '/' (navigation) or ':' (path parameters).
  bool _isRouteName(String value) {
    return value.startsWith('/') || value.startsWith(':');
  }

  /// Patterns that indicate a technical / non-UI string value.
  static final _technicalPatterns = [
    RegExp(r'^\w+://'), // URLs: https://, http://
    RegExp(r'^#[0-9A-Fa-f]{3,8}$'), // Hex colors: #FFF, #AABBCC
    RegExp(r'^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$'), // SCREAMING_SNAKE_CASE
    // snake_case: locale codes, env keys (e.g. en_US, api_key)
    RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)+$'),
    RegExp('^package:'), // Flutter package imports
    RegExp('^assets?/'), // Asset paths
    RegExp('^fonts?/'), // Font asset paths
    RegExp(r'^\d+(\.\d+)*$'), // Version strings / plain numbers
    RegExp(r'^[a-f0-9\-]{36}$'), // UUIDs
  ];

  bool _isTechnicalString(String value) {
    return _technicalPatterns.any((p) => p.hasMatch(value.trim()));
  }

  bool _isMapKeyOrIndex(StringLiteral node) {
    final parent = node.parent;
    if (parent is MapLiteralEntry) return parent.key == node;
    if (parent is IndexExpression) return parent.index == node;
    return false;
  }

  bool _isNonDisplayNamedParam(StringLiteral node) {
    final parent = node.parent;
    if (parent is NamedArgument) {
      return _nonDisplayParams.contains(parent.name.lexeme);
    }
    return false;
  }

  /// Returns true if the string is a direct argument (positional or
  /// display-named) inside a Widget constructor.
  bool _isInWidgetDisplayContext(StringLiteral node) {
    final parent = node.parent;

    // Case 1: Named argument — only flag if it's a known display param
    if (parent is NamedArgument) {
      if (!_displayParams.contains(parent.name.lexeme)) return false;
      final argList = parent.parent;
      if (argList is! ArgumentList) return false;
      return _isWidgetConstructor(argList.parent);
    }

    // Case 2: Positional argument directly in an argument list
    if (parent is ArgumentList) {
      return _isWidgetConstructor(parent.parent);
    }

    return false;
  }

  bool _isWidgetConstructor(AstNode? node) {
    if (node is! InstanceCreationExpression) return false;
    final element = node.staticType?.element;
    return element is ClassElement && _extendsWidget(element);
  }

  bool _extendsWidget(ClassElement element) {
    const widgetBaseClasses = {
      'Widget',
      'StatelessWidget',
      'StatefulWidget',
      'InheritedWidget',
      'RenderObjectWidget',
      'LeafRenderObjectWidget',
      'SingleChildRenderObjectWidget',
      'MultiChildRenderObjectWidget',
      'ProxyWidget',
      'ParentDataWidget',
      'InheritedTheme',
      'PreferredSizeWidget',
    };

    ClassElement? current = element;
    while (current != null) {
      if (widgetBaseClasses.contains(current.name)) return true;
      final supertype = current.supertype;
      if (supertype == null) break;
      final next = supertype.element;
      current = next is ClassElement ? next : null;
    }
    return false;
  }
}
