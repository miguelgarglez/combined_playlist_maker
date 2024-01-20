import 'package:combined_playlist_maker/models/my_response.dart';
import 'package:combined_playlist_maker/models/track.dart';
import 'package:combined_playlist_maker/services/recommendator.dart';
import 'package:combined_playlist_maker/services/requests.dart';

/// Calculates auxiliary information about recommendations.
///
/// This function takes a map of recommendations as input and calculates the following information:
/// - Total number of tracks in all recommendations
/// - Total number of users with recommendations
/// - Number of tracks that are repeated across different recommendations
///
/// The function iterates over each list of tracks in the recommendations map and updates the respective counters.
/// It also keeps track of the unique track IDs to identify repeated tracks.
///
/// Example usage:
/// ```dart
/// Map<String, List> recommendations = {
///   'user1': [track1, track2, track3],
///   'user2': [track2, track4, track5],
///   'user3': [track3, track5, track6],
/// };
///
/// auxInfoRecommendations(recommendations);
/// ```
void auxInfoRecommendations(Map<String, List> recommendations) {
  int totalTracks = 0;
  int totalUsers = recommendations.length;
  int repeatedTracks = 0;
  List trackIds = [];

  for (List trackList in recommendations.values) {
    totalTracks += trackList.length;
    for (Track track in trackList) {
      if (trackIds.contains(track.id)) {
        // ! Debugging
        print('TRACK ${track.id} - ${track.name} IS REPEATED');
        repeatedTracks += 1;
      } else {
        trackIds.add(track.id);
      }
    }
  }

  // ! Debugging
  print('Total tracks: ${totalTracks}');
  print('Total users: ${totalUsers}');
  print('Repeated tracks: ${repeatedTracks}');
}

/// Checks all strategies for all durations and returns the results.
///
/// This function generates playlists for each strategy and duration based on the obtained recommendations.
/// It calculates the overlapping between the playlists and returns the results in a map.
/// The map contains information about the users, users' similarity, and strategies overlapping for each duration.
///
/// Returns a Future that resolves to a map containing the results.
Future<Map> checkAllStrategiesAllDurations() async {
  List<Duration> durations = [
    Duration(minutes: 10),
    Duration(minutes: 20),
    Duration(minutes: 30),
    Duration(minutes: 60),
    Duration(minutes: 90),
    Duration(minutes: 120),
    Duration(minutes: 150),
    Duration(minutes: 180),
    Duration(minutes: 210),
    Duration(minutes: 240),
    Duration(minutes: 270),
    Duration(minutes: 300),
    Duration(minutes: 330),
    Duration(minutes: 360),
    Duration(minutes: 390),
    Duration(minutes: 420),
    Duration(minutes: 450),
    Duration(minutes: 480),
    Duration(minutes: 510),
    Duration(minutes: 540),
    Duration(minutes: 570),
    Duration(minutes: 600),
  ];

  Map<String, dynamic> results = {};

  // obtain all recommendations, then generate a playlist for each strategy and duration
  MyResponse recommendationsResponse = await obtainAllUsersRecommendations();
  if (recommendationsResponse.statusCode == 200) {
    Map<String, List> recommendations = recommendationsResponse.content;
    results['users'] = recommendations.keys.toList(); // list of users ids
    results['users_similarity'] = recommendationsResponse.auxContent;
    results['strategies_overlapping'] = {};

    for (Duration duration in durations) {
      String durationKey = duration.inMinutes.toString();
      results['strategies_overlapping'][durationKey] = {};
      Map<String, List<dynamic>> recommendation = generateRecommendedPlaylist(
          recommendations, duration, [1, 1, 1], 'all');

      Map<String, Map<String, double>> overlapping =
          calculateOverlappingBetweenPlaylists(recommendation);
      results['strategies_overlapping'][durationKey] = overlapping;
    }
  } else {
    // ! Debugging
    print('Error obtaining all recommendations');
    print(recommendationsResponse);
  }

  return results;
}

/// Calculates the overlapping between playlists based on a recommendation map.
///
/// The [recommendation] map contains strategies as keys and playlists as values.
/// This function iterates over each strategy and playlist combination to calculate the overlapping.
/// The overlapping is calculated by counting the number of tracks that appear in multiple playlists.
/// The result is returned as a map, where the keys are combinations of strategies and the values are the overlapping values.
///
/// Example:
/// ```dart
/// Map<String, List<dynamic>> recommendation = {
///   'strategy1': [track1, track2, track3],
///   'strategy2': [track2, track3, track4],
/// };
///
/// Map<String, double> overlappingMap = calculateOverlapping(recommendation);
/// Result: {'strategy1-strategy2': 0.5}
/// ```
Map<String, Map<String, double>> calculateOverlappingBetweenPlaylists(
    Map<String, List<dynamic>> recommendation) {
  List<String> trackIds = [];
  Map<String, Map<String, double>> overlappingMap = {};

  for (MapEntry<String, List<dynamic>> entry1 in recommendation.entries) {
    String strategy1 = entry1.key;
    List<dynamic> playlist1 = entry1.value;

    if (overlappingMap.containsKey(strategy1) == false) {
      overlappingMap[strategy1] = {};
    }

    trackIds.clear(); // clear the list when starting with a new strategy
    for (Track track in playlist1) {
      trackIds.add(track.id); // añado todos los ids de la playlist1
    }

    for (MapEntry<String, List<dynamic>> entry2 in recommendation.entries) {
      String strategy2 = entry2.key;
      List<dynamic> playlist2 = entry2.value;

      if (strategy1 != strategy2 &&
          overlappingMap[strategy1]![strategy2] == null) {
        int overlapping = 0;

        for (Track track in playlist2) {
          if (trackIds.contains(track.id)) {
            overlapping += 1;
          }
        }

        double overlappingValue =
            overlapping / ((playlist1.length + playlist2.length) / 2);
        // add the overlapping value for both combinations of strategies, as it is
        // symmetric and has the same value
        overlappingMap[strategy1]![strategy2] = overlappingValue;
        if (overlappingMap[strategy2] == null) {
          overlappingMap[strategy2] = {};
        }
        overlappingMap[strategy2]![strategy1] = overlappingValue;
      }
    }
  }

  return overlappingMap;
}

/// Calculates the overlapping between seeds in a seed map.
///
/// Given a [seedMap] and the total number of seeds [numSeeds], this function
/// calculates the overlapping between seeds for each user in the seed map.
/// The overlapping is represented as a nested map, where the keys are the users
/// and the values are the number of overlapping seeds between each pair of users.
/// The overlapping value is normalized by dividing it by the total number of seeds.
/// The resulting seed overlapping map is returned.
Map calculateSeedOverlapping(Map<String, List> seedMap, int numSeeds) {
  Map seedOverlapping = {};

  if (seedMap.isEmpty) {
    return seedOverlapping;
  } else {
    for (String user in seedMap.keys) {
      if (seedOverlapping[user] == null) {
        seedOverlapping[user] = {};
      }
      for (String user2 in seedMap.keys) {
        if (user != user2 && seedOverlapping[user][user2] == null) {
          seedOverlapping[user][user2] = 0;
          if (seedOverlapping[user2] == null) {
            seedOverlapping[user2] = {};
          }
          seedOverlapping[user2][user] = 0;
          for (String seed in seedMap[user]!) {
            if (seedMap[user2]!.contains(seed)) {
              if (seedOverlapping[user][user2] == null) {
                seedOverlapping[user][user2] = 1;
              } else {
                seedOverlapping[user][user2] += 1;
              }
            }
          }
          seedOverlapping[user][user2] /= numSeeds;
          // as it is symmetric, we add the value to the other user
          seedOverlapping[user2][user] = seedOverlapping[user][user2];
        }
      }
    }
  }
  return seedOverlapping;
}

/// Calculates the overlapping between users seeds
///
/// Given [artistSeeds] and [trackSeeds], maps with seeds for each user of the respective type,
/// this function calculates the overlapping between the users sets of seeds.
/// This is, the overlapping in artist seeds, and the overlapping in tracks seeds
/// The number of artist seeds is specified by [numArtistSeeds], and the number of track seeds
/// is specified by [numTrackSeeds].
///
/// Returns a map containing the overlapping results for artist seeds and track seeds.
Map<String, Map> obtainSeedsOverlapping(Map<String, List> artistSeeds,
    Map<String, List> trackSeeds, int numArtistSeeds, int numTrackSeeds) {
  Map<String, Map> seedOverlapping = {'artists': {}, 'tracks': {}};
  // artist seeds overlapping
  seedOverlapping['artists'] =
      calculateSeedOverlapping(artistSeeds, numArtistSeeds);
  // track seeds overlapping
  seedOverlapping['tracks'] =
      calculateSeedOverlapping(trackSeeds, numTrackSeeds);
  return seedOverlapping;
}
