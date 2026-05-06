import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/common/shapes/dotted_border_painter.dart';
import 'package:fileflow/core/common/widgets/folder_card.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UploadScreen extends FileFlowStatelessWidget {
  static const routeName = '/upload';

  const UploadScreen({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        animateColor: false,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SvgPicture.asset('assets/icons/ic_logo.svg', height: 30),
        ),
        leadingWidth: 76,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_rounded), color: AppColors.white)],
        title: RichText(
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 4),
            child: CustomPaint(
              painter: const DottedBorderPainter(color: AppColors.grey, strokeWidth: 0.8, dashPattern: [6, 6]),
              size: Size.infinite,
              isComplex: true,
              willChange: false,
              child: Container(
                color: AppColors.transparent,
                height: 195,
                width: double.infinity,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_sharp, color: AppColors.white),
                    SizedBox(height: 5),
                    Text(
                      StringConstants.kSelectYourFiles,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10).copyWith(left: 24, top: 18),
                  margin: const EdgeInsets.all(16).copyWith(bottom: 0),
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey),
                  ),
                  child: const Row(
                    children: [
                      FolderCard(size: 50, tabWidth: 1),
                      SizedBox(width: 20),
                      Text(
                        StringConstants.kRoot,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, size: 35, color: AppColors.white),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 32,
                  right: 32,
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Container(height: 1, color: AppColors.grey)),
                      Container(
                        color: AppColors.neutral900,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text(
                          StringConstants.kLocation,
                          style: TextStyle(color: AppColors.white, fontSize: 12),
                        ),
                      ),
                      Expanded(flex: 25, child: Container(height: 1, color: AppColors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                StringConstants.kUploadFile,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ),
          ),
          // Expanded(
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: [
          //       Container(
          //         alignment: Alignment.center,
          //         width: MediaQuery.sizeOf(context).width / 3 + 40,
          //         padding: EdgeInsets.symmetric(vertical: 10),
          //         margin: EdgeInsets.only(right: 10),
          //         decoration: BoxDecoration(
          //           color: AppColors.white12,
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Text(
          //               'Projects',
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.w500,
          //                 color: AppColors.white,
          //               ),
          //             ),
          //             SizedBox(height: 10),
          //             Expanded(
          //               child: ListView.builder(
          //                 itemCount: 10,
          //                 itemBuilder: (context, index) {
          //                   return Padding(
          //                     padding: EdgeInsets.only(
          //                       bottom: index == 9 ? 30 : 0,
          //                       left: 30,
          //                     ),
          //                     child: FolderItemWidget(name: 'Projects'),
          //                   );
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: MediaQuery.sizeOf(context).width / 3 + 40,
          //         padding: EdgeInsets.symmetric(vertical: 10),
          //         margin: EdgeInsets.only(right: 10),
          //         decoration: BoxDecoration(
          //           color: AppColors.white38,
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Text(
          //               'Projects',
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.w500,
          //                 color: AppColors.white,
          //               ),
          //             ),
          //             SizedBox(height: 10),
          //             Expanded(
          //               child: ListView.builder(
          //                 itemCount: 10,
          //                 itemBuilder: (context, index) {
          //                   return Padding(
          //                     padding: EdgeInsets.only(
          //                       bottom: index == 9 ? 30 : 0,
          //                       left: 30,
          //                     ),
          //                     child: FolderItemWidget(name: 'Hacking Data'),
          //                   );
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: MediaQuery.sizeOf(context).width / 3 + 40,
          //         padding: EdgeInsets.symmetric(vertical: 10),
          //         margin: EdgeInsets.only(right: 10),
          //         decoration: BoxDecoration(
          //           color: AppColors.white12,
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Text(
          //               'Hacking Data',
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.w500,
          //                 color: AppColors.white,
          //               ),
          //             ),
          //             SizedBox(height: 10),
          //             Expanded(
          //               child: ListView.builder(
          //                 itemCount: 10,
          //                 itemBuilder: (context, index) {
          //                   return Padding(
          //                     padding: EdgeInsets.only(
          //                       bottom: index == 9 ? 30 : 0,
          //                       left: 30,
          //                     ),
          //                     child: FolderItemWidget(name: 'Development'),
          //                   );
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          /*Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  height: double.infinity,
                  width: MediaQuery.sizeOf(context).width / 3 + 40,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.only(right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? AppColors.white12 : AppColors.white38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Projects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == 9 ? 30 : 0,
                                left: 30,
                              ),
                              child: FolderItemWidget(name: 'Projects'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }
}
