import 'package:flutter/material.dart';

import '../RCrewDetailPage.dart';
import '../model/RCrewModel.dart';
import 'RTagChip.dart';

class CrewCard extends StatelessWidget {

  final CrewModel crew;

  const CrewCard({
    super.key,
    required this.crew,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6,),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          /// 프로필 이미지
          Container(width: 68, height: 68,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          const SizedBox(width: 14),

          /// 정보 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(crew.role,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),


                Text(crew.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: crew.tags.map((tag) {

                      return Padding(
                        padding: const EdgeInsets.only(right: 6,),

                        child: TagChip(text: tag,),
                      );

                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// 버튼 영역
          SizedBox(
            width: 90,
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context,) {

    switch (crew.status) {

    /// 초대 예정
      case 'invite':

        return _singleButton(
          context: context,
          text: '초대하기',
          backgroundColor:
          Colors.grey.shade200,
          textColor: Colors.black,
        );

    /// 초대 수락 대기중
      case 'waiting':

        return Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            _singleButton(
              context: context,
              text: '초대 취소',
              backgroundColor:
              Colors.grey.shade600,
              textColor: Colors.white,
            ),

            const SizedBox(height: 8),

            _singleButton(
              context: context,
              text: '다시 초대',
              backgroundColor:
              Colors.grey.shade200,
              textColor: Colors.black,
            ),
          ],
        );

    /// 초대 완료
      case 'completed':

        return _singleButton(
          context: context,
          text: '상세 보기',
          backgroundColor:
          Colors.grey.shade200,
          textColor: Colors.black,

          onTap: () {

            Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => const RCrewDetailPage(),
              ),
            );
          },
        );

      default:
        return const SizedBox();
    }
  }

  Widget _singleButton({
    required BuildContext context,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {

    return SizedBox(
      width: double.infinity,
      height: 40,

      child: ElevatedButton(
        onPressed: onTap ?? () {},

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,

          elevation: 0,

          padding: EdgeInsets.zero,

          tapTargetSize: MaterialTapTargetSize.shrinkWrap,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: Text(text,

          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}