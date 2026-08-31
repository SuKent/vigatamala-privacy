# Vigatamala 차단 규칙

[繁體中文](/rules.zh-Hant) · [简体中文](/rules.zh-Hans) · [English](/rules.en) · [日本語](/rules.ja) · [한국어](/rules.ko)

여기에는 Vigatamala iOS 브라우저가 사용하는 광고 및 트래커 차단 규칙이 있습니다.

이 두 목록은 **앱에 함께 포함되어 있지 않으며**, 사용자가 앱 안에서 내려받습니다 — 다시 말해, 아래 파일들이 바로 앱이 실제로 가져다 쓰는 그 변환 결과물이며, 누구든 직접 내려받아 살펴보거나 스스로 사용할 수도 있습니다(아래 라이선스 참조).

## 다운로드

| 파일 | 설명 |
|---|---|
| [easylist.json](https://privacy.link2us.link/rules/easylist.json) | EasyList의 content blocker 개작본 |
| [easylist.NOTICE.txt](https://privacy.link2us.link/rules/easylist.NOTICE.txt) | 저작자 표시 및 상위 원본의 저작권 고지 |
| [easyprivacy.json](https://privacy.link2us.link/rules/easyprivacy.json) | EasyPrivacy의 content blocker 개작본 |
| [easyprivacy.NOTICE.txt](https://privacy.link2us.link/rules/easyprivacy.NOTICE.txt) | 위와 같음 |
| [easylist.json.sig](https://privacy.link2us.link/rules/easylist.json.sig) | Ed25519 서명(앱에서 검증하는 용도) |
| [easyprivacy.json.sig](https://privacy.link2us.link/rules/easyprivacy.json.sig) | 위와 같음 |

## 이것이 무엇인지

위의 두 JSON은 [EasyList](https://easylist.to/)와 EasyPrivacy의 **개작물**입니다. 저희는 Adblock Plus 필터 문법을 Apple의 Safari content blocker JSON 형식으로 변환했으며, 그 과정에서 다음과 같이 했습니다.

- 해당 형식으로 표현할 수 없는 규칙 유형(scriptlet 주입, 고급 옵션 등)은 버렸습니다.
- 65,000개로 잘라냈습니다 — 이것은 **저희가 스스로 정한** 보수적인 상한이며(구형 기기의 컴파일 시간과 메모리를 고려한 것입니다), 형식 자체의 한계는 아닙니다. 오늘의 상위 원본을 기준으로 보면 이 상한이 **실제로 무엇인가를 잘라내지는 않았습니다**(easylist 60,928개, easyprivacy 55,895개로 모두 상한 안에 있습니다). WebKit은 현재 150,000개를 넘는 목록을 파싱 단계에서 거부하지만, 그 숫자는 WebKit의 구현 세부 사항이고(Apple 문서에는 명시되어 있지 않으며, 2020년 말에야 50,000에서 올라간 것입니다), 게다가 ‘컴파일 프로세스의 약 150 MB 메모리 예산’에 맞춰 정해진 상한선입니다 — 컴파일이 되는 규칙 수와 컴파일할 가치가 있는 규칙 수는 같은 것이 아니며, 저희는 그 선에 가까이 갈 생각이 없습니다.

따라서 이것은 상위 원본 목록과 **같지 않으며**, 차단 효과도 완전히 같지는 않습니다. 온전한 원본을 원하신다면 [상위 원본](https://easylist.to/)을 직접 사용하십시오.

## 라이선스

상위 원본은 GPLv3 또는 CC BY-SA 3.0 Unported 이중 라이선스로 배포되며, 사용자가 둘 중 하나를 선택합니다. **이 개작본은 CC BY-SA 3.0 Unported를 채택함을 명시합니다.**

- 저작자 표시: The EasyList authors (https://easylist.to/)
- 라이선스 전문: <https://creativecommons.org/licenses/by-sa/3.0/legalcode>
- 원저작자는 이 개작본을 보증하지 **않습니다**.

각 규칙 파일 옆의 `.NOTICE.txt`에는 상위 원본 파일 머리말의 저작권 고지(Title / Version / Last modified / Commit / Homepage / Licence)가 한 글자도 빠짐없이 그대로 보존되어 있습니다. content blocker JSON은 주석 문법이 없는 벌거벗은 최상위 배열이라 파일 안에 다시 써 넣을 수 없기 때문입니다. 그 NOTICE에는 매번 변환할 때 근거로 삼은 상위 원본의 버전과 commit도 기록되어 있어, 버전별로 감사할 수 있습니다.

**라이선스의 적용 범위는 `rules/` 디렉터리에 한정됩니다.** 이 사이트의 나머지 내용(개인정보 처리방침 등)은 저작권을 유보합니다.

## 무결성 검증

규칙 파일은 Ed25519로 서명되어 있으며(`.sig`는 base64로 인코딩한 64바이트 raw 서명입니다), Vigatamala 앱에는 그에 대응하는 공개 키가 내장되어 있어, 미러 출처는 서명 검증을 통과해야만 채택됩니다.

## 재현하는 방법

`rules/converter/`는 독립적으로 빌드할 수 있는 변환기입니다(앱 안에서 쓰는 것과 같은 소스 코드이며, 같은 입력에 대해 바이트 단위로 동일한 출력을 냅니다).

```bash
cd rules/converter
swift build -c release
.build/release/RuleConverter <입력.txt> <출력.json> 65000
```

이 repo의 규칙은 GitHub Actions가 매일 자동으로 동기화하며(`.github/workflows/` 참조), 바로 이 변환기를 사용합니다.
