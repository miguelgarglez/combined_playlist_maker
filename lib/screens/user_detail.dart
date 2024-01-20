import 'package:combined_playlist_maker/models/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserDetail extends StatelessWidget {
  final String? id;

  const UserDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    var userBox = Hive.box<User>('users');
    User? user = userBox.get(id);

    // Decide el diseño en función del ancho de la pantalla
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(user!.displayName),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isHorizontal
                ? _buildWideScreenLayout(user, context)
                : _buildNarrowScreenLayout(user, context),
          ),
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout(User user, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Columna izquierda con la imagen
        Container(
          child: Hero(
            tag: user.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: (user.imageUrl == '')
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/images/unknown_cover.png',
                      image: user.imageUrl,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const Image(
                            image:
                                AssetImage('assets/images/unknown_cover.png'));
                      },
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      user.imageUrl,
                      width: 250,
                      height: 250,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        // Columna derecha con detalles y botones
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildUserDetails(user, context),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(User user, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Columna superior con la imagen
        Container(
          child: Hero(
            tag: user.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: (user.imageUrl == '')
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/images/unknown_cover.png',
                      image: user.imageUrl,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const Image(
                            image:
                                AssetImage('assets/images/unknown_cover.png'));
                      },
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      user.imageUrl,
                      width: 250,
                      height: 250,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Columna inferior con detalles y botones
        ..._buildUserDetails(user, context),
      ],
    );
  }

  List<Widget> _buildUserDetails(User user, BuildContext context) {
    return [
      Text(
        user.id,
        style: const TextStyle(fontSize: 18),
      ),
      Text(
        user.email,
        style: const TextStyle(fontSize: 18),
      ),
      Text(
        'Country: ${user.country}',
        style: const TextStyle(fontSize: 18),
      ),
      Text(
        'Followers: ${user.followers}',
        style: const TextStyle(fontSize: 18),
      ),
      const SizedBox(height: 16),
      const Text(
        'Want to know your most listened artists and tracks?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          context.go('/users/${user.id}/get-top-items');
        },
        child: const Text('Let\'s go!'),
      ),
      const SizedBox(height: 16),
      const Text(
        'Want new songs to listen to?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          context.go('/users/${user.id}/get-recommendations');
        },
        child: const Text('Get Recommendations'),
      ),
    ];
  }
}
