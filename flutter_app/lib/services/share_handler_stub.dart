typedef ShareCallback = void Function(String? title, String? url);

class ShareHandler {
  /// Handle incoming shared content (no-op on web)
  void handleIntent(ShareCallback onShare) {
    // Not supported on web
  }

  /// Handle text sharing (no-op on web)
  void handleTextShare(ShareCallback onShare) {
    // Not supported on web
  }

  void dispose() {
    // No-op on web
  }
}
