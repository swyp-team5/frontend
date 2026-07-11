import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// 약관 상세 바텀시트 — Agree1/2/3BottomSheet를 대체하는 범용 위젯.
// 서버가 이미 완성된 본문(content, Markdown)을 내려주기 때문에, 제목+본문만 있으면 된다.
class TermsDetailBottomSheet extends StatelessWidget {
  final String title;
  final String content;

  const TermsDetailBottomSheet({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xffF1F1F5),
                    child: Icon(Icons.close, size: 18, color: Color(0xff9A9A9A)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            Expanded(
              child: Markdown(
                data: content,
                padding: const EdgeInsets.only(top: 24),
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF505050),
                    height: 1.6,
                  ),
                  h3: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 2.0,
                  ),
                  strong: const TextStyle(fontWeight: FontWeight.w700),
                  listBullet: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF505050),
                  ),
                  tableBorder: TableBorder.all(color: const Color(0xFFE5E5EC)),
                  tableCellsPadding: const EdgeInsets.all(8),
                  tableHead: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tableBody: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xff0084FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
