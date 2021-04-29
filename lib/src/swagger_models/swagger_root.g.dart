// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_root.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerRoot _$SwaggerRootFromJson(Map<String, dynamic> json) {
  return SwaggerRoot(
    basePath: json['basePath'] as String? ?? '',
    components: json['components'] == null
        ? null
        : SwaggerComponents.fromJson(
            json['components'] as Map<String, dynamic>),
    info: json['info'] == null
        ? null
        : SwaggerInfo.fromJson(json['info'] as Map<String, dynamic>),
    host: json['host'] as String? ?? '',
    paths: _mapPaths(json['paths'] as Map<String, dynamic>) ?? {},
    tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => SwaggerTag.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    schemes:
        (json['schemes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
            [],
    parameters: (json['parameters'] as List<dynamic>?)
            ?.map((e) =>
                SwaggerRequestParameter.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$SwaggerRootToJson(SwaggerRoot instance) =>
    <String, dynamic>{
      'info': instance.info,
      'host': instance.host,
      'basePath': instance.basePath,
      'tags': instance.tags,
      'schemes': instance.schemes,
      'paths': instance.paths,
      'parameters': instance.parameters,
      'components': instance.components,
    };
