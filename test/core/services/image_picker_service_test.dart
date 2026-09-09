import 'dart:io';

import 'package:fileflow/core/services/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockImagePicker mockImagePicker;
  late ImagePickerService service;
  late Directory tempDir;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockImagePicker = MockImagePicker();
    service = ImagePickerService(imagePicker: mockImagePicker);
    tempDir = Directory.systemTemp.createTempSync('image_picker_service_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File writeFile(String name, int bytes) {
    final file = File('${tempDir.path}${Platform.pathSeparator}$name');
    file.writeAsBytesSync(List.filled(bytes, 0));
    return file;
  }

  group('pickImage', () {
    test('returns the picked file path when no maxFileSize is given', () async {
      final file = writeFile('small.jpg', 100);
      when(
        () => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile(file.path));

      final result = await service.pickImage();

      expect(result, file.path);
    });

    test('returns null when the user cancels the picker', () async {
      when(
        () => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.pickImage();

      expect(result, isNull);
    });

    test('throws when the picked file exceeds maxFileSize', () async {
      final file = writeFile('big.jpg', 100);
      when(
        () => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile(file.path));

      await expectLater(
        service.pickImage(maxFileSize: 0),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('File size exceeds'))),
      );
    });

    test('passes the requested source through to the underlying picker', () async {
      when(
        () => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      await service.pickImage(source: ImageSource.camera);

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).called(1);
    });
  });

  group('pickMultipleImages', () {
    test('returns all picked paths when no maxFileSize is given', () async {
      final fileA = writeFile('a.jpg', 100);
      final fileB = writeFile('b.jpg', 200);
      when(
        () => mockImagePicker.pickMultiImage(
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => [XFile(fileA.path), XFile(fileB.path)]);

      final result = await service.pickMultipleImages();

      expect(result, [fileA.path, fileB.path]);
    });

    test('filters out files exceeding maxFileSize, keeping the rest', () async {
      final withinLimit = writeFile('small.jpg', 100);
      final overLimit = writeFile('large.jpg', 2000000);
      when(
        () => mockImagePicker.pickMultiImage(
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => [XFile(withinLimit.path), XFile(overLimit.path)]);

      final result = await service.pickMultipleImages(maxFileSize: 1);

      expect(result, [withinLimit.path]);
    });

    test('returns an empty list when the user picks nothing', () async {
      when(
        () => mockImagePicker.pickMultiImage(
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => []);

      final result = await service.pickMultipleImages();

      expect(result, isEmpty);
    });
  });

  group('isValidImageFile', () {
    test('returns true for an existing file with a recognized image extension', () {
      final file = writeFile('photo.png', 10);
      expect(service.isValidImageFile(file.path), isTrue);
    });

    test('returns false for an existing file with an unrecognized extension', () {
      final file = writeFile('notes.txt', 10);
      expect(service.isValidImageFile(file.path), isFalse);
    });

    test('returns false for a non-existent path', () {
      expect(service.isValidImageFile('${tempDir.path}${Platform.pathSeparator}missing.jpg'), isFalse);
    });
  });

  group('getFileSizeInMB', () {
    test('returns the file size in MB for an existing file', () {
      final file = writeFile('one_mb.bin', 1024 * 1024);
      expect(service.getFileSizeInMB(file.path), closeTo(1.0, 0.0001));
    });

    test('returns 0 for a non-existent path', () {
      expect(service.getFileSizeInMB('${tempDir.path}${Platform.pathSeparator}missing.bin'), 0);
    });
  });
}
