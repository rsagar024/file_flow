import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/services/image_picker_service.dart';
import 'package:fileflow/features/auth/presentation/widgets/profile_image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  tearDown(() async {
    await getIt.reset();
    PaintingBinding.instance.imageCache.clear();
  });

  Widget buildPicker({
    String? imagePath,
    ValueChanged<String?>? onChanged,
    bool isEditing = true,
  }) {
    return Builder(
      builder: (context) => ProfileImagePickerWidget(
        context: context,
        imagePath: imagePath,
        isEditing: isEditing,
        onChanged: onChanged ?? (_) {},
      ),
    );
  }

  group('ProfileImagePickerWidget', () {
    testWidgets('renders a person icon fallback when imagePath is null', (tester) async {
      await pumpApp(tester, Scaffold(body: buildPicker(imagePath: null)));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders CachedNetworkImage for a network imagePath', (tester) async {
      await mockNetworkImagesFor(() async {
        await pumpApp(
          tester,
          Scaffold(body: buildPicker(imagePath: 'https://example.com/avatar.png')),
        );
        await tester.pump();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        expect(find.byIcon(Icons.person), findsNothing);
      });
    });

    testWidgets('renders Image.file for an existing local file path', (tester) async {
      final tempFile = File(
        '${Directory.systemTemp.path}/profile_image_picker_test_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      tempFile.writeAsBytesSync([0]);
      addTearDown(() {
        if (tempFile.existsSync()) tempFile.deleteSync();
      });

      await pumpApp(tester, Scaffold(body: buildPicker(imagePath: tempFile.path)));
      await tester.pump();

      final imageFinder = find.byWidgetPredicate((widget) => widget is Image && widget.image is FileImage);
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('shows a broken-image fallback for a non-existent local file path', (tester) async {
      await pumpApp(tester, Scaffold(body: buildPicker(imagePath: '/does/not/exist.png')));

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('Form.validate() surfaces the required error when there is no image', (tester) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Scaffold(
          body: Form(
            key: formKey,
            child: buildPicker(imagePath: null),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text(StringConstants.kProfileImageIsRequired), findsOneWidget);
    });

    testWidgets('Form.validate() surfaces no error once an image is present', (tester) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Scaffold(
          body: Form(
            key: formKey,
            child: buildPicker(imagePath: '/some/local/path.png'),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text(StringConstants.kProfileImageIsRequired), findsNothing);
    });

    testWidgets('isEditing:false hides the edit affordance', (tester) async {
      await pumpApp(tester, Scaffold(body: buildPicker(imagePath: null, isEditing: false)));

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('isEditing:true shows the edit affordance and tapping it opens the image-source sheet '
        'without throwing', (tester) async {
      getIt.registerLazySingleton<ImagePickerService>(() => MockImagePickerService());

      await pumpApp(tester, Scaffold(body: buildPicker(imagePath: null, isEditing: true)));

      expect(find.byIcon(Icons.edit), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kChooseImageSource), findsOneWidget);
      expect(find.text(StringConstants.kGallery), findsOneWidget);
      expect(find.text(StringConstants.kCamera), findsOneWidget);
    });
  });
}
