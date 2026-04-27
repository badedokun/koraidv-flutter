/// wallet_models.dart
/// KoraIDV Wallet — W3C Verifiable Credential types for Flutter/Dart
///
/// Types are prefixed with "Wallet" to avoid conflicts with existing KoraIDV types.

library;

// MARK: - Verifiable Credential

class WalletCredential {
  final List<String> context;
  final String id;
  final List<String> type;
  final String issuer;
  final String issuanceDate;
  final String expirationDate;
  final WalletCredentialSubject credentialSubject;
  final WalletCredentialStatus? credentialStatus;
  final WalletDataIntegrityProof? proof;

  const WalletCredential({
    this.context = const ['https://www.w3.org/ns/credentials/v2'],
    required this.id,
    this.type = const ['VerifiableCredential', 'KoraIdentityCredential'],
    required this.issuer,
    required this.issuanceDate,
    required this.expirationDate,
    required this.credentialSubject,
    this.credentialStatus,
    this.proof,
  });

  Map<String, dynamic> toJson() => {
        '@context': context,
        'id': id,
        'type': type,
        'issuer': issuer,
        'issuanceDate': issuanceDate,
        'expirationDate': expirationDate,
        'credentialSubject': credentialSubject.toJson(),
        if (credentialStatus != null)
          'credentialStatus': credentialStatus!.toJson(),
        if (proof != null) 'proof': proof!.toJson(),
      };

  factory WalletCredential.fromJson(Map<String, dynamic> json) {
    return WalletCredential(
      context: List<String>.from(json['@context'] ?? []),
      id: json['id'] as String,
      type: List<String>.from(json['type'] ?? []),
      issuer: json['issuer'] as String,
      issuanceDate: json['issuanceDate'] as String,
      expirationDate: json['expirationDate'] as String,
      credentialSubject: WalletCredentialSubject.fromJson(
          json['credentialSubject'] as Map<String, dynamic>),
      credentialStatus: json['credentialStatus'] != null
          ? WalletCredentialStatus.fromJson(
              json['credentialStatus'] as Map<String, dynamic>)
          : null,
      proof: json['proof'] != null
          ? WalletDataIntegrityProof.fromJson(
              json['proof'] as Map<String, dynamic>)
          : null,
    );
  }

  WalletCredential copyWith({
    WalletCredentialSubject? credentialSubject,
  }) {
    return WalletCredential(
      context: context,
      id: id,
      type: type,
      issuer: issuer,
      issuanceDate: issuanceDate,
      expirationDate: expirationDate,
      credentialSubject: credentialSubject ?? this.credentialSubject,
      credentialStatus: credentialStatus,
      proof: proof,
    );
  }
}

// MARK: - Credential Subject

class WalletCredentialSubject {
  final String id;
  final String fullName;
  final String? dateOfBirth;
  final String? nationality;
  final String verificationLevel;
  final String documentType;
  final String documentCountry;
  final bool biometricMatch;
  final bool livenessCheck;
  final bool governmentDbVerified;
  final String verifiedAt;
  final double confidenceScore;

  const WalletCredentialSubject({
    required this.id,
    required this.fullName,
    this.dateOfBirth,
    this.nationality,
    required this.verificationLevel,
    required this.documentType,
    required this.documentCountry,
    required this.biometricMatch,
    required this.livenessCheck,
    required this.governmentDbVerified,
    required this.verifiedAt,
    required this.confidenceScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (nationality != null) 'nationality': nationality,
        'verificationLevel': verificationLevel,
        'documentType': documentType,
        'documentCountry': documentCountry,
        'biometricMatch': biometricMatch,
        'livenessCheck': livenessCheck,
        'governmentDbVerified': governmentDbVerified,
        'verifiedAt': verifiedAt,
        'confidenceScore': confidenceScore,
      };

  factory WalletCredentialSubject.fromJson(Map<String, dynamic> json) {
    return WalletCredentialSubject(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      nationality: json['nationality'] as String?,
      verificationLevel: json['verificationLevel'] as String,
      documentType: json['documentType'] as String,
      documentCountry: json['documentCountry'] as String,
      biometricMatch: json['biometricMatch'] as bool,
      livenessCheck: json['livenessCheck'] as bool,
      governmentDbVerified: json['governmentDbVerified'] as bool,
      verifiedAt: json['verifiedAt'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
    );
  }
}

// MARK: - Credential Status (StatusList2021)

class WalletCredentialStatus {
  final String id;
  final String type;
  final String statusPurpose;
  final String statusListIndex;
  final String statusListCredential;

  const WalletCredentialStatus({
    required this.id,
    this.type = 'StatusList2021Entry',
    this.statusPurpose = 'revocation',
    required this.statusListIndex,
    required this.statusListCredential,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'statusPurpose': statusPurpose,
        'statusListIndex': statusListIndex,
        'statusListCredential': statusListCredential,
      };

  factory WalletCredentialStatus.fromJson(Map<String, dynamic> json) {
    return WalletCredentialStatus(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'StatusList2021Entry',
      statusPurpose: json['statusPurpose'] as String? ?? 'revocation',
      statusListIndex: json['statusListIndex'] as String,
      statusListCredential: json['statusListCredential'] as String,
    );
  }
}

// MARK: - Data Integrity Proof

class WalletDataIntegrityProof {
  final String type;
  final String cryptosuite;
  final String created;
  final String verificationMethod;
  final String proofPurpose;
  final String proofValue;

  const WalletDataIntegrityProof({
    this.type = 'DataIntegrityProof',
    this.cryptosuite = 'eddsa-rdfc-2022',
    required this.created,
    required this.verificationMethod,
    this.proofPurpose = 'assertionMethod',
    required this.proofValue,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'cryptosuite': cryptosuite,
        'created': created,
        'verificationMethod': verificationMethod,
        'proofPurpose': proofPurpose,
        'proofValue': proofValue,
      };

  factory WalletDataIntegrityProof.fromJson(Map<String, dynamic> json) {
    return WalletDataIntegrityProof(
      type: json['type'] as String? ?? 'DataIntegrityProof',
      cryptosuite: json['cryptosuite'] as String? ?? 'eddsa-rdfc-2022',
      created: json['created'] as String,
      verificationMethod: json['verificationMethod'] as String,
      proofPurpose: json['proofPurpose'] as String? ?? 'assertionMethod',
      proofValue: json['proofValue'] as String,
    );
  }
}

// MARK: - Stored Credential (wrapper with metadata)

class StoredWalletCredential {
  final String id;
  final WalletCredential credential;
  final String storedAt;
  final String issuerDID;
  final String subjectName;
  final String expiresAt;

  const StoredWalletCredential({
    required this.id,
    required this.credential,
    required this.storedAt,
    required this.issuerDID,
    required this.subjectName,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'credential': credential.toJson(),
        'storedAt': storedAt,
        'issuerDID': issuerDID,
        'subjectName': subjectName,
        'expiresAt': expiresAt,
      };

  factory StoredWalletCredential.fromJson(Map<String, dynamic> json) {
    return StoredWalletCredential(
      id: json['id'] as String,
      credential:
          WalletCredential.fromJson(json['credential'] as Map<String, dynamic>),
      storedAt: json['storedAt'] as String,
      issuerDID: json['issuerDID'] as String,
      subjectName: json['subjectName'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }
}

// MARK: - Verifiable Presentation

class WalletPresentation {
  final List<String> context;
  final List<String> type;
  final String? holder;
  final List<WalletCredential> verifiableCredential;
  final String created;
  final String? audience;
  final String? challenge;

  const WalletPresentation({
    this.context = const ['https://www.w3.org/ns/credentials/v2'],
    this.type = const ['VerifiablePresentation'],
    this.holder,
    required this.verifiableCredential,
    required this.created,
    this.audience,
    this.challenge,
  });

  Map<String, dynamic> toJson() => {
        '@context': context,
        'type': type,
        if (holder != null) 'holder': holder,
        'verifiableCredential':
            verifiableCredential.map((vc) => vc.toJson()).toList(),
        'created': created,
        if (audience != null) 'audience': audience,
        if (challenge != null) 'challenge': challenge,
      };

  factory WalletPresentation.fromJson(Map<String, dynamic> json) {
    return WalletPresentation(
      context: List<String>.from(json['@context'] ?? []),
      type: List<String>.from(json['type'] ?? []),
      holder: json['holder'] as String?,
      verifiableCredential: (json['verifiableCredential'] as List)
          .map((vc) => WalletCredential.fromJson(vc as Map<String, dynamic>))
          .toList(),
      created: json['created'] as String,
      audience: json['audience'] as String?,
      challenge: json['challenge'] as String?,
    );
  }
}

// MARK: - Errors

class WalletException implements Exception {
  final String code;
  final String message;

  const WalletException(this.code, this.message);

  static const storageFailed =
      WalletException('STORAGE_FAILED', 'Failed to store credential.');
  static const credentialNotFound =
      WalletException('CREDENTIAL_NOT_FOUND', 'Credential not found.');
  static const credentialExpired =
      WalletException('CREDENTIAL_EXPIRED', 'Credential has expired.');
  static const encodingFailed =
      WalletException('ENCODING_FAILED', 'Failed to encode credential data.');

  @override
  String toString() => 'WalletException($code): $message';
}
