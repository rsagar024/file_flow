import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryWidget extends FileFlowStatelessWidget {
  const CategoryWidget({super.key});

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
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 30),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childCount: 50,
            itemBuilder: (context, index) {
              return Image.network(key: ValueKey(index), _getImageUrl(index));
            },
          ),
        ),
      ],
    );
  }
}
