import 'package:combined_playlist_maker/models/my_response.dart';
import 'package:combined_playlist_maker/src/return_codes.dart';
import 'package:combined_playlist_maker/utils/error_dialog.dart';
import 'package:flutter/material.dart';

int handleResponseUI(MyResponse? r, String? userId, BuildContext context) {
  if (r?.statusCode == 400) {
    showErrorDialog(
        context,
        'An error (${r?.statusCode}) occured with Spotify API. Make sure you select some parameters and try again.',
        'OK');
    return ReturnCodes.BAD_REQUEST;
  } else if (r?.statusCode == 200) {
    return ReturnCodes.SUCCESS;
  } else if (r?.statusCode == 201) {
    return ReturnCodes.SUCCESS;
  } else if (r?.statusCode == 429) {
    showErrorDialog(
        context,
        'An error (${r?.statusCode}) occured with Spotify API. Too many requests. Try again later.',
        'OK');
    return ReturnCodes.TOO_MANY_REQUESTS;
  } else if (r?.statusCode == 401) {
    if (r!.auxContent.isNotEmpty) {
      userId = r.auxContent.values.first;
    }
    showReauthDialog(
        context,
        'An error (${r.statusCode}) refreshing token for $userId occured with Spotify API. Reauthenticate with $userId and try again.',
        'Authenticate again');
    return ReturnCodes.TOKEN_ERROR;
  } else {
    showErrorDialog(
        context,
        'An error (${r?.statusCode}) occured with Spotify API. Try again',
        'OK');
    return ReturnCodes.GENERIC_ERROR;
  }
}
