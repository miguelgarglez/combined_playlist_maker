import 'package:combined_playlist_maker/models/my_response.dart';
import 'package:combined_playlist_maker/src/return_codes.dart';
import 'package:combined_playlist_maker/services/error_handling.dart';
import 'package:combined_playlist_maker/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class GetRecommendations extends StatefulWidget {
  final String? userId;

  const GetRecommendations({super.key, this.userId});
  @override
  // ignore: library_private_types_in_public_api
  _GetRecommendationsState createState() => _GetRecommendationsState();
}

class _GetRecommendationsState extends State<GetRecommendations> {
  // Variables para los valores del formulario
  List<MultiSelectItem> _seedGenres = <MultiSelectItem>[];
  List<MultiSelectItem> _seedTracks = <MultiSelectItem>[];
  List<MultiSelectItem> _seedArtists = <MultiSelectItem>[];

  List errorStatus = [];

  double limit = 25;
  late List genresResult;
  late List tracksResult;
  late List artistsResult;

  final formKey = GlobalKey<FormState>();

  bool _loading = false;

  // Controladores para los campos de entrada
  final controller = TextEditingController();

  bool validateForm() {
    if (tracksResult.isEmpty && genresResult.isEmpty && artistsResult.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    genresResult = [];
    tracksResult = [];
    artistsResult = [];
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      MyResponse g = await getGenreSeeds(widget.userId!);
      errorStatus.add(g.statusCode);

      MyResponse t =
          await getUsersTopItems(widget.userId!, 'tracks', 'short_term', 15);
      errorStatus.add(t.statusCode);
      MyResponse a =
          await getUsersTopItems(widget.userId!, 'artists', 'short_term', 15);
      errorStatus.add(a.statusCode);
      _seedGenres = g.content
          .map<MultiSelectItem>((genre) => MultiSelectItem(genre, genre))
          .toList();
      _seedArtists = a.content
          .map<MultiSelectItem>(
              (artist) => MultiSelectItem(artist.id, artist.name))
          .toList();
      _seedTracks = t.content
          .map<MultiSelectItem>(
              (track) => MultiSelectItem(track.id, track.name))
          .toList();
    } catch (error) {
      // Manejar errores si es necesario
      throw Exception('Error initializing data on GetRecommendations');
    }
    // necesario para que termine de cargar las listas en los campos de opciones
    // del formulario
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Slider buildLimitField() {
    return Slider(
      value: limit,
      onChanged: (newValue) {
        setState(() {
          limit = newValue;
        });
      },
      min: 1.0, // Valor mínimo
      max: 50.0, // Valor máximo
      divisions: 49, // Número de divisiones (de 1 a 50)
      label: limit.round().toString(), // Etiqueta con el valor
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust recommendation parameters'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Text('Limit the length of the recommendation',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: buildLimitField()),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Text(
                    'Select up to 5 music genres',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MultiSelectDialogField(
                    items: _seedGenres,
                    initialValue: genresResult,
                    title: const Text('Select genres'),
                    selectedColor: Theme.of(context).highlightColor,
                    buttonIcon: const Icon(Icons.arrow_drop_down),
                    buttonText: const Text('Choose music genres'),
                    selectedItemsTextStyle:
                        Theme.of(context).textTheme.bodyLarge,
                    itemsTextStyle: Theme.of(context).textTheme.bodyLarge,
                    unselectedColor: Theme.of(context).highlightColor,
                    searchable: true,
                    separateSelectedItems: true,
                    listType: MultiSelectListType.LIST,
                    onConfirm: (results) {
                      genresResult = results;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Text('Select artists',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MultiSelectDialogField(
                      items: _seedArtists,
                      initialValue: artistsResult,
                      title: const Text('Select up to 5 artists'),
                      selectedColor: Theme.of(context).highlightColor,
                      buttonIcon: const Icon(Icons.arrow_drop_down),
                      buttonText: const Text('Choose artists'),
                      selectedItemsTextStyle:
                          Theme.of(context).textTheme.bodyLarge,
                      itemsTextStyle: Theme.of(context).textTheme.bodyLarge,
                      unselectedColor: Theme.of(context).highlightColor,
                      searchable: true,
                      separateSelectedItems: true,
                      onConfirm: (results) {
                        artistsResult = results;
                      },
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Text('Select tracks',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MultiSelectDialogField(
                      items: _seedTracks,
                      initialValue: tracksResult,
                      title: const Text('Select up to 5 tracks'),
                      selectedColor: Theme.of(context).highlightColor,
                      buttonIcon: const Icon(Icons.arrow_drop_down),
                      buttonText: const Text('Choose tracks'),
                      selectedItemsTextStyle:
                          Theme.of(context).textTheme.bodyLarge,
                      itemsTextStyle: Theme.of(context).textTheme.bodyLarge,
                      unselectedColor: Theme.of(context).highlightColor,
                      searchable: true,
                      separateSelectedItems: true,
                      onConfirm: (results) {
                        tracksResult = results;
                      },
                    )),
                ElevatedButton(
                  onPressed: () {
                    if (validateForm()) {
                      setState(() {
                        _loading = true;
                      });
                      getRecommendations(widget.userId!, genresResult,
                              artistsResult, tracksResult, limit)
                          .then((recommendationsResponse) {
                        setState(() {
                          _loading = false;
                        });
                        if (handleResponseUI(recommendationsResponse,
                                widget.userId!, context) ==
                            ReturnCodes.SUCCESS) {
                          context.go(
                              '/users/${widget.userId}/get-recommendations/recommendations',
                              extra: recommendationsResponse.content);
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select at least one genre, one artist or one track',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
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
}
