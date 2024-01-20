class Playlist {
  bool collaborative;
  String description;
  String externalUrls;
  String href;
  String id;
  String imageUrl;
  String name;
  String owner;
  bool public;
  List tracks;
  String type;
  String uri;

  Playlist({
    required this.collaborative,
    required this.description,
    required this.externalUrls,
    required this.href,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.owner,
    required this.public,
    required this.tracks,
    required this.type,
    required this.uri,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      collaborative: json['collaborative'] ?? false,
      description: json['description'] ?? '',
      externalUrls: json['external_urls']['spotify'] ?? '',
      href: json['href'] ?? '',
      id: json['id'] ?? '',
      imageUrl: json['images'][0]['url'] ??
          '', // * lista de maps {height, url, width}
      name: json['name'] ?? '',
      owner: json['owner']['id'] ?? '',
      public: json['public'] ?? false,
      // * lista de maps {added_at, added_by, is_local, primary_color, track}
      // * y cojo solamente el objeto track
      tracks:
          json['tracks']['items'].map((item) => item['track']).toList() ?? [],
      type: json['type'] ?? '',
      uri: json['uri'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Playlist{collaborative: $collaborative, description: $description, '
        'externalUrls: $externalUrls, href: $href, id: $id, '
        'images: $imageUrl, name: $name, owner: $owner, '
        'public: $public, tracks: $tracks, type: $type, uri: $uri}';
  }
}
