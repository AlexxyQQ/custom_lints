part of '../no_hardcoded_strings_rule.dart';

class _LocalizeFix extends DartFix {
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

      final _ =
          reporter.createChangeBuilder(
            message: 'Localize with easy_localization',
            priority: 90,
          )..addDartFileEdit((builder) {
            final filePath = resolver.path;

            // --- ⬇️ NEW "COMMON KEY" LOGIC ⬇️ ---

            // 1. Find project root and read the *entire* translations file first
            final projectRoot = _getProjectRoot(filePath);
            if (projectRoot == null) return; // Can't find project root

            final localizationFile = File(
              path.join(projectRoot, 'assets', 'translations', 'en-GB.json'),
            );

            Map<String, dynamic> translations = {};
            if (localizationFile.existsSync()) {
              final content = localizationFile.readAsStringSync();
              if (content.isNotEmpty) {
                try {
                  translations = jsonDecode(content) as Map<String, dynamic>;
                } catch (e) {
                  translations = {};
                }
              }
            }

            // 2. Search for the string value to see if it's a repeat
            final existingKey = _findKeyForValue(translations, stringValue);

            String localizationKey;
            String localeKeysPath;
            bool needsJsonWrite = false;

            if (existingKey != null) {
              // --- CASE A: String is a REPEAT ---

              if (existingKey.startsWith('common.')) {
                // It's already in common, just reuse it
                localizationKey = existingKey;
                localeKeysPath = existingKey.replaceAll('.', '_');
              } else {
                // It's a repeat, but nested. Move it to 'common'.
                // We'll create a new 'common' key and use that.
                // This leaves the old nested key, but all new uses will be 'common'.
                final generatedKey = _generateKeyFromString(stringValue);
                localizationKey = 'common.$generatedKey';
                localeKeysPath = 'common_$generatedKey';

                // We only need to write if the common key doesn't *also* already exist
                // _setNestedValue will check this for us.
                _setNestedValue(
                  translations,
                  localizationKey.split('.'),
                  stringValue,
                );
                needsJsonWrite = true; // We are adding a new 'common' key
              }
            } else {
              // --- CASE B: String is NEW ---
              // Use the original logic (nested path)
              localizationKey = _generateLocalizationKey(
                filePath,
                stringValue,
              );
              localeKeysPath = _generateLocaleKeysPath(
                filePath,
                stringValue,
              );

              // Add this new nested key to the JSON
              _setNestedValue(
                translations,
                localizationKey.split('.'),
                stringValue,
              );
              needsJsonWrite = true; // We are adding a new nested key
            }

            // 3. Write back to file *only if* we added a new key
            if (needsJsonWrite) {
              _writeTranslations(localizationFile, translations);
            }

            // --- ⬆️ END OF NEW LOGIC ⬆️ ---

            // 4. Replace the hardcoded string with the (now correct) LocaleKeys reference
            builder.addSimpleReplacement(
              node.sourceRange,
              'LocaleKeys.$localeKeysPath.tr()',
            );

            // 5. Add imports if not present
            final compilationUnit = node
                .thisOrAncestorOfType<CompilationUnit>();
            if (compilationUnit != null) {
              // Add easy_localization import for .tr()
              if (!_hasEasyLocalizationImport(compilationUnit)) {
                builder.addSimpleInsertion(
                  0,
                  "import 'package:easy_localization/easy_localization.dart';\n",
                );
              }

              // Add LocaleKeys import
              if (!_hasLocaleKeysImport(compilationUnit)) {
                final packageName = _getPackageName(projectRoot);
                if (packageName != null) {
                  final foundPath = _findLocaleKeysPath(projectRoot);

                  String importPath;
                  if (foundPath != null) {
                    importPath = 'package:$packageName/$foundPath';
                  } else {
                    importPath =
                        'package:$packageName/generated/locale_keys.g.dart';
                  }

                  builder.addSimpleInsertion(0, "import '$importPath';\n");
                }
              }
            }
          });
    });
  }

  // --- ⬇️ NEW HELPER ⬇️ ---
  /// Recursively searches a map for a [targetValue] and returns its key path.
  String? _findKeyForValue(Map<String, dynamic> map, String targetValue) {
    String? search(Map<String, dynamic> currentMap, String currentPath) {
      for (final entry in currentMap.entries) {
        final newPath = currentPath.isEmpty
            ? entry.key
            : '$currentPath.${entry.key}';

        if (entry.value is String && entry.value == targetValue) {
          return newPath; // Found it!
        }

        if (entry.value is Map<String, dynamic>) {
          final result = search(entry.value as Map<String, dynamic>, newPath);
          if (result != null) {
            return result; // Found in nested map
          }
        }
      }
      return null; // Not found in this branch
    }

    return search(map, '');
  }

  String _generateLocalizationKey(String filePath, String stringValue) {
    final parts = _getFilePathParts(filePath);
    final key = _generateKeyFromString(stringValue);
    return '${parts.join('.')}.$key';
  }

  String _generateLocaleKeysPath(String filePath, String stringValue) {
    final parts = _getFilePathParts(filePath);
    final key = _generateKeyFromString(stringValue).replaceAll('.', '_');
    return '${parts.join('_')}_$key';
  }

  List<String> _getFilePathParts(String filePath) {
    try {
      final normalizedPath = path.normalize(filePath);
      final allParts = path.split(normalizedPath);

      int libIndex = -1;
      for (int i = 0; i < allParts.length; i++) {
        if (allParts[i] == 'lib') {
          libIndex = i;
          break;
        }
      }

      List<String> relativeParts;
      if (libIndex != -1) {
        relativeParts = allParts.sublist(libIndex + 1);
      } else {
        relativeParts = allParts;
      }

      final relativePath = path.joinAll(relativeParts);
      final withoutExtension = path.withoutExtension(relativePath);
      final parts = path.split(withoutExtension);

      final sanitizedParts = parts
          .map((part) => part.replaceAll('.', '_'))
          .toList();

      return sanitizedParts;
    } catch (e) {
      return [path.basenameWithoutExtension(filePath).replaceAll('.', '_')];
    }
  }

  String _generateKeyFromString(String value) {
    final words = value
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(4)
        .toList();

    if (words.isEmpty) return 'text';

    return words.first +
        words
            .skip(1)
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join();
  }

  // --- ⬇️ NEW HELPER ⬇️ ---
  /// Writes the translation map to the specified file.
  void _writeTranslations(File file, Map<String, dynamic> translations) {
    try {
      file.createSync(recursive: true);
      const encoder = JsonEncoder.withIndent('  ');
      file.writeAsStringSync(encoder.convert(translations));
    } catch (e) {
      // Silently fail
    }
  }

  /// Recursively sets a value in a nested map, but *only* if the key doesn't exist.
  void _setNestedValue(
    Map<String, dynamic> map,
    List<String> keys,
    String value,
  ) {
    if (keys.isEmpty) return;

    final currentKey = keys[0];

    if (keys.length == 1) {
      // Only add the key if it doesn't already exist
      if (!map.containsKey(currentKey)) {
        map[currentKey] = value;
      }
      return;
    }

    if (!map.containsKey(currentKey) || map[currentKey] is! Map) {
      map[currentKey] = <String, dynamic>{};
    }

    _setNestedValue(
      map[currentKey] as Map<String, dynamic>,
      keys.sublist(1),
      value,
    );
  }

  bool _hasEasyLocalizationImport(CompilationUnit unit) {
    return unit.directives.any((directive) {
      if (directive is ImportDirective) {
        final uriContent = directive.uri.stringValue;
        return uriContent?.contains('easy_localization.dart') ?? false;
      }
      return false;
    });
  }

  bool _hasLocaleKeysImport(CompilationUnit unit) {
    return unit.directives.any((directive) {
      if (directive is ImportDirective) {
        final uriContent = directive.uri.stringValue;
        return uriContent?.contains('locale_keys.g.dart') ?? false;
      }
      return false;
    });
  }

  String? _getProjectRoot(String filePath) {
    try {
      var directory = Directory(path.dirname(filePath));
      while (true) {
        final pubspecFile = File(path.join(directory.path, 'pubspec.yaml'));
        if (pubspecFile.existsSync()) {
          return directory.path;
        }
        final parent = directory.parent;
        if (parent.path == directory.path) {
          return null;
        }
        directory = parent;
      }
    } catch (e) {
      return null;
    }
  }

  String? _getPackageName(String projectRoot) {
    try {
      final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
      if (!pubspecFile.existsSync()) return null;

      final pubspecContent = pubspecFile.readAsStringSync();
      final nameMatch = RegExp(
        r'^name:\s*(\w+)',
        multiLine: true,
      ).firstMatch(pubspecContent);
      return nameMatch?.group(1);
    } catch (e) {
      return null;
    }
  }

  String? _findLocaleKeysPath(String projectRoot) {
    final libDir = Directory(path.join(projectRoot, 'lib'));
    if (!libDir.existsSync()) return null;

    try {
      final files = libDir.listSync(recursive: true, followLinks: false);
      final file = files.firstWhere(
        (entity) =>
            entity is File &&
            path.basename(entity.path) == 'locale_keys.g.dart',
      );

      if (file != null) {
        final relativePath = path.relative(file.path, from: libDir.path);
        return path.toUri(relativePath).toString();
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
