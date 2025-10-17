// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/diagnostic/diagnostic.dart';
// import 'package:analyzer/error/error.dart' hide LintCode;
// import 'package:analyzer/error/listener.dart';
// import 'package:custom_lint_builder/custom_lint_builder.dart';

// class EvenNumbersOnlyLintRule extends DartLintRule {
//   const EvenNumbersOnlyLintRule() : super(code: _code);

//   static const _code = LintCode(
//     name: 'even_numbers_only_spacing',
//     problemMessage: 'Odd numbers are not allowed with spacing extensions ⚠️',
//     correctionMessage:
//         'Use an even number with spacing extensions like verticalGap, horizontalGap, allPadding, etc.',
//     errorSeverity: DiagnosticSeverity.ERROR,
//   );

//   // List of extension methods that only accept even numbers
//   static const _spacingExtensions = {
//     'verticalGap',
//     'horizontalGap',
//     'allPadding',
//     'symmetricPadding',
//     'onlyPadding',
//     'topPadding',
//     'bottomPadding',
//     'leftPadding',
//     'rightPadding',
//     'verticalPadding',
//     'horizontalPadding',
//     'margin',
//     'verticalMargin',
//     'horizontalMargin',
//     'allMargin',
//     'spacing',
//     'gap',
//   };

//   @override
//   void run(
//     CustomLintResolver resolver,
//     DiagnosticReporter reporter,
//     CustomLintContext context,
//   ) {
//     context.registry.addMethodInvocation((node) {
//       _checkMethodInvocation(node, reporter);
//     });
//   }

//   void _checkMethodInvocation(
//     MethodInvocation node,
//     DiagnosticReporter reporter,
//   ) {
//     // Check if the method name matches one of our spacing extensions
//     if (!_spacingExtensions.contains(node.methodName.name)) return;

//     // Check for ignore comments
//     if (_hasIgnoreComment(node)) return;

//     // The receiver of the method should be an integer literal
//     final receiver = node.target;
//     if (receiver is! IntegerLiteral) return;

//     final numberValue = receiver.value;
//     if (numberValue == null) return;

//     // Check if the number is odd
//     if (numberValue.isOdd) {
//       reporter.atNode(receiver, _code);
//     }
//   }

//   bool _hasIgnoreComment(MethodInvocation node) {
//     final compilationUnit = node.thisOrAncestorOfType<CompilationUnit>();
//     if (compilationUnit == null) return false;

//     final lineInfo = compilationUnit.lineInfo;
//     final location = lineInfo.getLocation(node.offset);
//     final line = location.lineNumber;

//     // Check for ignore comment on the same line or the line before
//     final source = compilationUnit.toSource();
//     final lines = source.split('\n');

//     if (line > 0 && line <= lines.length) {
//       // Check current line
//       final currentLine = lines[line - 1];
//       if (_containsIgnoreComment(currentLine)) return true;

//       // Check previous line
//       if (line > 1) {
//         final previousLine = lines[line - 2];
//         if (_containsIgnoreComment(previousLine)) return true;
//       }
//     }

//     return false;
//   }

//   bool _containsIgnoreComment(String line) {
//     final ignorePatterns = [
//       RegExp(r'//\s*ignore:\s*even_numbers_only_spacing'),
//       RegExp(r'//\s*ignore_for_file:\s*even_numbers_only_spacing'),
//       RegExp(r'//\s*ignore:\s*odd.number', caseSensitive: false),
//       RegExp(r'//\s*odd.ok', caseSensitive: false),
//     ];

//     return ignorePatterns.any((pattern) => pattern.hasMatch(line));
//   }

//   @override
//   List<Fix> getFixes() => [_RoundToEvenNumberFix(), _AddIgnoreCommentFix()];
// }

// class _RoundToEvenNumberFix extends DartFix {
//   @override
//   void run(
//     CustomLintResolver resolver,
//     ChangeReporter reporter,
//     CustomLintContext context,
//     Diagnostic analysisError,
//     List<Diagnostic> others,
//   ) {
//     context.registry.addIntegerLiteral((node) {
//       if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

//       final numberValue = node.value;
//       if (numberValue == null || numberValue.isEven) return;

//       final changeBuilder = reporter.createChangeBuilder(
//         message: 'Round to nearest even number',
//         priority: 100,
//       );

//       changeBuilder.addDartFileEdit((builder) {
//         // Round odd number to nearest even number
//         final roundedNumber =
//             (numberValue.isOdd) ? ((numberValue / 2).ceil() * 2) : numberValue;

//         builder.addSimpleReplacement(
//           node.sourceRange,
//           roundedNumber.toString(),
//         );
//       });
//     });
//   }
// }

// class _AddIgnoreCommentFix extends DartFix {
//   @override
//   void run(
//     CustomLintResolver resolver,
//     ChangeReporter reporter,
//     CustomLintContext context,
//     Diagnostic analysisError,
//     List<Diagnostic> others,
//   ) {
//     context.registry.addMethodInvocation((node) {
//       if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

//       final changeBuilder = reporter.createChangeBuilder(
//         message: 'Add ignore comment',
//         priority: 80,
//       );

//       changeBuilder.addDartFileEdit((builder) {
//         final compilationUnit = node.thisOrAncestorOfType<CompilationUnit>();
//         if (compilationUnit == null) return;

//         final lineInfo = compilationUnit.lineInfo;
//         final location = lineInfo.getLocation(node.offset);
//         final lineStart = lineInfo.getOffsetOfLine(location.lineNumber - 1);

//         // Find the indentation of the current line
//         final source = compilationUnit.toSource();
//         final currentLineStart = source.substring(lineStart, node.offset);
//         final indentMatch = RegExp(r'^(\s*)').firstMatch(currentLineStart);
//         final indent = indentMatch?.group(1) ?? '';

//         builder.addSimpleInsertion(
//           lineStart,
//           '$indent// ignore: even_numbers_only_spacing\n',
//         );
//       });
//     });
//   }
// }
