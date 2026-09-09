import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:fileflow/features/home/presentation/widgets/all_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // The pinned-folders grid alone nearly fills the default 800x600 test
  // surface, so the sliver framework won't even build the "Recent Files"
  // header/grid below it (outside the render + cache extent) unless the
  // surface is made tall enough to fit everything without scrolling.
  // setSurfaceSize must run inside testWidgets, not setUp/tearDown, or it
  // trips TestWidgetsFlutterBinding's inTest assertion.
  Future<void> enlargeSurface() async {
    await binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() async {
      PaintingBinding.instance.imageCache.clear();
      await binding.setSurfaceSize(null);
    });
  }

  testWidgets('renders the search field and category chips', (tester) async {
    await enlargeSurface();
    await mockNetworkImagesFor(() async {
      await pumpApp(tester, const HomeScreen());
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kSearchInFileFlow), findsOneWidget);
      expect(find.text(StringConstants.kAll), findsOneWidget);
      expect(find.text(StringConstants.kFolders), findsOneWidget);
      expect(find.text(StringConstants.kImages), findsOneWidget);
      expect(find.text(StringConstants.kVideos), findsOneWidget);
      expect(find.text(StringConstants.kAudios), findsOneWidget);
      expect(find.text(StringConstants.kDocuments), findsOneWidget);
    });
  });

  testWidgets('renders the pinned folders + recent files section', (tester) async {
    await enlargeSurface();
    await mockNetworkImagesFor(() async {
      await pumpApp(tester, const HomeScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AllCategoryWidget), findsOneWidget);
      expect(find.text(StringConstants.kPinnedFolder), findsOneWidget);
      expect(find.text(StringConstants.kRecentFiles), findsOneWidget);
    });
  });
}
