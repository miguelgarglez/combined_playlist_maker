import 'package:combined_playlist_maker/models/my_response.dart';
import 'package:combined_playlist_maker/services/requests.dart' as req;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class User {
  final displayName;
  final String id;
  final String email;
  final String imageUrl;
  final String country;
  final int followers;
  String accessToken;
  String refreshToken;

  User({
    required this.displayName,
    required this.id,
    required this.email,
    required this.imageUrl,
    required this.country,
    required this.followers,
    required this.accessToken,
    required this.refreshToken,
  });

  // Constructor alternativo para crear un User desde JSON
  // recibido de la request de los datos de usuario getProfileInfo
  factory User.fromJson(
      Map<String, dynamic> json, String token, String refreshToken) {
    String imageUrl = '';
    if ((json['images'] as List).isNotEmpty) {
      // La lista de imágenes no está vacía y puedes acceder a json['images'][0]
      imageUrl =
          json['images'][1]['url']; // Selecciona la segunda imagen de la lista
    } else {
      // La lista de imágenes está vacía o no existe la clave 'images' en el JSON
      imageUrl = '';
    }

    return User(
      displayName: json['display_name'],
      id: json['id'],
      email: json['email'],
      imageUrl: imageUrl,
      country: json['country'],
      followers: json['followers']['total'],
      accessToken: token,
      refreshToken: refreshToken,
    );
  }

  factory User.dummy() {
    return User(
        displayName: 'Select one of the available users',
        id: 'dummy',
        email: '',
        imageUrl: '',
        country: '',
        followers: 0,
        accessToken: '',
        refreshToken: '');
  }

  factory User.notValid() {
    return User(
        displayName: '',
        id: '',
        email: '',
        imageUrl: '',
        country: '',
        followers: 0,
        accessToken: '',
        refreshToken: '');
  }

  MyResponse updateToken() {
    req.refreshToken(id).then((tokenResponse) {
      if (tokenResponse.content.isNotEmpty) {
        var usersBox = Hive.box<User>('users');
        User? u = usersBox.get(id);
        u!.accessToken = tokenResponse.content['access_token'];
        u.refreshToken = tokenResponse.content['refresh_token'];
        usersBox.delete(u.id);
        usersBox.put(u.id, u).then((v) {
          if (kDebugMode) {
            print('User $id updated with refreshed token');
          }
          return tokenResponse;
        });
      } else {
        return tokenResponse;
      }
    });
    return MyResponse();
  }

  bool isNotValid() {
    return (displayName == '' &&
        id == '' &&
        email == '' &&
        country == '' &&
        accessToken == '' &&
        refreshToken == '');
  }

  @override
  String toString() {
    return 'User{display_name: $displayName, id: $id, email: $email, imageUrl: $imageUrl, country: $country, followers: $followers, accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0; // Identificador único para la clase User

  @override
  User read(BinaryReader reader) {
    // Lee los campos del usuario desde la caja
    final displayName = reader.readString();
    final id = reader.readString();
    final email = reader.readString();
    final imageUrl = reader.readString();
    final country = reader.readString();
    final followers = reader.readInt();
    final accessToken = reader.readString();
    final refreshToken = reader.readString();

    // Crea y devuelve un objeto User
    return User(
        displayName: displayName,
        id: id,
        email: email,
        imageUrl: imageUrl,
        country: country,
        followers: followers,
        accessToken: accessToken,
        refreshToken: refreshToken);
  }

  @override
  void write(BinaryWriter writer, User obj) {
    // Escribe los campos del usuario en la caja
    writer.writeString(obj.displayName);
    writer.writeString(obj.id);
    writer.writeString(obj.email);
    writer.writeString(obj.imageUrl);
    writer.writeString(obj.country);
    writer.writeInt(obj.followers);
    writer.writeString(obj.accessToken);
    writer.writeString(obj.refreshToken);
  }
}
