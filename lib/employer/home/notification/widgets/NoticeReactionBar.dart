import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../RNotificationModel.dart';

// 공지 상세 화면의 공감 바 — collapsed(집계 칩 + "+") / expanded(이모지 6개 전체) 두 상태를 갖는다.
// - canReact가 false면(사장님) "+"를 눌러도 펼쳐지지 않고 집계만 보여준다.
// - 이모지 탭 시 onSelect(reactionType)만 호출하고, 실제 API 연동/상태 갱신은 호출부(상세 페이지)가 담당한다.
class NoticeReactionBar extends StatefulWidget {
  final List<NoticeReaction> reactions;
  final String? myReactionType;
  final bool canReact;
  final ValueChanged<String>? onSelect;

  const NoticeReactionBar({
    super.key,
    required this.reactions,
    required this.myReactionType,
    required this.canReact,
    this.onSelect,
  });

  @override
  State<NoticeReactionBar> createState() => _NoticeReactionBarState();
}

class _NoticeReactionBarState extends State<NoticeReactionBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (_expanded && widget.canReact) {
      return _buildExpanded();
    }
    return _buildCollapsed();
  }

  Widget _buildCollapsed() {
    final activeReactions = widget.reactions.where((r) => r.count > 0).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        GestureDetector(
          onTap: widget.canReact ? () => setState(() => _expanded = true) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SvgPicture.asset(
              'assets/images/reactions/add_reaction.svg',
              width: 18,
              height: 18,
            ),
          ),
        ),
        ...activeReactions.map((r) {
          final isMine = widget.canReact && r.reactionType == widget.myReactionType;
          final assetPath = reactionAssetMap[r.reactionType];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isMine ? const Color(0xFFE0EEFF) : const Color(0xFFE8E8ED),
              borderRadius: BorderRadius.circular(20),
              border: isMine ? Border.all(color: const Color(0xFF0084FF)) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (assetPath != null)
                  SvgPicture.asset(assetPath, width: 18, height: 18),
                const SizedBox(width: 4),
                Text(
                  r.count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExpanded() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactionAssetMap.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                setState(() => _expanded = false);
                widget.onSelect?.call(entry.key);
              },
              child: SvgPicture.asset(entry.value, width: 28, height: 28),
            ),
          );
        }).toList(),
      ),
    );
  }
}
