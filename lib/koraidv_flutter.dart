/// Kora IDV Flutter SDK
///
/// Thin wrapper over the native iOS and Android KoraIDV SDKs
/// via platform channels (MethodChannel).
library koraidv_flutter;

export 'src/types.dart';
export 'src/kora_exception.dart';
export 'src/koraidv.dart';
export 'src/koraidv_platform_interface.dart';
export 'src/widgets/koraidv_provider.dart';
export 'src/widgets/koraidv_controller.dart';
export 'src/widgets/verification_flow.dart';

// Wallet — W3C Verifiable Credentials
export 'src/wallet/kora_wallet.dart';
export 'src/wallet/wallet_models.dart';
export 'src/wallet/selective_disclosure.dart';
