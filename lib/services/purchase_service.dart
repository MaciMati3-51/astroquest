import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'storage_service.dart';

/// RevenueCatダッシュボードで定義するEntitlement識別子。
const String kProEntitlementId = 'pro';

/// 購入の結果。UI側でメッセージを出し分けるために使う。
enum PurchaseOutcome { success, cancelled, failed }

/// RevenueCatによるサブスクリプション課金。
///
/// APIキーは `--dart-define-from-file=.env` 経由でビルド時に注入する。
/// キーが未設定、または初期化に失敗した場合は [isLive] が false になり、
/// Paywallはローカルスタブ（タップでisProをON）にフォールバックする。
/// これは開発中や審査前でもアプリ全体が動く状態を保つため。
class PurchaseService {
  PurchaseService._(this._storage);

  final StorageService _storage;
  static PurchaseService? _instance;
  static PurchaseService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('PurchaseService.init() を先に呼ぶこと');
    }
    return i;
  }

  static const String _apiKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  bool _live = false;

  /// RevenueCat SDKが実際に構成できているか。falseならスタブ動作。
  bool get isLive => _live;

  /// Pro権限の有無。RevenueCatのEntitlementを正とし、端末側にキャッシュしている。
  /// 起動直後やオフライン時はキャッシュ値が返る。
  bool get isPro => _storage.isPro;

  /// Pro状態が変わったときにUIへ通知する。
  final ValueNotifier<bool> proChanged = ValueNotifier<bool>(false);

  static Future<PurchaseService> init(StorageService storage) async {
    final existing = _instance;
    if (existing != null) return existing;
    final service = PurchaseService._(storage);
    await service._configure();
    _instance = service;
    return service;
  }

  Future<void> _configure() async {
    if (_apiKey.isEmpty) {
      debugPrint(
        '[RevenueCat] APIキー未設定のためスタブモードで動作する。'
        ' 実課金を使うには --dart-define-from-file=.env を付けてビルドすること。',
      );
      return;
    }
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      Purchases.addCustomerInfoUpdateListener(_applyCustomerInfo);
      _live = true;
      // 起動時に現在の権限状態をサーバーと突き合わせる。
      // 解約・返金・機種変更後の復元がここで反映される。
      _applyCustomerInfo(await Purchases.getCustomerInfo());
      debugPrint('[RevenueCat] 初期化完了');
    } catch (e) {
      // キーが無効・ネットワーク不通などでもアプリは起動させる。
      debugPrint('[RevenueCat] 初期化失敗のためスタブモードにフォールバック: $e');
      _live = false;
    }
  }

  /// CustomerInfoのEntitlementを端末キャッシュへ書き戻す。
  void _applyCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.active[kProEntitlementId]?.isActive ?? false;
    if (active == _storage.isPro) return;
    _storage.setIsPro(active);
    proChanged.value = !proChanged.value;
    debugPrint('[RevenueCat] Pro権限を更新: $active');
  }

  /// 現在のOfferingを取得する。未構成・商品未設定ならnull。
  Future<Offering?> fetchCurrentOffering() async {
    if (!_live) return null;
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        debugPrint('[RevenueCat] 有効なOfferingが無い（商品未設定の可能性）');
        return null;
      }
      return current;
    } catch (e) {
      debugPrint('[RevenueCat] Offering取得失敗: $e');
      return null;
    }
  }

  /// パッケージを購入する。
  /// [package] がnull（スタブ表示でPackage実体が無い）場合もスタブ経路に落ちる。
  Future<PurchaseOutcome> purchase(Package? package) async {
    if (!_live || package == null) return _stubPurchase();
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _applyCustomerInfo(result.customerInfo);
      final active =
          result.customerInfo.entitlements.active[kProEntitlementId]?.isActive ??
              false;
      return active ? PurchaseOutcome.success : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      // ユーザーが購入ダイアログを閉じた場合はエラー扱いしない。
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseOutcome.cancelled;
      }
      debugPrint('[RevenueCat] 購入失敗: $e');
      return PurchaseOutcome.failed;
    } catch (e) {
      debugPrint('[RevenueCat] 購入失敗: $e');
      return PurchaseOutcome.failed;
    }
  }

  /// 購入を復元する。機種変更・再インストール時に必要（ストア審査の必須要件）。
  Future<PurchaseOutcome> restore() async {
    if (!_live) return _stubPurchase();
    try {
      final info = await Purchases.restorePurchases();
      _applyCustomerInfo(info);
      final active =
          info.entitlements.active[kProEntitlementId]?.isActive ?? false;
      return active ? PurchaseOutcome.success : PurchaseOutcome.failed;
    } catch (e) {
      debugPrint('[RevenueCat] 復元失敗: $e');
      return PurchaseOutcome.failed;
    }
  }

  /// スタブ動作：決済を経ずにisProをONにする。
  Future<PurchaseOutcome> _stubPurchase() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await _storage.setIsPro(true);
    proChanged.value = !proChanged.value;
    return PurchaseOutcome.success;
  }
}
