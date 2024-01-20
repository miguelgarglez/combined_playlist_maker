import 'package:combined_playlist_maker/main.dart';
import 'package:combined_playlist_maker/services/requests.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    //aquí realmente tendré que acabar haciendo una funcion que compruebe si el
    //token que haya está en vigor con la API de spotify
    //mostrar botón de login, no mostrar botón comenzar
    var notLoggedIn = <Widget>[
      const Icon(
        Icons
            .music_note_outlined, // Puedes cambiar el icono según tus preferencias
        size: 120.0, // Tamaño del icono
        // Color del icono
      ),
      const SizedBox(height: 20.0),
      const Padding(
        padding: EdgeInsets.all(15.0),
        child: ElevatedButton(
            onPressed: requestAuthorization, child: Text('Login with Spotify')),
      ),
      const Padding(
        padding: EdgeInsets.all(15.0),
        child: Text('And start using the app!'),
      ),
    ];

    var loggedIn = <Widget>[
      // Icono grande
      const Icon(
        Icons.music_note, // Puedes cambiar el icono según tus preferencias
        size: 120.0, // Tamaño del icono
        // Color del icono
      ),
      const SizedBox(height: 20.0), // Espacio entre el icono y el texto
      const Text(
        'Welcome!',
        style: TextStyle(
          fontSize: 24.0, // Tamaño del texto
          fontWeight: FontWeight.bold, // Estilo del texto
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(15.0),
        child: Text('You logged in from Spotify'),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ElevatedButton(
                  onPressed: () {
                    context.go('/users/');
                  },
                  child: const Text('See user\'s list')),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: ElevatedButton(
                  onPressed: () {
                    deleteContentFromHive();
                    context.go('/');
                  },
                  child: const Text('Delete data')),
            ),
          ],
        ),
      ),

      // Puedes agregar más contenido aquí, como botones, texto adicional, etc.
    ];

    if (isAuthenticated()) {
      children = loggedIn;
    } else {
      children = notLoggedIn;
    }
    // comprobar si el codigo se ha devuelto al autorizar el acceso de spotify
    if (authSuccess(Uri.base) == true) {
      if (hiveGetUsers().isEmpty) {
        var authBox = Hive.box('auth');
        authBox.put('isAuth', true);
      }

      retrieveSpotifyProfileInfo().then((user) {
        if (user.content.isNotValid()) {
          // TODO: Fix bug that makes the build method be called twice
          // TODO: and make the error be thrown always
          // This is why we are not doing anything in case there is an error
        } else {
          context.go('/users/');
        }
      });
    }
    // ! Debugging
    if (kDebugMode) {
      print('Se ejecuta build()');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combined Playlist Maker'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      )),
    );
  }
}

bool authSuccess(Uri url) {
  // Comprueba si la URL contiene el parámetro "error" y "state"
  if (url.queryParameters.containsKey("error") &&
      url.queryParameters.containsKey("state")) {
    // En caso de error, verifica si el valor del parámetro "error" es "access_denied"
    if (url.queryParameters["error"] == "access_denied") {
      return false; // Respuesta de error
    }
  } else {
    // Comprueba si la URL contiene los parámetros esperados en caso de éxito
    if (url.queryParameters.containsKey("code") &&
        url.queryParameters.containsKey("state")) {
      return true; // Respuesta exitosa
    }
  }
  return false; // Por defecto, considera que es una respuesta de error
}
