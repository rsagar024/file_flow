import 'dart:convert';
import 'dart:io';

import 'package:fileflow/core/common/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../helpers/pump_app.dart';

// Smallest valid 1x1 pixel PNG.
final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==',
);

void main() {
  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
  });

  group('UserAvatar fallback', () {
    testWidgets('shows a person icon when there is no imageUrl and no displayName', (tester) async {
      await pumpApp(tester, const UserAvatar());

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows computed initials when displayName is provided', (tester) async {
      await pumpApp(tester, const UserAvatar(displayName: 'John Doe'));

      expect(find.text('JD'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('shows a single initial when displayName has only one word', (tester) async {
      await pumpApp(tester, const UserAvatar(displayName: 'John'));

      expect(find.text('J'), findsOneWidget);
    });
  });

  group('UserAvatar local file image', () {
    late File tempFile;

    setUp(() {
      tempFile = File('${Directory.systemTemp.path}/user_avatar_test_${DateTime.now().microsecondsSinceEpoch}.png');
      tempFile.writeAsBytesSync(_pngBytes);
    });

    tearDown(() {
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    });

    testWidgets('renders Image.file when imageUrl points to an existing local file', (tester) async {
      await pumpApp(tester, UserAvatar(imageUrl: tempFile.path));
      await tester.pump();

      final imageFinder = find.byWidgetPredicate((widget) => widget is Image && widget.image is FileImage);
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('falls back when imageUrl points to a non-existent local file', (tester) async {
      await pumpApp(tester, const UserAvatar(imageUrl: '/does/not/exist.png', displayName: 'AB'));

      // A single-word displayName only ever yields its first letter as the
      // initial (see UserAvatar._initials), not the whole word.
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('UserAvatar network image', () {
    testWidgets('renders without throwing for a network imageUrl', (tester) async {
      await mockNetworkImagesFor(() async {
        await pumpApp(tester, const UserAvatar(imageUrl: 'https://example.com/avatar.png'));
        await tester.pump();
      });
    });
  });
}
