import 'dart:convert';
import 'dart:typed_data';
import 'package:combined_playlist_maker/screens/playlist_detail.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:combined_playlist_maker/models/user.dart';
import 'package:combined_playlist_maker/src/return_codes.dart';
import 'package:combined_playlist_maker/services/error_handling.dart';
import 'package:combined_playlist_maker/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavePlaylist extends StatefulWidget {
  final List items;
  final bool automaticSaving;
  final String? strategy;

  const SavePlaylist({super.key, required this.items})
      : automaticSaving = false,
        strategy = '';

  SavePlaylist.defaultSaving({super.key, required this.items, this.strategy})
      : automaticSaving = true;

  @override
  _SavePlaylistState createState() => _SavePlaylistState();
}

class _SavePlaylistState extends State<SavePlaylist> {
  String selectedUser = 'dummy';
  String playlistTitle = 'Título por defecto';
  String playlistDescription = 'Descripción por defecto';
  bool playlistVisibility = false;
  bool playlistCollaborative = false;
  List<User> users = [];

  bool _loading = false;

  // * Para seleccionar una imagen de la galería
  Uint8List? playlistCover;
  String base64Cover = '';

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> initializeData() async {
    try {
      var usersBox = Hive.box<User>('users');
      users = usersBox.values.toList();
      users.insert(0, User.dummy());
    } catch (error) {
      throw Exception('Error initializing users on SavePlaylist');
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> _pickImage() async {
    final pickedImageBytes = await ImagePickerWeb.getImageAsBytes();

    if (pickedImageBytes != null) {
      if (pickedImageBytes.length > 255 * 1024) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sorry, the image is too big'),
            ),
          );
        });
        return;
      }
      setState(() {
        playlistCover = pickedImageBytes;
        base64Cover = base64Encode(pickedImageBytes);
      });
    }
  }

  bool validatePlaylistData() {
    if (selectedUser == 'dummy' || selectedUser == '') {
      return false;
    }
    if (playlistTitle.isEmpty) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.automaticSaving) {
      _assignDefaultTestTitleAndDescription();
      return _buildAskForUser();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Save Playlist'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                DropdownButton<String>(
                  value: selectedUser,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUser = newValue!;
                    });
                  },
                  items: users.map<DropdownMenuItem<String>>((user) {
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Row(
                        children: [
                          FadeInImage.assetNetwork(
                              placeholder: 'assets/images/unknown_cover.png',
                              image: user.imageUrl,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return const Image(
                                    image: AssetImage(
                                        'assets/images/unknown_cover.png'));
                              }),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(user.displayName)),
                        ],
                      ),
                    );
                  }).toList(),
                  hint: const Text('Select a user to save the playlist'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Playlist\'s title',
                  ),
                  initialValue: playlistTitle,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        playlistTitle = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Playlist\'s description',
                  ),
                  initialValue: playlistDescription,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        playlistDescription = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Will the playlist be collaborative?',
                      style: Theme.of(context).textTheme.labelLarge,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: playlistCollaborative,
                      onChanged: (bool? value) {
                        setState(() {
                          playlistCollaborative = value!;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 16.0),
                    Radio<bool>(
                      value: false,
                      groupValue: playlistCollaborative,
                      onChanged: (bool? value) {
                        setState(() {
                          playlistCollaborative = value!;
                        });
                      },
                    ),
                    const Text('No'),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: playlistCollaborative
                      ? [const Text('Your playlist will be collaborative')]
                      : [
                          Radio<bool>(
                            value: true,
                            groupValue: playlistVisibility,
                            onChanged: (bool? value) {
                              setState(() {
                                playlistVisibility = value!;
                              });
                            },
                          ),
                          const Text('Public'),
                          const SizedBox(width: 16.0),
                          Radio<bool>(
                            value: false,
                            groupValue: playlistVisibility,
                            onChanged: (bool? value) {
                              setState(() {
                                playlistVisibility = value!;
                              });
                            },
                          ),
                          const Text('Private'),
                        ],
                ),
                const SizedBox(height: 16.0),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Upload a cover for your playlist:',
                      style: Theme.of(context).textTheme.labelLarge,
                    )),
                IconButton(
                  onPressed: _pickImage,
                  icon: playlistCover != null
                      ? Image.memory(
                          playlistCover!,
                          width: 60,
                          height: 60,
                        )
                      : const Icon(Icons.image, size: 60),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para guardar la playlist

                    if (validatePlaylistData()) {
                      setState(() {
                        _loading = true;
                      });
                      savePlaylistToSpotify(
                              widget.items,
                              selectedUser,
                              playlistTitle,
                              playlistDescription,
                              playlistVisibility,
                              playlistCollaborative,
                              base64Cover)
                          .then((playlistResponse) {
                        setState(() {
                          _loading = false;
                        });
                        if (handleResponseUI(
                                playlistResponse, selectedUser, context) ==
                            ReturnCodes.SUCCESS) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetail(
                                  userId: selectedUser,
                                  playlistId: playlistResponse.content['id'],
                                ),
                              ));
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all the fields'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save playlist'),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAskForUser() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Playlist'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                DropdownButton<String>(
                  value: selectedUser,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUser = newValue!;
                    });
                  },
                  items: users.map<DropdownMenuItem<String>>((user) {
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Row(
                        children: [
                          FadeInImage.assetNetwork(
                              placeholder: 'assets/images/unknown_cover.png',
                              image: user.imageUrl,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return const Image(
                                    image: AssetImage(
                                        'assets/images/unknown_cover.png'));
                              }),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(user.displayName)),
                        ],
                      ),
                    );
                  }).toList(),
                  hint: const Text('Select a user to save the playlist'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para guardar la playlist

                    if (validatePlaylistData()) {
                      setState(() {
                        _loading = true;
                      });
                      savePlaylistToSpotify(
                              widget.items,
                              selectedUser,
                              playlistTitle,
                              playlistDescription,
                              playlistVisibility,
                              playlistCollaborative,
                              base64Cover)
                          .then((playlistResponse) {
                        setState(() {
                          _loading = false;
                        });
                        if (handleResponseUI(
                                playlistResponse, selectedUser, context) ==
                            ReturnCodes.SUCCESS) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetail(
                                  userId: selectedUser,
                                  playlistId: playlistResponse.content['id'],
                                ),
                              ));
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select an user'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save playlist'),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _assignDefaultTestTitleAndDescription() {
    playlistTitle = widget.strategy!;
    playlistDescription =
        'Playlist generated for users: ${users.skip(1).map((user) => user.displayName).join(', ')}';
    playlistVisibility = true;
  }
}
