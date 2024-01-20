import 'package:combined_playlist_maker/models/track.dart';
import 'package:combined_playlist_maker/screens/track_detail.dart';
import 'package:flutter/material.dart';

class TrackTile extends StatelessWidget {
  final Track track;

  const TrackTile({super.key, required this.track});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FadeInImage.assetNetwork(
        placeholder: 'assets/images/unknown_cover.png',
        image: track.imageUrl,
        imageErrorBuilder: (context, error, stackTrace) {
          return const Image(
              image: AssetImage('assets/images/unknown_cover.png'));
        },
      ),
      title: Text(track.name),
      subtitle: Text(
          track.artists.map((artist) => artist['name'].toString()).join(', ')),
      trailing: Icon(Icons.music_note_sharp),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackDetail(track: track),
            ));
      },
    );
  }
}
