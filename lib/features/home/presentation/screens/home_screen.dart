import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_app_bar.dart';
import 'package:fileflow/core/common/widgets/file_flow_text_field_widget.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/features/home/presentation/widgets/all_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends FileFlowStatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends FileFlowState<HomeScreen> {
  static const List<String> categories = [
    StringConstants.kAll,
    StringConstants.kFolders,
    StringConstants.kImages,
    StringConstants.kVideos,
    StringConstants.kAudios,
    StringConstants.kDocuments,
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: FileFlowAppBar(
        leading: SvgPicture.asset('assets/icons/ic_logo.svg', height: 30),
        titleWidget: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
            children: const [
              TextSpan(text: StringConstants.kFile),
              TextSpan(
                text: StringConstants.kFlow,
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        trailing: InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () {},
          child: Icon(Icons.notifications_rounded, color: context.colors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            FileFlowTextFieldWidget(
              hintText: StringConstants.kSearchInFileFlow,
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
              margin: const EdgeInsets.symmetric(vertical: 16),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: List.generate(categories.length, (index) => _getChip(label: categories[index]))),
            ),
            const SizedBox(height: 20),
            const Expanded(child: AllCategoryWidget()),
          ],
        ),
      ),
      // body: const FolderCategoryWidget(),
      // body: const CategoryWidget(),
    );
  }

  Widget _getChip({required String label}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: context.colors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
      child: Row(
        spacing: 4,
        children: [
          Text(
            label,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.textPrimary),
        ],
      ),
    );
  }
}
