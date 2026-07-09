import 'dart:convert';
import 'dart:io';

/// 根据 JSON 文件生成 freezed + json_serializable 源文件。
void main(List<String> args) {
  final options = _GenerateOptions.parse(args);
  if (options == null) {
    _printUsage();
    exitCode = 64;
    return;
  }

  final inputFile = File(options.inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('JSON file not found: ${options.inputPath}');
    exitCode = 66;
    return;
  }

  final jsonValue = jsonDecode(inputFile.readAsStringSync());
  final rootValue = jsonValue is List && jsonValue.isNotEmpty
      ? jsonValue.first
      : jsonValue;
  if (rootValue is! Map<String, dynamic>) {
    stderr.writeln('JSON root must be an object or a non-empty object array.');
    exitCode = 65;
    return;
  }

  final generator = _FreezedModelGenerator(
    rootClassName: options.rootClassName,
    outputPath: options.outputPath,
  );
  final content = generator.generate(rootValue);
  final outputFile = File(options.outputPath);
  outputFile.parent.createSync(recursive: true);

  if (outputFile.existsSync() && outputFile.readAsStringSync() == content) {
    stdout.writeln('unchanged ${outputFile.path}');
    return;
  }

  outputFile.writeAsStringSync(content);
  stdout.writeln('generated ${outputFile.path}');
}

/// 命令行参数配置。
class _GenerateOptions {
  const _GenerateOptions({
    required this.inputPath,
    required this.outputPath,
    required this.rootClassName,
  });

  final String inputPath;
  final String outputPath;
  final String rootClassName;

  static _GenerateOptions? parse(List<String> args) {
    String? inputPath;
    String? outputPath;
    String? rootClassName;

    for (var index = 0; index < args.length; index += 1) {
      final arg = args[index];
      switch (arg) {
        case '--input':
        case '-i':
          inputPath = _nextValue(args, index);
          index += 1;
          break;
        case '--output':
        case '-o':
          outputPath = _nextValue(args, index);
          index += 1;
          break;
        case '--class':
        case '-c':
          rootClassName = _nextValue(args, index);
          index += 1;
          break;
        case '--help':
        case '-h':
          return null;
        default:
          stderr.writeln('Unknown argument: $arg');
          return null;
      }
    }

    if (inputPath == null || outputPath == null || rootClassName == null) {
      return null;
    }

    return _GenerateOptions(
      inputPath: inputPath,
      outputPath: outputPath,
      rootClassName: _toPascalCase(rootClassName),
    );
  }

  static String? _nextValue(List<String> args, int index) {
    final valueIndex = index + 1;
    if (valueIndex >= args.length || args[valueIndex].startsWith('-')) {
      return null;
    }

    return args[valueIndex];
  }
}

/// freezed class 生成器，负责类型推断与嵌套模型拆分。
class _FreezedModelGenerator {
  _FreezedModelGenerator({
    required this.rootClassName,
    required this.outputPath,
  });

  final String rootClassName;
  final String outputPath;
  final _classes = <_ModelClass>[];
  final _usedClassNames = <String>{};

  String generate(Map<String, dynamic> rootValue) {
    _collectClass(rootClassName, rootValue);

    final fileName = _fileName(outputPath);
    final partName = fileName.substring(0, fileName.length - '.dart'.length);
    final buffer = StringBuffer()
      ..writeln("import 'package:freezed_annotation/freezed_annotation.dart';")
      ..writeln()
      ..writeln("part '$partName.freezed.dart';")
      ..writeln("part '$partName.g.dart';")
      ..writeln();

    for (var index = 0; index < _classes.length; index += 1) {
      if (index > 0) {
        buffer.writeln();
      }
      _writeClass(buffer, _classes[index]);
    }

    return buffer.toString();
  }

  String _collectClass(String preferredClassName, Map<String, dynamic> value) {
    final className = _uniqueClassName(_toPascalCase(preferredClassName));
    final fields = <_ModelField>[];
    _classes.add(_ModelClass(name: className, fields: fields));

    value.forEach((jsonKey, fieldValue) {
      final fieldName = _safeFieldName(jsonKey);
      fields.add(
        _ModelField(
          jsonKey: jsonKey,
          name: fieldName,
          type: _inferType(className, jsonKey, fieldValue),
        ),
      );
    });

    return className;
  }

  String _inferType(String ownerClassName, String jsonKey, Object? value) {
    if (value is String) {
      return 'String';
    }
    if (value is bool) {
      return 'bool';
    }
    if (value is int) {
      return 'int';
    }
    if (value is double) {
      return 'num';
    }
    if (value is Map<String, dynamic>) {
      return _collectClass('$ownerClassName ${_nestedName(jsonKey)}', value);
    }
    if (value is List) {
      return 'List<${_inferListItemType(ownerClassName, jsonKey, value)}>';
    }

    return 'dynamic';
  }

  String _inferListItemType(
    String ownerClassName,
    String jsonKey,
    List<Object?> value,
  ) {
    final firstNonNull = value.where((item) => item != null).firstOrNull;
    if (firstNonNull == null) {
      return 'dynamic';
    }
    if (firstNonNull is Map<String, dynamic>) {
      return _collectClass(
        '$ownerClassName ${_nestedName(jsonKey)}',
        firstNonNull,
      );
    }
    if (firstNonNull is String) {
      return 'String';
    }
    if (firstNonNull is bool) {
      return 'bool';
    }
    if (firstNonNull is int) {
      return 'int';
    }
    if (firstNonNull is double) {
      return 'num';
    }
    if (firstNonNull is List) {
      return 'List<dynamic>';
    }

    return 'dynamic';
  }

  void _writeClass(StringBuffer buffer, _ModelClass modelClass) {
    buffer
      ..writeln('/// ${modelClass.name} model')
      ..writeln('@freezed')
      ..writeln(
        'abstract class ${modelClass.name} with _\$${modelClass.name} {',
      )
      ..writeln('  const factory ${modelClass.name}({');

    for (final field in modelClass.fields) {
      buffer.writeln(
        "    @JsonKey(name: '${_escapeSingleQuote(field.jsonKey)}') "
        '${field.type}? ${field.name},',
      );
    }

    buffer
      ..writeln('  }) = _${modelClass.name};')
      ..writeln()
      ..writeln(
        '  factory ${modelClass.name}.fromJson(Map<String, dynamic> json) =>',
      )
      ..writeln('      _\$${modelClass.name}FromJson(json);')
      ..writeln('}');
  }

  String _uniqueClassName(String preferredName) {
    var className = preferredName;
    var suffix = 2;
    while (_usedClassNames.contains(className)) {
      className = '$preferredName$suffix';
      suffix += 1;
    }
    _usedClassNames.add(className);
    return className;
  }
}

/// class 结构描述。
class _ModelClass {
  const _ModelClass({required this.name, required this.fields});

  final String name;
  final List<_ModelField> fields;
}

/// 字段结构描述。
class _ModelField {
  const _ModelField({
    required this.jsonKey,
    required this.name,
    required this.type,
  });

  final String jsonKey;
  final String name;
  final String type;
}

void _printUsage() {
  stdout.writeln('''
Generate a freezed model source file from a JSON file.

Usage:
  fvm dart run tool/generate_freezed_model.dart \\
    --input path/to/sample.json \\
    --output lib/entities/repay/repay_resp.dart \\
    --class RepayResp

Then run:
  fvm dart run build_runner build
''');
}

String _fileName(String path) {
  return path.replaceAll(r'\', '/').split('/').last;
}

String _nestedName(String jsonKey) {
  final pascalName = _toPascalCase(jsonKey);
  if (pascalName == 'List' || pascalName == 'Items') {
    return 'Item';
  }

  return pascalName;
}

String _toPascalCase(String value) {
  final words = _splitWords(value);
  final result = words.map(_capitalize).join();
  if (result.isEmpty) {
    return 'GeneratedModel';
  }
  if (RegExp(r'^[0-9]').hasMatch(result)) {
    return 'Model$result';
  }

  return result;
}

String _safeFieldName(String jsonKey) {
  final words = _splitWords(jsonKey);
  var name = words.isEmpty
      ? 'field'
      : words.first.toLowerCase() + words.skip(1).map(_capitalize).join();
  if (RegExp(r'^[0-9]').hasMatch(name)) {
    name = 'field$name';
  }
  if (_dartKeywords.contains(name)) {
    name = '${name}Value';
  }

  return name;
}

List<String> _splitWords(String value) {
  final spaced = value
      .replaceAllMapped(
        RegExp('([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ');

  return spaced
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }

  return value[0].toUpperCase() + value.substring(1);
}

String _escapeSingleQuote(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}

const _dartKeywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'with',
  'while',
  'yield',
};
