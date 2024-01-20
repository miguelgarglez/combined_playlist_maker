class Track {
  List<Map<String, String>> artists;
  int durationMs;
  String isrc;
  String href;
  String id;
  String name;
  String imageUrl;
  int popularity;
  int trackNumber;
  String uri;

  Track({
    required this.artists,
    required this.durationMs,
    required this.isrc,
    required this.href,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.popularity,
    required this.trackNumber,
    required this.uri,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    var imageUrl;
    if ((json['album']['images'] as List).isNotEmpty) {
      // La lista de imágenes no está vacía y puedes acceder a json['album']['images'][0]
      imageUrl = json['album']['images'][0]
          ['url']; // hay tres imágenes, cogemos la de mayor tamaño
    } else {
      // La lista de imágenes está vacía o no existe la clave 'images' en el JSON
      imageUrl = '';
    }

    return Track(
      artists: List<Map<String, String>>.from(json['artists'].map((artist) =>
          <String, String>{'id': artist['id'], 'name': artist['name']})),
      durationMs: json['duration_ms'],
      isrc: json['external_ids']['isrc'],
      href: json['href'],
      id: json['id'],
      name: json['name'],
      imageUrl: imageUrl,
      popularity: json['popularity'],
      trackNumber: json['track_number'],
      uri: json['uri'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Track{id: $id, name: $name, artists: $artists, popularity: $popularity}';
  }
}
