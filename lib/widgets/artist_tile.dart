import 'package:combined_playlist_maker/models/artist.dart';
import 'package:combined_playlist_maker/utils/work_in_progress.dart';
import 'package:flutter/material.dart';

class ArtistTile extends StatelessWidget {
  final Artist artist;

  const ArtistTile({super.key, required this.artist});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FadeInImage.assetNetwork(
          placeholder: 'assets/images/unknown_cover.png',
          image: artist.imageUrl,
          imageErrorBuilder: (context, error, stackTrace) {
            return const Image(
                image: AssetImage('assets/images/unknown_cover.png'));
          }),
      title: Text(artist.name),
      subtitle: Text(artist.genres.map((genre) => genre.toString()).join(', ')),
      trailing: const Icon(Icons.portrait_rounded),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkInProgressScreen(),
            ));
      },
    );
  }
}
