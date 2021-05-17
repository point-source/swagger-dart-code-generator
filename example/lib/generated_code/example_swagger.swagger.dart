import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'example_swagger.enums.swagger.dart' as enums;
export 'example_swagger.enums.swagger.dart';

part 'example_swagger.swagger.chopper.dart';
part 'example_swagger.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class ExampleSwagger extends ChopperService {
  ExampleSwagger create([ChopperClient? client]) {
    if (client != null) {
      return _$ExampleSwagger(client);
    }

    final newClient = ChopperClient(
        services: [_$ExampleSwagger()],
        converter: JsonSerializableConverter(),
        baseUrl: 'https://petstore.swagger.io/v2');
    return _$ExampleSwagger(newClient);
  }

  ///Add a new pet to the store
  ///@param body Pet object that needs to be added to the store
  @Post(path: '/pet')
  Future<chopper.Response<PetPetPost$Response>> petPost(
      {@Body() required Pet? body});

  ///Update an existing pet
  ///@param body Pet object that needs to be added to the store
  @Put(path: '/pet')
  Future<chopper.Response> petPut({@Body() required Pet? body});

  ///Finds Pets by status
  ///@param status Status values that need to be considered for filter
  ///@param color Status values that need to be considered for filter
  @Get(path: '/pet/findByStatus')
  Future<chopper.Response<List<Pet>>> petFindByStatusGet(
      {@Query() required enums.PetFindByStatus$Get$Status? status,
      @Query() required enums.PetFindByStatus$Get$Color? color});

  ///Finds Pets by tags
  ///@param tags Tags to filter by
  @Get(path: '/pet/findByTags')
  Future<chopper.Response<List<Pet>>> petFindByTagsGet(
      {@Query() required List<String>? tags});

  ///Find pet by ID
  ///@param petId ID of pet to return
  @Get(path: '/pet/{petId}')
  Future<chopper.Response<Pet>> petPetIdGet(
      {@Path('petId') required int? petId});

  ///Updates a pet in the store with form data
  ///@param petId ID of pet that needs to be updated
  ///@param name Updated name of the pet
  ///@param status Updated status of the pet
  @Post(path: '/pet/{petId}')
  Future<chopper.Response> petPetIdPost(
      {@Path('petId') required int? petId,
      @Field() required String? name,
      @Field() required String? status});

  ///Deletes a pet
  ///@param api_key
  ///@param petId Pet id to delete
  @Delete(path: '/pet/{petId}')
  Future<chopper.Response> petPetIdDelete(
      {@Header() required String? api_key, @Path('petId') required int? petId});

  ///uploads an image
  ///@param petId ID of pet to update
  ///@param additionalMetadata Additional data to pass to server
  ///@param file file to upload
  @Post(path: '/pet/{petId}/uploadImage')
  Future<chopper.Response<ApiResponse>> petPetIdUploadImagePost(
      {@Path('petId') required int? petId,
      @Field() required String? additionalMetadata,
      @Field() required List<String>? file});

  ///Returns pet inventories by status
  @Get(path: '/store/inventory')
  Future<chopper.Response<List<dynamic>>> storeInventoryGet();

  ///Place an order for a pet
  ///@param body order placed for purchasing the pet
  @Post(path: '/store/order')
  Future<chopper.Response<OrderWithDash>> storeOrderPost(
      {@Body() required Order? body});

  ///Find purchase order by ID
  ///@param orderId ID of pet that needs to be fetched
  @Get(path: '/store/order/{orderId}')
  Future<chopper.Response<Order>> storeOrderOrderIdGet(
      {@Path('orderId') required int? orderId});

  ///Delete purchase order by ID
  ///@param orderId ID of the order that needs to be deleted
  @Delete(path: '/store/order/{orderId}')
  Future<chopper.Response> storeOrderOrderIdDelete(
      {@Path('orderId') required int? orderId});

  ///Create user
  ///@param body Created user object
  @Post(path: '/user')
  Future<chopper.Response> userPost({@Body() required User? body});

  ///Creates list of users with given input array
  ///@param body List of user object
  @Post(path: '/user/createWithArray')
  Future<chopper.Response> userCreateWithArrayPost(
      {@Body() required List<User>? body});

  ///Creates list of users with given input array
  ///@param body List of user object
  @Post(path: '/user/createWithList')
  Future<chopper.Response> userCreateWithListPost(
      {@Body() required List<User>? body});

  ///Logs user into the system
  ///@param username The user name for login
  ///@param password The password for login in clear text
  @Get(path: '/user/login')
  Future<chopper.Response<String>> userLoginGet(
      {@Query() required String? username, @Query() required String? password});

  ///Logs out current logged in user session
  @Get(path: '/user/logout')
  Future<chopper.Response> userLogoutGet();

  ///Get user by user name
  ///@param username The name that needs to be fetched. Use user1 for testing.
  @Get(path: '/user/{username}')
  Future<chopper.Response<User>> userUsernameGet(
      {@Path('username') required String? username});

  ///Updated user
  ///@param username name that need to be updated
  ///@param body Updated user object
  @Put(path: '/user/{username}')
  Future<chopper.Response> userUsernamePut(
      {@Path('username') required String? username,
      @Body() required User? body});

  ///Delete user
  ///@param username The name that needs to be deleted
  @Delete(path: '/user/{username}')
  Future<chopper.Response> userUsernameDelete(
      {@Path('username') required String? username});
}

class Order {
  Order(
      {required id,
      required petId,
      required quantity,
      required shipDateTime,
      required shipDate,
      required status,
      required complete});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'petId', defaultValue: 'null', includeIfNull: 'false')
  int petId;

  @JsonKey(name: 'quantity', defaultValue: 'null', includeIfNull: 'false')
  int quantity;

  @JsonKey(name: 'shipDateTime', defaultValue: 'null', includeIfNull: 'false')
  String shipDateTime;

  @JsonKey(name: 'shipDate', defaultValue: 'null', includeIfNull: 'false')
  String shipDate;

  @JsonKey(name: 'status', defaultValue: 'null', includeIfNull: 'false')
  String status;

  @JsonKey(name: 'complete', defaultValue: 'false', includeIfNull: 'false')
  bool complete;
}

class OrderWithDash {
  OrderWithDash(
      {required id,
      required petId,
      required quantity,
      required shipDate,
      required status,
      required complete});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'petId', defaultValue: 'null', includeIfNull: 'false')
  int petId;

  @JsonKey(name: 'quantity', defaultValue: 'null', includeIfNull: 'false')
  int quantity;

  @JsonKey(name: 'shipDate', defaultValue: 'null', includeIfNull: 'false')
  String shipDate;

  @JsonKey(name: 'status', defaultValue: 'null', includeIfNull: 'false')
  String status;

  @JsonKey(name: 'complete', defaultValue: 'false', includeIfNull: 'false')
  bool complete;
}

class Category {
  Category({required id, required name});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'name', defaultValue: 'null', includeIfNull: 'false')
  String name;
}

class User {
  User(
      {required id,
      required username,
      required firstName,
      required lastName,
      required email,
      required password,
      required phone,
      required userStatus});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'username', defaultValue: 'null', includeIfNull: 'false')
  String username;

  @JsonKey(name: 'firstName', defaultValue: 'null', includeIfNull: 'false')
  String firstName;

  @JsonKey(name: 'lastName', defaultValue: 'null', includeIfNull: 'false')
  String lastName;

  @JsonKey(name: 'email', defaultValue: 'null', includeIfNull: 'false')
  String email;

  @JsonKey(name: 'password', defaultValue: 'null', includeIfNull: 'false')
  String password;

  @JsonKey(name: 'phone', defaultValue: 'null', includeIfNull: 'false')
  String phone;

  @JsonKey(name: 'userStatus', defaultValue: 'null', includeIfNull: 'false')
  int userStatus;
}

class Tag {
  Tag({required id, required name});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'name', defaultValue: 'null', includeIfNull: 'false')
  String name;
}

class Pet {
  Pet(
      {required id,
      required category,
      required name,
      required photoUrls,
      required tags,
      required status});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'category', defaultValue: 'null', includeIfNull: 'false')
  undefinedType category;

  @JsonKey(name: 'name', defaultValue: 'null', includeIfNull: 'false')
  String name;

  @JsonKey(name: 'photoUrls', defaultValue: 'null', includeIfNull: 'false')
  undefinedType photoUrls;

  @JsonKey(name: 'tags', defaultValue: 'null', includeIfNull: 'false')
  undefinedType tags;

  @JsonKey(name: 'status', defaultValue: 'null', includeIfNull: 'false')
  String status;
}

class ApiResponse {
  ApiResponse({required code, required type, required message});

  @JsonKey(name: 'code', defaultValue: 'null', includeIfNull: 'false')
  int code;

  @JsonKey(name: 'type', defaultValue: 'null', includeIfNull: 'false')
  String type;

  @JsonKey(name: 'message', defaultValue: 'null', includeIfNull: 'false')
  String message;
}

class PetPost$Response {
  PetPost$Response({required id, required petId});

  @JsonKey(name: 'id', defaultValue: 'null', includeIfNull: 'false')
  int id;

  @JsonKey(name: 'petId', defaultValue: 'null', includeIfNull: 'false')
  int petId;
}

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class CustomJsonDecoder {
  CustomJsonDecoder(this.factories);

  final Map<Type, JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class JsonSerializableConverter extends chopper.JsonConverter {
  @override
  chopper.Response<ResultType> convertResponse<ResultType, Item>(
      chopper.Response response) {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    final jsonRes = super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final jsonDecoder = CustomJsonDecoder(ExampleSwaggerJsonDecoderMappings);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}
