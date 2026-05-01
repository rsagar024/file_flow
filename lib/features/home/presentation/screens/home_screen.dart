import 'package:fileflow/core/common/base/presentation/file_flow_stateful_widget.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        animateColor: false,
        toolbarHeight: 170,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/icons/ic_logo.svg', height: 30),
                  iconSize: 40,
                  color: AppColors.white,
                ),
                const Spacer(flex: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.white),
                    children: [
                      TextSpan(text: StringConstants.kFile),
                      TextSpan(
                        text: StringConstants.kFlow,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 5),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_rounded), color: AppColors.white),
              ],
            ),
            _customTextField(
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
          ],
        ),
      ),
      body: const AllCategoryWidget(),
      // body: const FolderCategoryWidget(),
      // body: const CategoryWidget(),
    );
  }

  Widget _customTextField({
    required String hintText,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: TextFormField(
        keyboardType: keyboardType,
        maxLength: 10,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.white),
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.grey700),
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.white, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        // validator: InputValidators.validatePhoneNumber,
      ),
    );
  }

  Widget _getChip({required String label}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: AppColors.white12, borderRadius: BorderRadius.circular(8)),
      child: Row(
        spacing: 4,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.white),
        ],
      ),
    );
  }
}
