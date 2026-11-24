/// Flutter support for Bare Kit.
library;

// The JNI environment and references of package:jni are internal to it, but
// exposed for bindings outside of it, such as these.
// ignore_for_file: invalid_use_of_internal_member

import 'dart:ffi';
import 'dart:io';

import 'package:bare_kit/embedder.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';

export 'package:bare_kit/bare_kit.dart';

/// The implementation of the plugin, which Flutter registers on startup.
final class BareKitFlutter {
  BareKitFlutter._();

  static void registerWith() {
    configureFilenames(_resolveAsset);

    if (Platform.isAndroid) configureAndroid(_androidOptions);
  }
}

// Resolve an asset key against the assets that Flutter bundles with the
// application, relative to the resources that Bare Kit resolves against where
// it has them.
String _resolveAsset(String key) {
  if (Platform.isAndroid) return 'flutter_assets/$key';

  if (Platform.isIOS) return 'Frameworks/App.framework/flutter_assets/$key';

  if (Platform.isMacOS) {
    return '../Frameworks/App.framework/Resources/flutter_assets/$key';
  }

  final data = Uri(path: 'data/flutter_assets/$key');

  return File(Platform.resolvedExecutable).parent.uri
      .resolveUri(data)
      .toFilePath();
}

// Kept for as long as the process lives, as the application context does.
final _context = androidApplicationContext;

AndroidOptions _androidOptions() {
  return using((arena) {
    final jvm = arena<Pointer<Void>>();

    // Getting the virtual machine attaches the calling thread to it.
    Jni.env.GetJavaVM(jvm.cast());

    return (jvm: jvm.value, context: _context.reference.pointer);
  });
}
