import 'package:combined_playlist_maker/src/return_codes.dart';
import 'package:combined_playlist_maker/screens/playlist_display.dart';
import 'package:combined_playlist_maker/services/error_handling.dart';
import 'package:combined_playlist_maker/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';

class GeneratePlaylist extends StatefulWidget {
  @override
  _GeneratePlaylistState createState() => _GeneratePlaylistState();
}

class _GeneratePlaylistState extends State<GeneratePlaylist> {
  Duration _duration = const Duration(hours: 0, minutes: 0);
  String? _aggregationStrategy;

  bool _loading = false;

  bool validateDuration(Duration duration) {
    if (duration.inMinutes < 5) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Generate Playlist')),
        body: SingleChildScrollView(
            child: Center(
                child: Form(
                    child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Text('Choose the duration of the playlist',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: DurationPicker(
                  baseUnit: BaseUnit.minute,
                  duration: _duration,
                  onChange: (val) {
                    setState(() {
                      _duration = val;
                    });
                  },
                  snapToMins: 5.0,
                )),
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Choose an aggregation strategy',
                        style: Theme.of(context).textTheme.bodyLarge),
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Info'),
                              content: const Text(
                                  """The aggregation strategy determines how the songs will be combined to create the playlist.
Choose 'Compare strategies A and B' to see the playlist generated with each strategy and see which one you like the most."""),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(
                  left: 60, right: 60, top: 15, bottom: 15),
              child: DropdownButtonFormField(
                hint: const Text('Strategy'),
                value: _aggregationStrategy,
                items: {
                  //'average': 'Average',
                  //'most_pleasure': 'Most Pleasure',
                  'multiplicative': 'Strategy A',
                  'least_misery': 'Strategy B',
                  //'borda': 'Borda',
                  //'average_custom': 'Average without misery',
                  'all': 'Compare strategies A and B'
                }
                    .map((value, label) {
                      return MapEntry(
                          value,
                          DropdownMenuItem(
                              value: value, child: Center(child: Text(label))));
                    })
                    .values
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _aggregationStrategy = value.toString();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  if (validateDuration(_duration)) {
                    setState(() {
                      _loading = true;
                    });
                    generateCombinedPlaylist(_duration, _aggregationStrategy)
                        .then((playlistResponse) {
                      setState(() {
                        _loading = false;
                      });
                      if (handleResponseUI(playlistResponse, '', context) ==
                          ReturnCodes.SUCCESS) {
                        if (playlistResponse.content.length == 1) {
                          if (playlistResponse.auxContent.isEmpty) {
                            // if only one playlist has been generated with one aggregation strategy,
                            // the playlist is displayed directly
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDisplay(
                                      items: playlistResponse
                                          .content[_aggregationStrategy],
                                      title: 'Your combined playlist'),
                                ));
                          } else {
                            // if it was going to be a comparison, but one playlist
                            // has been removed due to total overlapping
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDisplay(
                                      items: playlistResponse.content.values
                                          .toList()[0],
                                      wasOverlapped: true,
                                      title: 'Your combined playlist'),
                                ));
                          }
                        } else {
                          // if multiple playlists have been generated, a tab bar will be displayed
                          // to show the different playlists generated with different aggregation strategies
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlaylistDisplay.multiplePlaylists(
                                        playlists: playlistResponse.content,
                                        title: 'See your playlists'),
                              ));
                        }
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('The duration must be at least 5 minutes.'),
                      ),
                    );
                  }
                },
                child: const Text('Generate playlist'),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        )))));
  }
}
