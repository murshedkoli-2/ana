// Conditional import: use Android version on native, stub on web
export 'share_handler_android.dart'
    if (dart.library.html) 'share_handler_stub.dart';
