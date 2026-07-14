import 'package:flutter/material.dart';

/// 약관 및 개인정보 처리 동의 내역 페이지.
/// 회원가입 시 동의했던 약관 전문을 그대로 보여주는 정적(읽기 전용) 화면.
class TermsAndPrivacyPage extends StatelessWidget {
  const TermsAndPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ArticleTitle('제1조 (목적)'),
                    _ArticleBody(
                      '본 약관은 착착 서비스의 이용과 관련하여 “착착”과 이용자의\n'
                          '권리, 의무 및 책임사항을 규정함을 목적으로 합니다. '
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제2조 (정의)'),
                    _ArticleBody(
                      '1. "착착"이란 사장님 회원 및 알바생 회원에게 근무 일정 관리, 출퇴근 기록, 급여 계산 '
                          '등 스케줄링 관련 기능 및 이에 부수되는 다양한 정보를 제공하기 위하여 '
                          '컴퓨터, 모바일 기기 등 정보통신 설비를 이용해 구축한 가상의 영업장 또는 플랫폼을 말하며, '
                          '서비스가 제공되는 모바일 애플리케이션을 의미합니다. '
                          '아울러 이를 운영하는 사업자의 의미로도 사용합니다.\n\n'
                          '2. "이용자"란 "착착"에 접속하여 이 약관에 따라 "착착"이 제공하는 '
                          '서비스를 받는 회원 및 비회원을 말합니다.\n\n'
                          '3. "회원"이라 함은 "착착"에 접속하여 이 약관에 따라 '
                          '"착착"이 제공하는 서비스를 받는 회원 및 비회원을 말합니다.\n\n'
                          '4. "비회원"이라 함은 회원에 가입하지 않고 "착착"이 제공하는 서비스를 '
                          '이용하는 자를 말합니다.',
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제3조 (약관 등의 명시와 개정)'),
                    _ArticleBody(
                      '1. "착착"은 이 약관의 내용과 상호, 대표자 성명, 영업소 소재지 주소'
                          '(회원의 불만을 처리할 수 있는 곳의 주소를 포함), 전화번호, '
                          '전자우편주소, 개인정보보호책임자 등을 "이용회원(사장님 회원 및 알바생 회원)"이 '
                          '쉽게 알 수 있도록 스케줄링 서비스 화면(설정 또는 마이페이지 등 연결화면)에 게시합니다. '
                          '다만, 약관의 구체적인 내용은 회원이 연결화면을 통하여 볼 수 있도록 할 수 있습니다.\n\n'
                          '2. "착착"은 이용회원이 약관에 동의하기에 앞서 약관에 정해져 있는 내용 중 '
                          '유료 서비스 이용요금, 환불 조건, 회원의 책임 및 권한 제한 등과 같은 중요한 내용을 '
                          '이용회원이 쉽게 이해할 수 있도록 별도의 연결화면 또는 팝업화면 등을 제공하여 '
                          '이용회원의 확인을 구하여야 합니다.\n\n'
                          '3. "착착"은 「약관의 규제에 관한 법률」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」, '
                          '「개인정보 보호법」, 「컨텐츠산업 진흥법」 등 관련 법령을 위배하지 않는 범위에서 이 약관을 '
                          '개정할 수 있습니다.\n\n'
                          '4. "착착"은 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 서비스 내 '
                          '공지사항 화면에 그 적용일자 7일 이전부터 적용일자 전일까지 공지합니다. '
                          '다만, 이용회원에게 불리하게 약관 내용을 변경하는 경우에는 최소한 30일 이상의 사전 유예기간을 두고 공지하며, '
                          '서비스 내 공지 외에 푸시 알림, 전자우편 등 전자적 수단을 통해 회원에게 개별 통지합니다. '
                          '이 경우 "착착"은 개정 전 내용과 개정 후 내용을 명확하게 비교하여 회원이 알기 쉽도록 표시합니다.\n\n'
                          '5. "착착"은 약관을 개정할 경우, 개정약관은 그 적용일자 이후에 체결되는 계약(또는 가입)에만 적용되고 '
                          '그 이전에 이미 체결된 계약에 대해서는 개정 전의 약관조항이 그대로 적용됩니다. '
                          '다만, 이미 계약을 체결한 이용회원이 개정약관 조항의 적용을 받기를 원하는 뜻을 제4항에 의한 '
                          '개정약관의 공지기간 내에 "착착"에 송신하여 "착착"의 동의를 받은 경우에는 개정약관 조항이 적용됩니다. '
                          "(또한, 회사가 제4항에 따라 개정약관을 공지하면서 '회원이 기간 내에 거부 의사를 표시하지 않으면 동의한 것으로 본다'는 "
                          '뜻을 명확하게 공지하였음에도 회원이 명시적으로 거부 의사를 표시하지 않은 경우, '
                          '개정약관에 동의한 것으로 봅니다.)\n\n'
                          '6. 이 약관에서 정하지 아니한 사항과 이 약관의 해석에 관하여는 「약관의 규제에 관한 법률」, '
                          '정부가 정하는 관계법령 또는 상관례에 따릅니다.',
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제4조 (서비스 내용)'),
                    const SizedBox(height: 10),
                    _ArticleCard(
                      intro: '착착은 다음 서비스를 제공합니다',
                      items: const [
                        '근무자 관리',
                        '자동 스케줄 생성',
                        '근태 관리',
                        '근무 교대 및 대타 신청',
                        '공지사항 관리',
                        '알림 서비스',
                      ],
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제5조 (회원의 의무)'),
                    const SizedBox(height: 10),
                    _ArticleCard(
                      intro: '회원은 다음 행위를 해서는 안 됩니다',
                      items: const [
                        '신청 또는 변경 시 허위 내용 등록',
                        '타인의 계정 및 정보 도용',
                        '"착착"에 게시된 정보의 변경',
                        '"착착"이 정한 정보 이외의 정보 등의 송신 또는 게시',
                        '“착착” 기타 제3자의 저작권 등 지적재산권에 대한 침해',
                        '"착착" 제3자의 명예를 손상시키거나 업무를 방해하는 '
                            '행위',
                        '외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 착착에 공개 또는 게시하는 행위',
                      ],
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제6조 (서비스 변경)'),
                    _ArticleBody('1. "착착"은 다음과 같은 업무를 수행합니다'),
                    const SizedBox(height: 10),
                    _ArticleCard(
                      items: const [
                        '재화 또는 용역에 대한 정보 제공',
                        '기타 "착착"이 정하는 업무',
                      ],
                    ),
                    _ArticleBody(
                      '2. “착착”은 기술적 사양의 변경 등의 경우에는 장차 체결되는 계약에 의해 '
                          '제공할 서비스의 내용을 변경할 수 있습니다. 이 경우에는 변경된 서비스의 '
                          '내용 및 제공일자를 명시하여 현재의 서비스의 내용을 게시한 곳에 즉시 공지합니다.',
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제7조 (회원가입)'),
                    _ArticleBody(
                      '1. 이용자는 "착착"이 정한 가입 양식에 따라 회원정보를 기입한 후 '
                          '이 약관에 동의한다는 의사표시를 함으로서 회원가입을 신청합니다.\n\n'
                          '2. "착착"은 제1항과 같이 회원으로 가입할 것을 신청한 이용자 중 '
                          '다음 각 호에 해당하지 않는 한 회원으로 등록합니다.',
                    ),
                    const SizedBox(height: 10),
                    _ArticleCard(
                      items: const [
                        '가입신청자가 이 약관 제9조 제3항에 의하여 이전에 회원자격을 상실한 적이 있는 경우, '
                            '다만 제9조 제3항에 의한 회원자격 상실 후 3년이 경과한 자로서 '
                            '“착착”의 회원재가입 승낙을 얻은 경우에는 예외로 함',
                        '등록 내용에 허위, 기재누락, 오기가 있는 경우',
                        '기타 회원으로 등록하는 것이 “착착”의 기술상 현저히 지장이 있다고 판단되는 경우',
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ArticleBody(
                      '3. 회원가입계약의 성립 시기는 “착착”의 승낙이 회원에게 도달한 시점으로 합니다.\n\n'
                          '4. 회원은 회원가입 시 등록한 사항에 변경이 있는 경우, 상당한 기간 이내에 '
                          '“착착”에 대하여 회원정보 수정 등의 방법으로 그 변경사항을 알려야 합니다.',
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제8조 (회원 ID 및 비밀번호에 대한 의무)'),
                    _ArticleBody(
                      '1. 제17조의 경우를 제외한 ID와 비밀번호에 관한 관리책임은 회원에게 있습니다.\n\n'
                      '2. 회원은 자신의 ID 및 비밀번호를 제3자에게 이용하게 해서는 안됩니다.\n\n'
                      '3. 회원이 자신의 ID 및 비밀번호를 도난당하거나 제3자가 사용하고 있음을 인지한 경우에는 '
                          '바로 “착착”에 통보하고 “착착”의 안내가 있는 경우에는 그에 따라야 합니다.',
                    ),
                    SizedBox(height: 28),

                    _ArticleTitle('제9조 (회원 탈퇴 및 자격 상실 등)'),
                    _ArticleBody(
                      '1. 회원은 "착착"에 언제든지 탈퇴를 요청할 수 있으며 "착착"은 즉시 '
                          '회원탈퇴를 처리합니다.\n\n'
                          '2. 회원이 다음 각 호의 사유에 해당하는 경우, "착착"은 회원자격을 '
                          '제한 및 정지시킬 수 있습니다.',
                    ),
                    const SizedBox(height: 10),
                    _ArticleCard(
                      items: const [
                        '가입 신청 시에 허위 내용을 등록한 경우',
                        '다른 사람의 “착착” 이용을 방해하거나 그 정보를 도용하는 등 서비스 질서를 위협하는 경우',
                        '“착착”을 이용하여 법령 또는 이 약관이 금지하거나 공서양속에 반하는 행위를 하는 경우',
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ArticleBody(
                      '3. “착착”이 회원 자격을 제한․정지 시킨 후, '
                          '동일한 행위가 2회 이상 반복되거나 30일 이내에 '
                          '그 사유가 시정되지 아니하는 경우 “착착”은 회원자격을 상실시킬 수 있습니다.\n\n'
                      '4. “착착”이 회원자격을 상실시키는 경우에는 회원등록을 말소합니다. '
                          '이 경우 회원에게 이를 통지하고, 회원등록 말소 전에 최소한 '
                          '30일 이상의 기간을 정하여 소명할 기회를 부여합니다.',
                    ),
                    SizedBox(height: 36),

                    _ArticleTitle('개인정보 수집 및 이용 동의'),
                    _ArticleBody(
                      '1. 이용자의 개인정보를 수집·이용하는 때에는 당해 이용자에게 그 목적을 고지하고 동의를 받습니다.\n\n'
                          '2. 수집된 개인정보를 목적외의 용도로 이용할 수 없으며, '
                          '새로운 이용목적이 발생한 경우 또는 제3자에게 제공하는 경우에는 '
                          '이용·제공단계에서 당해 이용자에게 그 목적을 고지하고 동의를 받습니다. '
                          '다만, 관련 법령에 달리 정함이 있는 경우에는 예외로 합니다.\n\n'
                          '3. 제1항에 의해 이용자의 동의를 받아야 하는 경우에는 개인정보관리 책임자의 신원'
                          '(소속, 성명 및 전화번호, 기타 연락처), 정보의 수집목적 및 이용목적, 제3자에 대한 '
                          '정보제공 관련사항(제공받은자, 제공목적 및 제공할 정보의 내용) 등 '
                          '「정보통신망 이용촉진 및 정보보호 등에 관한 법률」에 규정한 사항을 '
                          '미리 명시하거나 고지해야 하며 이용자는 언제든지 이 동의를 철회할 수 있습니다.\n\n'
                          '4. 이용자는 언제든지 “착착”이 가지고 있는 자신의 개인정보에 대해 열람 및 오류정정을 '
                          '요구할 수 있으며 “착착”은 이에 대해 지체 없이 필요한 조치를 취할 의무를 집니다. '
                          '이용자가 오류의 정정을 요구한 경우에는 “착착”은 그 오류를 정정할 때까지 당해 '
                          '개인정보를 이용하지 않습니다.\n\n'
                      '5. “착착” 또는 그로부터 개인정보를 제공받은 제3자는 개인정보의 수집목적 '
                          '또는 제공받은 목적을 달성한 때에는 당해 개인정보를 지체 없이 파기합니다.\n\n'
                      '6. 이용자의 개인정보 수집시 서비스제공을 위하여 필요한 범위에서 최소한의 개인정보를 수집하며, '
                          '개인정보 보호법에 따라 “착착”에 가입하는 이용자로부터 다음과 같이 개인정보를 수집 및이용합니다.',
                    ),
                    SizedBox(height: 20),

                    _InfoTable(),
                    SizedBox(height: 20),

                    _ArticleBody(
                      '7. 위 개인정보 수집 및 이용에 동의하지 않을 권리가 있으며, 동의하지 않을 경우 서비스 이용이 제한될 수 있습니다.',
                    ),
                    SizedBox(height: 36),

                    _ArticleTitle('마케팅 정보 수신 동의'),
                    _ArticleBody(
                      '1. 착착은 서비스 관련 정보를 이용자에게 전송합니다'
                    ),
                    const SizedBox(height: 10),
                    _ArticleCard(
                      items: const [
                        '수신 방법',
                        '앱 푸시',
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ArticleBody(
                      '2. 선택 동의이며, 동의하지 않아도 서비스 이용은 가능합니다. '
                          '단, 동의를 거부할 경우, “착착” 서비스 관련 정보를 받으실 수 없습니다.',
                    ),
                    _ArticleCard(
                      items: const [
                        '수신 동의 철회 방법',
                        '앱 : ‘마이페이지’ > ‘계정 설정’ > ‘푸시 알림’',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 14,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            ),
          ),
          const Text(
            '약관 및 개인정보 처리 동의 내역',
            style: TextStyle(
              color: Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleTitle extends StatelessWidget {
  final String text;

  const _ArticleTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  final String text;

  const _ArticleBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF444444),
        ),
      ),
    );
  }
}

/// 항목 / 보유기간 표
/// 유형 / 처리 목적 / 보유 기간 표.
/// 스크린샷처럼 테두리 없는 둥근 컨테이너 안에 헤더 + 구분선 + 행으로 표시된다.
class _InfoTable extends StatelessWidget {
  const _InfoTable();

  static const List<String> _headers = ['유형', '처리 목적', '보유 기간'];

  static const List<List<String>> _rows = [
    ['이름', '회원 식별', '탈퇴 후 30일'],
    ['이메일', '로그인', '탈퇴 후 30일'],
    ['휴대폰 번호', '본인 확인', '탈퇴 후 30일'],
    ['매장 정보', '스케줄 관리', '탈퇴 후 30일'],
    ['근무자 정보', '근무자 관리', '탈퇴 후 30일'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _buildRow(
            cells: _headers,
            textColor: const Color(0xFFACACAC),
            fontWeight: FontWeight.w500,
          ),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          ..._rows.asMap().entries.map((entry) {
            final isLast = entry.key == _rows.length - 1;
            return Column(
              children: [
                _buildRow(
                  cells: entry.value,
                  textColor: const Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                ),
                if (!isLast)
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow({
    required List<String> cells,
    required Color textColor,
    required FontWeight fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: cells
            .map(
              (cell) => Expanded(
            child: Text(
              cell,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

/// 제4~6조처럼 "안내 문구 + 항목 리스트"를 회색 컨테이너 안에
/// 구분선으로 나눠 보여주는 위젯.
/// [intro]는 컨테이너 첫 줄에 옅은 회색으로 표시되고, [items]는 그 아래
/// 구분선과 함께 나열된다.
class _ArticleCard extends StatelessWidget {
  final String? intro;
  final List<String> items;

  const _ArticleCard({this.intro, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F5), // 수정
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intro != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                intro!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: Color(0xFF767676),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
          ],
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
              ],
            );
          }),
        ],
      ),
    );
  }
}