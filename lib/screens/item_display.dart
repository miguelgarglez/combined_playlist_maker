import 'package:combined_playlist_maker/models/track.dart';
import 'package:combined_playlist_maker/widgets/artist_tile.dart';
import 'package:combined_playlist_maker/widgets/track_tile.dart';
import 'package:flutter/material.dart';

class ItemDisplay extends StatelessWidget {
  final List items;
  final String title;

  ItemDisplay({super.key, required this.items, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        // Agrega el contenido de tu widget aquí
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            var child;
            if (items[index].runtimeType == Track) {
              child = TrackTile(track: items[index]);
            } else {
              child = ArtistTile(artist: items[index]);
            }
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: child,
            );
          },
          itemCount: items.length,
        ),
      ),
    );
  }
}
