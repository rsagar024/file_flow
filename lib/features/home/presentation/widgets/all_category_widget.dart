import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
import 'package:fileflow/features/home/presentation/screens/folder_details_screen.dart';
import 'package:fileflow/features/home/presentation/widgets/file_list_item_widget.dart';
import 'package:fileflow/features/home/presentation/widgets/folder_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AllCategoryWidget extends FileFlowStatefulWidget {
  const AllCategoryWidget({super.key});

  @override
  State<AllCategoryWidget> createState() => _AllCategoryWidgetState();
}

class _AllCategoryWidgetState extends FileFlowState<AllCategoryWidget> {
  bool _isGridView = true;
  static const List<Map<String, String>> _files = [
    {'name': 'Vacation Photo.jpg', 'size': '3.2 MB', 'date': 'Apr 10, 2025'},
    {'name': 'Project Report.png', 'size': '1.8 MB', 'date': 'Apr 9, 2025'},
    {'name': 'Screenshot.png', 'size': '512 KB', 'date': 'Apr 8, 2025'},
    {'name': 'Profile Picture.jpeg', 'size': '2.1 MB', 'date': 'Apr 7, 2025'},
    {'name': 'Wallpaper.jpeg', 'size': '4.5 MB', 'date': 'Apr 6, 2025'},
    {'name': 'Design Draft.jpg', 'size': '6.0 MB', 'date': 'Apr 5, 2025'},
  ];

  String _getImageUrl(int index) {
    if (index % 3 == 0 && index % 5 == 0) {
      return 'https://images.pexels.com/photos/36597363/pexels-photo-36597363.jpeg';
    } else if (index % 3 == 0) {
      return 'https://images.pexels.com/photos/35927296/pexels-photo-35927296.jpeg';
    } else if (index % 5 == 0) {
      return 'https://images.pexels.com/photos/36681919/pexels-photo-36681919.png';
    } else {
      return 'https://images.pexels.com/photos/18578038/pexels-photo-18578038.jpeg';
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return SafeArea(
      bottom: true,
      minimum: const EdgeInsets.only(bottom: 10),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pinned Folder',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0062FF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 10.0;
                  final int crossAxisCount = constraints.maxWidth < 600
                      ? 3
                      : constraints.maxWidth < 900
                      ? 4
                      : 6;
                  final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: 20,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FolderDetailsScreen()),
                            );
                          },
                          child: SizedBox(
                            width: itemWidth,
                            child: const FolderItemWidget(name: 'Work Folder'),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    'Recent Files',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _isGridView = true),
                    child: Icon(Icons.grid_view, color: _isGridView ? const Color(0xFF0062FF) : Colors.white),
                  ),
                  const SizedBox(width: 10),
                  // List icon
                  GestureDetector(
                    onTap: () => setState(() => _isGridView = false),
                    child: Icon(Icons.list_outlined, color: !_isGridView ? const Color(0xFF0062FF) : Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (_isGridView)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 10),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: 18,
                itemBuilder: (context, index) {
                  return Image.network(
                    key: ValueKey(index),
                    _getImageUrl(index),
                    loadingBuilder: (context, child, loadingProgress) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            child,
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () {},
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                                  child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 10),
              sliver: SliverList.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index % _files.length];
                  return FileListItemWidget(
                    imageUrl: _getImageUrl(index),
                    fileName: file['name']!,
                    fileSize: file['size']!,
                    fileDate: file['date']!,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
