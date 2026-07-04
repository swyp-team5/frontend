// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:photo_manager/photo_manager.dart';
//
// import 'RNotificationModel.dart';
// import 'RNotificationProvider.dart';
//
// class RNotiEditPage extends ConsumerStatefulWidget {
//   final RNotificationModel notice;
//   final int noticeIndex;
//
//   const RNotiEditPage({
//     super.key,
//     required this.notice,
//     required this.noticeIndex,
//   });
//
//   @override
//   ConsumerState<RNotiEditPage> createState() =>
//       _RNotiEditPageState();
// }
//
// class _RNotiEditPageState
//     extends ConsumerState<RNotiEditPage> {
//   late TextEditingController titleController;
//   late TextEditingController contentController;
//
//   File? selectedImage;
//
//   @override
//   void initState() {
//     super.initState();
//
//     titleController =
//         TextEditingController(text: widget.notice.title);
//
//     contentController =
//         TextEditingController(text: widget.notice.content);
//
//     if (widget.notice.imagePath != null) {
//       selectedImage = File(widget.notice.imagePath!);
//     }
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     contentController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updateNotice() async {
//     final updatedNotice = RNotificationModel(
//       title: titleController.text,
//       content: contentController.text,
//       writer: widget.notice.writer,
//       date: DateFormat('M월 d일 HH:mm')
//           .format(DateTime.now()),
//       imagePath: selectedImage?.path,
//       reactions: widget.notice.reactions,
//     );
//
//     await ref
//         .read(RNotificationProvider.notifier)
//         .updateNotice(
//       widget.noticeIndex,
//       updatedNotice,
//     );
//
//     if (!mounted) return;
//
//     Navigator.pop(context);
//     Navigator.pop(context);
//   }
//
//   Future<void> _showEditDialog() async {
//     if (titleController.text.trim().isEmpty ||
//         contentController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('제목과 내용을 모두 입력해주세요.'),
//         ),
//       );
//       return;
//     }
//
//     final confirm = await showDialog<bool>(
//       context: context,
//       barrierColor: Colors.black54,
//       builder: (context) {
//         return Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             margin: const EdgeInsets.only(
//               left: 16,
//               right: 16,
//               bottom: 20,
//             ),
//             child: Material(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       '공지글을 수정하시겠습니까?',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         decoration: TextDecoration.none,
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     /// 수정하기
//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context, true);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0084FF),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           '수정하기',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     /// 취소
//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.pop(context, false);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           '취소',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//
//     if (confirm == true) {
//       await _updateNotice();
//     }
//   }
//
//   Future<void> _showGalleryBottomSheet() async {
//     final PermissionState ps =
//     await PhotoManager.requestPermissionExtend();
//
//     if (!ps.isAuth &&
//         ps != PermissionState.limited) {
//       return;
//     }
//
//     final albums =
//     await PhotoManager.getAssetPathList(
//       type: RequestType.image,
//       onlyAll: true,
//     );
//
//     if (albums.isEmpty) return;
//
//     final images =
//     await albums.first.getAssetListPaged(
//       page: 0,
//       size: 100,
//     );
//
//     images.sort(
//           (a, b) =>
//           b.createDateTime.compareTo(
//             a.createDateTime,
//           ),
//     );
//
//     if (!mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(28),
//         ),
//       ),
//       builder: (context) {
//         AssetEntity? tempSelectedAsset;
//
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return SizedBox(
//               height: MediaQuery.of(context).size.height * 0.7,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 12),
//
//                   /// 상단 드래그 바
//                   Container(
//                     width: 50,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   /// 제목 + 닫기 버튼
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: SizedBox(
//                       height: 44,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           const Center(
//                             child: Text(
//                               '최근 항목',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//
//                           Positioned(
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Container(
//                                 width: 36,
//                                 height: 36,
//                                 decoration: const BoxDecoration(
//                                   color: Color(0xFFF2F2F7),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.close,
//                                   color: Colors.grey,
//                                   size: 22,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   Expanded(
//                     child: images.isEmpty
//                         ? const Center(
//                       child: Text('사진이 없습니다.'),
//                     )
//                         : GridView.builder(
//                       padding: EdgeInsets.zero,
//                       itemCount: images.length + 1,
//                       gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 2,
//                         mainAxisSpacing: 2,
//                       ),
//                       itemBuilder: (context, index) {
//                         /// 첫 번째 셀 = 카메라
//                         if (index == 0) {
//                           return Container(
//                             color: const Color(0xFFE5E5EA),
//                             child: const Center(
//                               child: Icon(
//                                 Icons.camera_alt_outlined,
//                                 size: 34,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           );
//                         }
//
//                         final asset = images[index - 1];
//                         final isSelected =
//                             tempSelectedAsset?.id == asset.id;
//
//                         return FutureBuilder<Uint8List?>(
//                           future: asset.thumbnailDataWithSize(
//                             const ThumbnailSize(300, 300),
//                           ),
//                           builder: (context, snapshot) {
//                             if (!snapshot.hasData) {
//                               return Container(
//                                 color: Colors.grey.shade200,
//                               );
//                             }
//
//                             return GestureDetector(
//                               onTap: () {
//                                 setModalState(() {
//                                   tempSelectedAsset = asset;
//                                 });
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: isSelected
//                                       ? Border.all(
//                                     color: Colors.blue,
//                                     width: 3,
//                                   )
//                                       : null,
//                                 ),
//                                 child: Stack(
//                                   children: [
//                                     Positioned.fill(
//                                       child: Image.memory(
//                                         snapshot.data!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//
//                                     /// 체크박스
//                                     Positioned(
//                                       top: 8,
//                                       right: 8,
//                                       child: Container(
//                                         width: 24,
//                                         height: 24,
//                                         decoration: BoxDecoration(
//                                           color: isSelected
//                                               ? Colors.blue
//                                               : Colors.white,
//                                           borderRadius:
//                                           BorderRadius.circular(6),
//                                           border: Border.all(
//                                             color: Colors.grey.shade300,
//                                           ),
//                                         ),
//                                         child: isSelected
//                                             ? const Icon(
//                                           Icons.check,
//                                           size: 16,
//                                           color: Colors.white,
//                                         )
//                                             : null,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 12, 20, 24,),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: tempSelectedAsset == null
//                             ? null
//                             : () async {
//                           final file =
//                           await tempSelectedAsset!.originFile;
//
//                           if (file != null) {
//                             setState(() {
//                               selectedImage = file;
//                             });
//
//                             if (mounted) {
//                               Navigator.pop(context);
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF007AFF),
//                           disabledBackgroundColor:
//                           const Color(0xFFE5E5EA),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           '사진 선택',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding:
//               const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 30,
//               ),
//               child: Row(
//                 mainAxisAlignment:
//                 MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () =>
//                         Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back_ios_new,
//                     ),
//                   ),
//
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed:
//                         _showGalleryBottomSheet,
//                         icon: const Icon(
//                           Icons.image_outlined,
//                           size: 28,
//                         ),
//                       ),
//
//                       const SizedBox(width: 8),
//
//                       SizedBox(
//                         width: 88,
//                         height: 40,
//                         child: ElevatedButton(
//                           onPressed: _showEditDialog,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE6F3FF),
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             '수정',
//                             style: TextStyle(
//                               color: Color(0xFF0063BF),
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             Expanded(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextField(
//                       controller: titleController,
//                       decoration:
//                       const InputDecoration(
//                         border: InputBorder.none,
//                         hintText:
//                         '제목을 입력해주세요.',
//                       ),
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 10,),
//                   Divider(
//                     color: Color(0xFFE5E5E5),
//                   ),
//
//                   Expanded(
//                     child:
//                     SingleChildScrollView(
//                       padding:
//                       const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           TextField(
//                             controller: contentController,
//                             maxLines: null,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText:
//                               '공지내용을 입력해 주세요.',
//                             ),
//                             style: const TextStyle(
//                               fontSize: 16,
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           if (selectedImage != null)
//                             Stack(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.file(selectedImage!,),
//                                 ),
//
//                                 Positioned(
//                                   top: 10,
//                                   right: 10,
//                                   child:
//                                   GestureDetector(
//                                     onTap: () {
//                                       setState(
//                                             () {
//                                           selectedImage =
//                                           null;
//                                         },
//                                       );
//                                     },
//                                     child:
//                                     Container(
//                                       width: 32,
//                                       height: 32,
//                                       decoration:
//                                       const BoxDecoration(
//                                         color: Colors
//                                             .white,
//                                         shape: BoxShape
//                                             .circle,
//                                       ),
//                                       child:
//                                       const Icon(Icons.close,
//                                         size: 20,),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }