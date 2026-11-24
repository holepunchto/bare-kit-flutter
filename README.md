# bare-kit-flutter

Flutter support for [Bare Kit](https://github.com/holepunchto/bare-kit), which runs Bare in a thread of its own within the application, known as a worklet, with an IPC to it exposed as `Bare.IPC` inside the worklet. It provides [`bare_kit`](https://pub.dev/packages/bare_kit) with what it needs from Flutter, such as the application context on Android.

```
flutter pub add bare_kit_flutter
```

## Usage

```dart
import 'dart:convert';

import 'package:bare_kit_flutter/bare_kit_flutter.dart';

void main() async {
  final worklet = Worklet.start('assets/app.bundle');

  worklet.add(utf8.encode('Hello world'));

  await for (final data in utf8.decoder.bind(worklet)) {
    print(data);
  }

  worklet.destroy();
}
```

Where `assets/app.bundle` is a Bare bundle using `Bare.IPC`, listed as an asset of the application:

```js
Bare.IPC.on('data', (data) => Bare.IPC.end(data))
```

```yaml
flutter:
  assets:
    - assets/app.bundle
```

See [`bare_kit`](https://pub.dev/packages/bare_kit) for the API, which is exported as is, and [Bare Kit](https://github.com/holepunchto/bare-kit) for the [lifecycle](https://github.com/holepunchto/bare-kit#lifecycle), [IPC](https://github.com/holepunchto/bare-kit#ipc), [suspension](https://github.com/holepunchto/bare-kit#suspension), [addons](https://github.com/holepunchto/bare-kit#addons), and [error handling](https://github.com/holepunchto/bare-kit#error-handling) of a worklet. In Flutter terms:

- A relative filename names a Flutter asset by its key.
- Worklets started from a background isolate need it to call `DartPluginRegistrant.ensureInitialized()` first.
- An uncaught error in the worklet aborts the process, the application included, so report errors over `Bare.IPC` as described in [error handling](https://github.com/holepunchto/bare-kit#error-handling).

## Platforms

The package supports Android, iOS, Linux, macOS, and Windows. On Android, assets are not files, so the resources of a bundle that it loads at runtime, such as addons, must be listed one `/<path>` per line in `<name>.assets` next to it and be stored in `<name>/<path>`, all as Flutter assets, from where Bare Kit extracts them before the bundle first runs.

## License

Apache-2.0
