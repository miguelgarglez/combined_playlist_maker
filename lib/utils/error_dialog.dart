import 'package:combined_playlist_maker/services/requests.dart';
import 'package:flutter/material.dart';

showErrorDialog(context, msg, btn) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            child: Text(btn),
            onPressed: () {
              // Cierra el cuadro de diálogo
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showReauthDialog(context, msg, btn) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            child: Text(btn),
            onPressed: () {
              requestAuthorization();
            },
          ),
        ],
      );
    },
  );
}
