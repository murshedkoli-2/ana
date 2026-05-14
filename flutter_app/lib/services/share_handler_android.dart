import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

typedef ShareCallback = void Function(String? title, String? url);

class ShareHandler {
  StreamSubscription? _intentSub;

  /// Handle incoming shared content
  void handleIntent(ShareCallback onShare) {
    try {
      // Listen for share intent from other apps
      _intentSub?.cancel();
      _intentSub = ReceiveSharingIntent.getMediaStream()
          .listen((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final file = value.first;
          _processSharedFile(file, onShare);
        }
      }, onError: (err) {
        print('Error receiving share: $err');
      });

      // Check for initial intent if app was closed
      ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final file = value.first;
          _processSharedFile(file, onShare);
        }
      });
    } catch (e) {
      print('Error handling intent: $e');
    }
  }

  void _processSharedFile(SharedMediaFile file, ShareCallback onShare) {
    // Extract title and URL from shared content
    String? title = file.type == SharedMediaType.url ? 'Shared Video' : null;
    String? url = file.path; // URL is in path for shared URLs

    onShare(title, url);
  }

  /// Handle text sharing (for URLs shared as text)
  void handleTextShare(ShareCallback onShare) {
    try {
      ReceiveSharingIntent.getTextStream().listen(
        (String value) {
          if (value.isNotEmpty) {
            // Assume shared text is a URL
            if (value.startsWith('http://') || value.startsWith('https://')) {
              onShare('Shared Video', value);
            } else {
              onShare(value, '');
            }
          }
        },
        onError: (err) {
          print('Error receiving text share: $err');
        },
      );

      // Check initial text share
      ReceiveSharingIntent.getInitialText().then((String? value) {
        if (value != null && value.isNotEmpty) {
          if (value.startsWith('http://') || value.startsWith('https://')) {
            onShare('Shared Video', value);
          } else {
            onShare(value, '');
          }
        }
      });
    } catch (e) {
      print('Error handling text share: $e');
    }
  }

  void dispose() {
    _intentSub?.cancel();
  }
}
