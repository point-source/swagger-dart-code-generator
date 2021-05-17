import 'dart:convert';

import 'package:swagger_dart_code_generator/src/code_generators/constants.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_requests_generator.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:recase/recase.dart';
import 'package:swagger_dart_code_generator/src/extensions/string_extension.dart';
import 'package:swagger_dart_code_generator/src/exception_words.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_schema.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_path.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';
import 'package:code_builder/code_builder.dart';

class SwaggerModelsGenerator {
  String generate(String dartCode, String fileName, GeneratorOptions options) {
    final map = jsonDecode(dartCode) as Map<String, dynamic>;
    final root = SwaggerRoot.fromJson(map);

    final classes = _generateClasses(
      root: root,
      fileName: fileName,
      options: options,
    );

    final lib = Library((l) => l..body.addAll(classes));

    final tt = lib.accept(DartEmitter()).toString();

    return tt;
  }

  bool _shouldGenerateModel(SwaggerSchema schema) {
    if (schema.enumValues.isNotEmpty ||
        kBasicTypes.contains(schema.type.toLowerCase()) ||
        schema.items?.type == kEnum ||
        schema.ref.isNotEmpty) {
      return true;
    }

    return false;
  }

  Map<String, SwaggerSchema> _getClassesFromResponses({
    required Map<String, SwaggerPath> paths,
  }) {
    final results = <String, SwaggerSchema>{};

    if (paths.isEmpty) {
      return results;
    }

    paths.forEach((path, pathValue) {
      pathValue.requests.forEach((requestType, requestValue) {
        if (requestType == kRequestTypeOptions) {
          return;
        }

        final neededResponse = SwaggerRequestsGenerator.getSuccessedResponse(
            responses: requestValue.responses);

        if (neededResponse?.schema?.type == kObject &&
            neededResponse?.schema?.properties.isNotEmpty == true) {
          final modelKey =
              getResponseModelTypeName(path: path, requestType: requestType);
          results[modelKey] = neededResponse!.schema!;
        }
      });
    });

    return results;
  }

  static String getResponseModelTypeName({
    required String path,
    required String requestType,
  }) {
    final pathText = path.split('/').map((e) => e.pascalCase).join();
    final requestText = requestType.pascalCase;

    return '$pathText$requestText\$$kResponse';
  }

  List<Class> _generateClasses({
    required SwaggerRoot root,
    required String fileName,
    required GeneratorOptions options,
  }) {
    final classes = root.definitions
      ..addAll(root.components?.schemas ?? {})
      ..addAll(_getClassesFromResponses(paths: root.paths));

    var generatedClasses = <Class?>[];

    classes.forEach((classKey, classEntry) {
      if (classEntry.enumValues.isNotEmpty) {
        return;
      }

      generatedClasses.add(_generateModelClassString(
        schema: classEntry,
        className: classKey,
        schemas: classes,
        options: options,
      ));
    });

    return generatedClasses
        .where((element) => element != null)
        .cast<Class>()
        .toList();
  }

  static String getValidatedClassName(String className) {
    if (className.isEmpty) {
      return className;
    }

    final isEnum = className.startsWith('enums.');

    if (isEnum) {
      className = className.substring(6);
    }

    final result = className.pascalCase
        .split('-')
        .map((String str) => str.capitalize)
        .join();

    if (kKeyClasses.contains(result)) {
      return '$result\$';
    }

    if (isEnum) {
      return 'enums.$result';
    }

    return result;
  }

  String _getParameterTypeName({required String parameterType}) {
    switch (parameterType) {
      case 'integer':
      case 'int':
        return 'int';
      case 'boolean':
        return 'bool';
      case 'string':
        return 'String';
      case 'number':
        return 'double';
      case 'object':
        return 'Object';
      default:
        return 'undefinedType';
    }
  }

  static String generateFieldName(String jsonKey) {
    final forbiddenCharacters = <String>['#'];
    jsonKey = jsonKey.camelCase;

    forbiddenCharacters.forEach((String element) {
      if (jsonKey.startsWith(element)) {
        jsonKey = '\$forbiddenFieldName';
      }
    });

    if (jsonKey.startsWith(RegExp('[0-9]')) ||
        exceptionWords.contains(jsonKey)) {
      jsonKey = '\$' + jsonKey;
    }
    return jsonKey;
  }

  static String generateRequestEnumName(
      String path, String requestType, String parameterName) {
    if (path == '/') {
      path = '\$';
    }

    path = path.split('{').map((e) => e.capitalize).join();
    path = path.split('}').map((e) => e.capitalize).join();

    final correctedPath = generateFieldName(path);

    final result =
        '${correctedPath.capitalize}\$${requestType.capitalize}\$${parameterName.capitalize}';

    return SwaggerModelsGenerator.getValidatedClassName(result);
  }

  static String generateRequestName(String path, String requestType) {
    if (path == '/') {
      path = '\$';
    }

    path = path.split('{').map((e) => e.capitalize).join();
    path = path.split('}').map((e) => e.capitalize).join();
    path = path.split(',').map((e) => e.capitalize).join();

    final correctedPath = generateFieldName(path);

    return '${correctedPath.capitalize}${requestType.capitalize}'.camelCase;
  }

  Field _generateField({
    required String fieldName,
    required String fieldKey,
    required SwaggerSchema field,
    required GeneratorOptions options,
  }) {
    var typeName = _getFieldTypeName(field);
    final includeIfNull = options.includeIfNull?.value ?? true;

    return Field(
      (f) => f
        ..type = Reference(typeName)
        ..name = generateFieldName(fieldName)
        ..annotations.add(refer(kJsonKey).call([], {
          kName: literalString(fieldKey),
          kDefaultValue: literalString(field.defaultValue.toString()),
          kIncludeIfNull: literalString(includeIfNull.toString())
        })),
    );
  }

  List<Field> _generateModelFields({
    required Map<String, SwaggerSchema> fields,
    required Map<String, SwaggerSchema> schemas,
    required String className,
    required GeneratorOptions options,
  }) {
    if (fields.isEmpty) {
      return [];
    }

    final results = <Field>[];

    fields.forEach((key, field) {
      var fieldName = key;
      final fieldKey = key;

      exceptionWords.forEach((String exceptionWord) {
        if (fieldName == exceptionWord) {
          fieldName = '\$' + fieldName;
        }
      });

      results.add(_generateField(
        field: field,
        fieldName: fieldName,
        fieldKey: fieldKey,
        options: options,
      ));
    });

    return results;
  }

  

  List<Parameter> _generateConstructorParameters({
    required String className,
    required Map<String, SwaggerSchema> properties,
    required GeneratorOptions options,
  }) {
    if (properties.isEmpty) {
      return [];
    }

    return properties.keys
        .map(
          (propertyKey) => Parameter(
            (p) => p
              ..required = true
              ..name = generateFieldName(propertyKey)
              ..named = true,
          ),
        )
        .toList();
  }

  Class? _generateModelClassString({
    required String className,
    required SwaggerSchema schema,
    required Map<String, SwaggerSchema> schemas,
    required GeneratorOptions options,
  }) {
    if (_shouldGenerateModel(schema)) {
      return null;
    }

    final validatedClassName = getValidatedClassName(className);

    return Class(
      (c) => c
        ..constructors.add(
          Constructor(
            (co) => co
              ..optionalParameters.addAll(
                _generateConstructorParameters(
                    className: validatedClassName,
                    properties: schema.properties,
                    options: options),
              ),
          ),
        )
        ..fields.addAll(
          _generateModelFields(
            className: validatedClassName,
            fields: schema.properties,
            schemas: schemas,
            options: options,
          ),
        )
        ..name = getValidatedClassName(validatedClassName),
    );
  }

  String _getFieldTypeName(SwaggerSchema field) {
    if (field.items != null) {
      final originalRef = field.items!.originalRef;
      if (originalRef.isNotEmpty) {
        return _getParameterTypeName(parameterType: originalRef);
      }

      final ref = field.items!.ref.getRef();
      if (ref.isNotEmpty) {
        return _getParameterTypeName(parameterType: ref);
      }
    }

    return _getParameterTypeName(parameterType: field.type);
  }
}
