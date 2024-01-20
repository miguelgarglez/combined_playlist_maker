import 'package:combined_playlist_maker/screens/generate_playlist.dart';
import 'package:combined_playlist_maker/screens/get_recommendations.dart';
import 'package:combined_playlist_maker/screens/get_top_items.dart';
import 'package:combined_playlist_maker/screens/item_display.dart';
import 'package:combined_playlist_maker/screens/landing.dart';
import 'package:combined_playlist_maker/screens/playlist_display.dart';
import 'package:combined_playlist_maker/screens/user_detail.dart';
import 'package:combined_playlist_maker/screens/users_display.dart';
import 'package:go_router/go_router.dart';

GoRouter myAppRoutes() {
  return GoRouter(initialLocation: '/', routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const MyHomePage(),
      routes: const [],
    ),
    GoRoute(
        name: 'users',
        path: '/users',
        builder: (context, state) => UsersDisplay(),
        routes: [
          GoRoute(
              name: 'generate playlist',
              path: 'generate-playlist',
              builder: (context, state) {
                return GeneratePlaylist();
              },
              routes: const []),
          GoRoute(
              name: 'user detail',
              path: ':id',
              builder: (context, state) {
                String? id = state.pathParameters['id'];
                return UserDetail(id: id);
              },
              routes: [
                // one for recommendations
                GoRoute(
                    name: 'get recommendations',
                    path: 'get-recommendations',
                    builder: (context, state) {
                      String? id = state.pathParameters['id'];
                      return GetRecommendations(userId: id);
                    },
                    routes: [
                      GoRoute(
                          name: 'result recommendations',
                          path: 'recommendations',
                          builder: (context, state) {
                            List items = state.extra as List;
                            String? id = state.pathParameters['id'];
                            return PlaylistDisplay(
                              items: items,
                              title: 'Your recommendations',
                              userId: id,
                            );
                          },
                          routes: [])
                    ]),
                // another for top items
                GoRoute(
                    name: 'get top items',
                    path: 'get-top-items',
                    builder: (context, state) {
                      String? id = state.pathParameters['id'];
                      return GetTopItems(userId: id);
                    },
                    routes: [
                      GoRoute(
                          name: 'result top tracks',
                          path: 'top-tracks',
                          builder: (context, state) {
                            List items = state.extra as List;
                            String? id = state.pathParameters['id'];
                            return PlaylistDisplay(
                              items: items,
                              title: 'Your top tracks',
                              userId: id,
                            );
                          },
                          routes: []),
                      GoRoute(
                        name: 'result top artists',
                        path: 'top-artists',
                        builder: (context, state) {
                          List items = state.extra as List;
                          return ItemDisplay(
                            items: items,
                            title: 'Your top artists',
                          );
                        },
                      )
                    ]),
              ]),
        ]),
  ]);
}
