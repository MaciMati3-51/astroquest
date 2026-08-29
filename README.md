# AstroQuest

占星術 × 超軽運動のゲーミフィケーションアプリ。
デスクワーカー・ゲーマー向けに、その日の「星の属性」に合わせた1〜2分のミッションを提示し、
達成でタリスマンカードを獲得・Streakを積み上げる。

RevenueCat Shipaton 提出用プロジェクト。

## 特徴

- **Cosmic Status** — 生年月日から太陽星座を判定し、4エレメント（Fire / Earth / Air / Water）にマッピング
- **Buff Mission** — エレメント × 日付シードで決定的に選ばれる1日1ミッション（Desk Stretch / Hydration / Grounding）
- **Talisman Collection** — 達成ごとにタリスマンカードを抽選・解放
- **Streak** — 連続達成日数のカウントと履歴
- **Pro プラン** — 限定タリスマン4種 + Streak全履歴（RevenueCatによるサブスクリプション課金）

## 技術スタック

| 項目 | 内容 |
|---|---|
| フレームワーク | Flutter 3.24.5 |
| 対象プラットフォーム | Android |
| 課金 | RevenueCat (`purchases_flutter`) |
| ローカル保存 | `shared_preferences`（サーバー・認証なし） |
| 通知 | `flutter_local_notifications`（毎日9:00のローカル通知） |

占星術の判定は太陽星座のみを使用する。出生時間・出生地は取得しない。
ミッション文言はローカルの定型文プールから決定的に選択される（LLM API 不使用）。

## セットアップ

```bash
flutter pub get
cp .env.example .env   # RevenueCat の Android 公開APIキーを記入
flutter run --dart-define-from-file=.env
```

`.env` は `.gitignore` 済み。APIキーをコードにハードコードしないこと。

キー未設定でもアプリは起動し、Paywall はローカルスタブ動作にフォールバックする。

## ビルド

```bash
flutter build apk --debug   --dart-define-from-file=.env
flutter build apk --release --dart-define-from-file=.env
```

## ディレクトリ構成

```
lib/
├── main.dart
├── models/       # cosmic_element, zodiac, quest
├── data/         # content_pool, talisman_pool
├── services/     # storage_service, notification_service, purchase_service
├── screens/      # onboarding, paywall, home, quest_timer, talisman_reveal, collection
├── theme/        # app_theme
└── widgets/      # gradient_card
```

## 既知の環境上の注意

OpenJDK 21 と Android SDK の組み合わせでは jlink 変換が
`ModuleTarget is malformed: platformString missing delimiter: android` で失敗する。
JDK 17 を使うこと。

```bash
flutter config --jdk-dir=/usr/lib/jvm/java-17-openjdk-amd64
```
