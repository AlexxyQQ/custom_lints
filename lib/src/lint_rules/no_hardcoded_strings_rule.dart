import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' show AnalysisError, ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class HardcodedStringLintRule extends DartLintRule {
  const HardcodedStringLintRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hardcoded_strings_in_widgets',
    problemMessage:
        'String literals should not be declared inside a widget '
        'class. '
        'If this string is used for presentation, such as in a Text widget, '
        'it will make harder adding l10n support. '
        'If this string is used for comparison, such as: membership == "free", '
        'it is a sign of primitive obsession.\n\n'
        'Example of correct usage:\n'
        '- Using easy_localization: Text(LocaleKeys.some_key.tr())\n'
        '- Using Flutter gen-l10n: Text(AppLocalizations.of(context)!.someKey)',
    correctionMessage:
        'If this is for presentation:\n'
        '1. Use a localization package (easy_localization or Flutter gen-l10n)\n'
        '2. Generate localization keys\n'
        '3. Add translations to locale files\n'
        '4. Use generated keys instead of hardcoded strings\n\n'
        'If this is for comparison, consider using an enum instead.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addStringLiteral((node) {
      _checkStringLiteral(node, reporter);
    });
  }

  void _checkStringLiteral(StringLiteral node, ErrorReporter reporter) {
    // Check for ignore comments
    if (_hasIgnoreComment(node)) return;

    // Only check strings that are passed to widgets
    if (!_isPassedToWidget(node)) return;

    // Skip empty strings
    if (node.stringValue?.isEmpty ?? true) return;

    // Skip very short strings (single characters, operators, etc.)
    if (node.stringValue!.length <= 2) return;

    // Skip strings used as map keys
    if (_isMapKey(node)) return;

    // Skip strings in widget properties where hardcoding is acceptable
    if (_isAcceptableWidgetProperty(node)) return;

    // Skip strings that look like technical identifiers or configuration
    if (_isTechnicalString(node.stringValue!)) return;

    reporter.atNode(node, _code);
  }

  bool _isMapKey(StringLiteral node) {
    final parent = node.parent;

    // Check if this string is used as an index in bracket notation (map['key'])
    if (parent is IndexExpression) {
      return parent.index == node;
    }

    // Check if this string is used as a key in map literal ({key: value})
    if (parent is MapLiteralEntry) {
      return parent.key == node;
    }

    return false;
  }

  bool _isPassedToWidget(StringLiteral node) {
    final argumentList = node.thisOrAncestorOfType<ArgumentList>();
    if (argumentList == null) return false;

    var walker = node.parent;
    while (walker != null && walker != argumentList) {
      if (walker is FunctionExpression || walker is FunctionBody) {
        return false;
      }
      walker = walker.parent;
    }

    final owner = argumentList.parent;
    if (owner is! InstanceCreationExpression) return false;

    final type = owner.staticType;
    if (type == null) return false;

    final element = type.element;
    if (element == null || !_isFlutterWidget(element)) return false;

    for (final arg in argumentList.arguments) {
      if (identical(arg, node)) return true;
      if (arg is NamedExpression && identical(arg.expression, node)) {
        return true;
      }
    }

    return false;
  }

  bool _isFlutterWidget(Element? element) {
    if (element == null) return false;

    if (element is ClassElement) {
      return _extendsWidget(element);
    }

    return false;
  }

  bool _extendsWidget(ClassElement element) {
    ClassElement? current = element;

    while (current != null) {
      final className = current.name;

      if (_isWidgetBaseClass(className)) {
        return true;
      }

      final supertype = current.supertype;
      if (supertype != null) {
        final supertypeElement = supertype.element;
        current = supertypeElement is ClassElement ? supertypeElement : null;
      } else {
        break;
      }
    }

    return false;
  }

  bool _isWidgetBaseClass(String className) {
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

    return widgetBaseClasses.contains(className);
  }

  bool _isAcceptableWidgetProperty(StringLiteral node) {
    final parent = node.parent;
    if (parent is! NamedExpression) return false;

    final propertyName = parent.name.label.name;

    const acceptableProperties = {
      'semanticsLabel',
      'excludeSemantics',
      'restorationId',
      'heroTag',
      'key',
      'debugLabel',
      'fontFamily',
      'package',
      'name',
      'asset',
      'tooltip',
      'textDirection',
      'locale',
      'materialType',
      'clipBehavior',
      'crossAxisAlignment',
      'mainAxisAlignment',
      'textAlign',
      'textBaseline',
      'overflow',
      'softWrap',
      'textScaleFactor',
    };

    return acceptableProperties.contains(propertyName);
  }

  bool _isTechnicalString(String value) {
    final technicalPatterns = [
      RegExp(r'^\w+://'),
      RegExp(r'^[\w\-\.]+@[\w\-\.]+\.\w+'),
      RegExp(r'^#[0-9A-Fa-f]{3,8}'),
      RegExp(r'^\d+(\.\d+)?[a-zA-Z]*'),
      RegExp(r'^[A-Z][A-Z0-9]*_[A-Z0-9_]*'),
      RegExp(r'^[a-z]+_[a-z_]+'),
      RegExp(r'^/[\w/\-\.]*'),
      RegExp(r'^\w+\.\w+'),
      RegExp(r'^[\w\-]+\.[\w]+'),
      RegExp(r'^[a-zA-Z0-9]*[_\-0-9]+[a-zA-Z0-9_\-]*'),
    ];

    return technicalPatterns.any((pattern) => pattern.hasMatch(value.trim()));
  }

  bool _hasIgnoreComment(StringLiteral node) {
    final compilationUnit = node.thisOrAncestorOfType<CompilationUnit>();
    if (compilationUnit == null) return false;

    final lineInfo = compilationUnit.lineInfo;
    final location = lineInfo.getLocation(node.offset);
    final line = location.lineNumber;

    final source = compilationUnit.toSource();
    final lines = source.split('\n');

    if (line > 0 && line <= lines.length) {
      final currentLine = lines[line - 1];
      if (_containsIgnoreComment(currentLine)) return true;

      if (line > 1) {
        final previousLine = lines[line - 2];
        if (_containsIgnoreComment(previousLine)) return true;
      }
    }

    return false;
  }

  bool _containsIgnoreComment(String line) {
    final ignorePatterns = [
      RegExp(r'//\s*ignore:\s*avoid_hardcoded_strings_in_widgets'),
      RegExp(r'//\s*ignore_for_file:\s*avoid_hardcoded_strings_in_widgets'),
      RegExp(r'//\s*ignore:\s*hardcoded.string', caseSensitive: false),
      RegExp(r'//\s*hardcoded.ok', caseSensitive: false),
    ];

    return ignorePatterns.any((pattern) => pattern.hasMatch(line));
  }

  @override
  List<Fix> getFixes() => [_AddIgnoreCommentFix(), _ExtractToVariableFix()];
}

class _AddIgnoreCommentFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addStringLiteral((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add ignore comment',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final compilationUnit = node.thisOrAncestorOfType<CompilationUnit>();
        if (compilationUnit == null) return;

        final lineInfo = compilationUnit.lineInfo;
        final location = lineInfo.getLocation(node.offset);
        final lineStart = lineInfo.getOffsetOfLine(location.lineNumber - 1);

        final source = compilationUnit.toSource();
        final currentLineStart = source.substring(lineStart, node.offset);
        final indentMatch = RegExp(r'^(\s*)').firstMatch(currentLineStart);
        final indent = indentMatch?.group(1) ?? '';

        builder.addSimpleInsertion(
          lineStart,
          '$indent// ignore: avoid_hardcoded_strings_in_widgets\n',
        );
      });
    });
  }
}

class _ExtractToVariableFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addStringLiteral((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final stringValue = node.stringValue;
      if (stringValue == null || stringValue.isEmpty) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Extract to variable',
        priority: 70,
      );

      changeBuilder.addDartFileEdit((builder) {
        final variableName = _generateVariableName(stringValue);

        var parent = node.parent;
        while (parent != null &&
            parent is! MethodDeclaration &&
            parent is! ClassDeclaration) {
          parent = parent.parent;
        }

        if (parent is MethodDeclaration) {
          final methodBody = parent.body;
          if (methodBody is BlockFunctionBody) {
            final block = methodBody.block;
            final insertOffset = block.leftBracket.offset + 1;

            builder.addSimpleInsertion(
              insertOffset,
              '\n    const $variableName = ${node.toSource()};\n',
            );

            builder.addSimpleReplacement(node.sourceRange, variableName);
          }
        } else if (parent is ClassDeclaration) {
          final insertOffset = parent.leftBracket.offset + 1;

          builder.addSimpleInsertion(
            insertOffset,
            '\n  static const $variableName = ${node.toSource()};\n',
          );

          builder.addSimpleReplacement(node.sourceRange, variableName);
        }
      });
    });
  }

  String _generateVariableName(String value) {
    final words =
        value
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .trim()
            .toLowerCase()
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .take(3)
            .toList();

    if (words.isEmpty) return 'textValue';

    final camelCase =
        words.first +
        words
            .skip(1)
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join();

    return '${camelCase}Text';
  }
}
