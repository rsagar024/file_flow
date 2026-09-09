import 'package:fileflow/features/home/presentation/screens/folder_details_screen.dart';
import 'package:fileflow/features/home/presentation/widgets/folder_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // The 5 pinned FolderItemWidgets alone nearly fill the default 800x600
  // test surface, so the 18-image masonry grid below them wouldn't be built
  // at all (outside the sliver render + cache extent) without a taller
  // surface.
  testWidgets('builds without throwing and renders the hardcoded title + folders', (tester) async {
    // setSurfaceSize must run inside testWidgets, not setUp/tearDown, or it
    // trips TestWidgetsFlutterBinding's inTest assertion.
    await binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() async {
      PaintingBinding.instance.imageCache.clear();
      await binding.setSurfaceSize(null);
    });

    await mockNetworkImagesFor(() async {
      await pumpApp(tester, const FolderDetailsScreen());
      await tester.pumpAndSettle();

      // AppBar title + one Text per List.generate(5, ...) folder item.
      expect(find.text('Work Folder'), findsNWidgets(6));
      expect(find.byType(FolderItemWidget), findsNWidgets(5));

      // The 18-item masonry grid of remote images renders at least the
      // visible ones without throwing (network_image_mock stands in for the
      // real network calls).
      expect(find.byType(Image), findsWidgets);
    });
  });
}
