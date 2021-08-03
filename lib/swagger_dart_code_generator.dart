import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:swagger_dart_code_generator/src/extensions/file_name_extensions.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_code_generator.dart';
import 'package:dart_style/dart_style.dart';

///Returns instance of SwaggerDartCodeGenerator
SwaggerDartCodeGenerator swaggerCodeBuilder(BuilderOptions options) =>
    SwaggerDartCodeGenerator(options);

const String _inputFileExtension = '.swagger';
const String _outputFileExtension = '.swagger.dart';
const String _outputEnumsFileExtension = '.enums.swagger.dart';
const String _outputResponsesFileExtension = '.responses.swagger.dart';
const String _indexFileName = 'client_index.dart';
const String _mappingFileName = 'client_mapping.dart';

Map<String, List<String>> _generateExtensions(GeneratorOptions options) => {
      '.swagger': [
        '${options.outputFolder}$_indexFileName',
        '${options.outputFolder}$_mappingFileName'
      ],
      '${options.inputFolder}{{}}$_inputFileExtension': [
        '${options.outputFolder}{{}}.dart',
        '${options.outputFolder}{{}}$_outputFileExtension',
        '${options.outputFolder}{{}}$_outputEnumsFileExtension',
        '${options.outputFolder}{{}}$_outputResponsesFileExtension',
      ]
    };

///Root library entry
class SwaggerDartCodeGenerator implements Builder {
  SwaggerDartCodeGenerator(BuilderOptions builderOptions) {
    options = GeneratorOptions.fromJson(builderOptions.config);
  }

  @override
  Map<String, List<String>> get buildExtensions =>
      _buildExtensionsCopy ??= _generateExtensions(options);

  Map<String, List<String>>? _buildExtensionsCopy;

  late GeneratorOptions options;

  final DartFormatter _formatter = DartFormatter();

  List<String>? _files;

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.startsWith(options.inputFolder)) return;
    final fileNameWithExtension =
        buildStep.inputId.pathSegments.last.replaceAll('-', '_');
    if (fileNameWithExtension == '.placeholder') {
      return;
    }

    final fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    final contents = await buildStep.readAsString(buildStep.inputId);

    final codeGenerator = SwaggerCodeGenerator();

    final models = codeGenerator.generateModels(
        contents, getFileNameWithoutExtension(fileNameWithExtension), options);

    final responses = codeGenerator.generateResponses(
        contents, getFileNameWithoutExtension(fileNameWithExtension), options);

    final requestBodies = codeGenerator.generateRequestBodies(
        contents, getFileNameWithoutExtension(fileNameWithExtension), options);

    final enums = codeGenerator.generateEnums(
        contents, getFileNameWithoutExtension(fileNameWithExtension));

    final imports = codeGenerator.generateImportsContent(
        fileNameWithoutExtension,
        models.isNotEmpty,
        options.buildOnlyModels,
        enums.isNotEmpty);

    final converter = codeGenerator.generateConverter(
        contents, getFileNameWithoutExtension(fileNameWithExtension), options);

    final requests = codeGenerator.generateRequests(
        contents,
        getClassNameFromFileName(fileNameWithExtension),
        getFileNameWithoutExtension(fileNameWithExtension),
        options);

    final customDecoder = codeGenerator.generateCustomJsonConverter(
        getFileNameWithoutExtension(fileNameWithExtension), models.isNotEmpty);

    final dateToJson = codeGenerator.generateDateToJson();

    final copyAssetId = AssetId(buildStep.inputId.package,
        '${options.outputFolder}$fileNameWithoutExtension$_outputFileExtension');

    await buildStep.writeAsString(
        copyAssetId,
        _generateFileContent(imports, requests, converter, models, responses,
            requestBodies, customDecoder, dateToJson));

    if (enums.isNotEmpty) {
      ///Write enums
      final formatterEnums = _tryFormatCode(enums);

      final enumsAssetId = AssetId(buildStep.inputId.package,
          '${options.outputFolder}$fileNameWithoutExtension$_outputEnumsFileExtension');

      await buildStep.writeAsString(enumsAssetId, formatterEnums);
    }

    ///Write additional files on first input
    _files ??= await buildStep
        .findAssets(Glob('${options.inputFolder}*.swagger'))
        .map((AssetId asset) => asset.pathSegments.last)
        .toList();
    if (_files?.isNotEmpty ?? false) {
      await _generateAdditionalFiles(
          _files!, buildStep.inputId.package, buildStep, true);
    }
  }

  String _generateFileContent(
      String imports,
      String requests,
      String converter,
      String models,
      String responses,
      String requestBodies,
      String customDecoder,
      String dateToJson) {
    final result = """
$imports

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

${options.buildOnlyModels ? '' : requests}

${options.withConverter ? converter : ''}

$models

$responses

$requestBodies

${options.withBaseUrl && options.withConverter ? customDecoder : ''}

$dateToJson
""";

    return _tryFormatCode(result);
  }

  String _tryFormatCode(String code) {
    try {
      final formattedResult = _formatter.format(code);
      return formattedResult;
    } catch (e) {
      print('''[WARNING] Code formatting failed.
          Please raise an issue on https://github.com/epam-cross-platform-lab/swagger-dart-code-generator/issues/
          Reason: $e''');
      return code;
    }
  }

  Future<void> _generateAdditionalFiles(List<String> files, String package,
      BuildStep buildStep, bool hasModels) async {
    final codeGenerator = SwaggerCodeGenerator();

    final indexAssetId =
        AssetId(package, '${options.outputFolder}$_indexFileName');

    final imports = codeGenerator.generateIndexes(files);

    await buildStep.writeAsString(indexAssetId, _formatter.format(imports));

    if (options.withConverter) {
      final mappingAssetId =
          AssetId(package, '${options.outputFolder}$_mappingFileName');

      final mapping = codeGenerator.generateConverterMappings(files, hasModels);

      await buildStep.writeAsString(mappingAssetId, _formatter.format(mapping));
    }
  }
}
