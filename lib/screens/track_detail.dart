import 'package:combined_playlist_maker/models/track.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackDetail extends StatelessWidget {
  final Track track;

  const TrackDetail({Key? key, required this.track}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Decide el diseño en función del ancho de la pantalla
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(track.name),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isHorizontal
                ? _buildWideScreenLayout(track, context)
                : _buildNarrowScreenLayout(track, context),
          ),
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout(Track track, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Columna izquierda con la imagen
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                blurStyle: BlurStyle.normal,
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: (track.imageUrl == '')
                ? FadeInImage.assetNetwork(
                    placeholder: 'assets/images/unknown_cover.png',
                    image: track.imageUrl,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return const Image(
                          image: AssetImage('assets/images/unknown_cover.png'));
                    },
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    track.imageUrl,
                    width: 250,
                    height: 250,
                  ),
          ),
        ),
        const SizedBox(width: 40),
        // Columna derecha con detalles y botones
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildTrackDetails(track, context),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(Track track, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Columna superior con la imagen
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                blurStyle: BlurStyle.normal,
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: (track.imageUrl == '')
                ? FadeInImage.assetNetwork(
                    placeholder: 'asssets/images/unknown_cover.png',
                    image: track.imageUrl,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return const Image(
                          image: AssetImage('assets/images/unknown_cover.png'));
                    },
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    track.imageUrl,
                    width: 250,
                    height: 250,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Columna inferior con detalles y botones
        ..._buildTrackDetails(track, context),
      ],
    );
  }

  List<Widget> _buildTrackDetails(Track track, BuildContext context) {
    return [
      Text(
        '${track.name}',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      Text(
        '${track.artists.map((a) => a['name']).join(', ')}',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      Text(
        '${Duration(milliseconds: track.durationMs).inMinutes}:${Duration(milliseconds: track.durationMs).inSeconds.remainder(60).toString().padLeft(2, '0')} min',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 16),
      const Text(
        'Want to listen to this track?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          Uri u = Uri.https('open.spotify.com', '/track/${track.id}');
          canLaunchUrl(u).then((value) {
            launchUrl(u);
          }).onError((error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open track on Spotify'),
              ),
            );
          });
        },
        child: const Text('Play on Spotify'),
      ),
    ];
  }
}
