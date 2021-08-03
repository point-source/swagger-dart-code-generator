import 'dart:convert';

import 'package:swagger_dart_code_generator/src/code_generators/swagger_additions_generator.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_converter_generator.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_enums_generator.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_models_generator.dart';
import 'package:swagger_dart_code_generator/src/code_generators/swagger_requests_generator.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v2/swagger_enums_generator_v2.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v2/swagger_models_generator_v2.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v2/swagger_requests_generator_v2.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v3/swagger_enums_generator_v3.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v3/swagger_models_generator_v3.dart';
import 'package:swagger_dart_code_generator/src/code_generators/v3/swagger_requests_generator_v3.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';

class SwaggerCodeGenerator {
  final Map<int, SwaggerEnumsGenerator> _enumsMap =
      <int, SwaggerEnumsGenerator>{
    2: SwaggerEnumsGeneratorV2(),
    3: SwaggerEnumsGeneratorV3()
  };

  final Map<int, SwaggerModelsGenerator> _modelsMap =
      <int, SwaggerModelsGenerator>{
    2: SwaggerModelsGeneratorV2(),
    3: SwaggerModelsGeneratorV3()
  };

  final Map<int, SwaggerRequestsGenerator> _requestsMap =
      <int, SwaggerRequestsGenerator>{
    2: SwaggerRequestsGeneratorV2(),
    3: SwaggerRequestsGeneratorV3()
  };

  int _getApiVersion(String dartCode) {
    final dynamic map = jsonDecode(dartCode);

    final openApi = map['openapi'] as String?;
    return openApi != null ? 3 : 2;
  }

  /// Accepts a list of file names (including extensions, but not paths)
  String generateIndexes(List<String> files) =>
      _getSwaggerAdditionsGenerator().generateIndexes(files);

  /// Accepts a list of file names (including extensions, but not paths)
  String generateConverterMappings(List<String> files, bool hasModels) =>
      _getSwaggerAdditionsGenerator()
          .generateConverterMappings(files, hasModels);

  String generateImportsContent(String swaggerFileName, bool hasModels,
          bool buildOnlyModels, bool hasEnums) =>
      _getSwaggerAdditionsGenerator().generateImportsContent(
          swaggerFileName, hasModels, buildOnlyModels, hasEnums);

  String generateConverter(
          String dartCode, String fileName, GeneratorOptions options) =>
      _getSwaggerConverterGenerator(dartCode)
          .generate(dartCode, fileName, options);

  String generateResponses(
          String dartCode, String fileName, GeneratorOptions options) =>
      _getSwaggerModelsGenerator(dartCode)
          .generateResponses(dartCode, fileName, options);

  String generateRequestBodies(
          String dartCode, String fileName, GeneratorOptions options) =>
      _getSwaggerModelsGenerator(dartCode)
          .generateRequestBodies(dartCode, fileName, options);

  String generateEnums(String dartCode, String fileName) =>
      _getSwaggerEnumsGenerator(dartCode).generate(dartCode, fileName);

  String generateModels(
          String dartCode, String fileName, GeneratorOptions options) =>
      _getSwaggerModelsGenerator(dartCode)
          .generate(dartCode, fileName, options);

  String generateRequests(String dartCode, String className, String fileName,
          GeneratorOptions options) =>
      _getSwaggerRequestsGenerator(dartCode)
          .generate(dartCode, className, fileName, options);

  String generateCustomJsonConverter(String fileName, bool hasModels) =>
      _getSwaggerAdditionsGenerator()
          .generateCustomJsonConverter(fileName, hasModels);

  String generateDateToJson() =>
      _getSwaggerAdditionsGenerator().generateDateToJson();

  SwaggerAdditionsGenerator _getSwaggerAdditionsGenerator() =>
      SwaggerAdditionsGenerator();

  SwaggerConverterGenerator _getSwaggerConverterGenerator(String dartCode) =>
      SwaggerConverterGenerator();

  SwaggerEnumsGenerator _getSwaggerEnumsGenerator(String dartCode) =>
      _enumsMap[_getApiVersion(dartCode)]!;

  SwaggerModelsGenerator _getSwaggerModelsGenerator(String dartCode) =>
      _modelsMap[_getApiVersion(dartCode)]!;

  SwaggerRequestsGenerator _getSwaggerRequestsGenerator(String dartCode) =>
      _requestsMap[_getApiVersion(dartCode)]!;
}
