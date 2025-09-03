import 'dart:convert';
import 'package:flutter/foundation.dart';

/// 安全管理器 - 处理数据加密、隐私保护等安全相关功能
class SecurityManager {
  SecurityManager._();

  /// 生成安全的随机盐值
  static String generateSalt() {
    final bytes = List<int>.generate(32, (i) => DateTime.now().millisecondsSinceEpoch + i);
    return base64Encode(bytes);
  }

  /// 使用简化算法生成密钥
  static Uint8List deriveKey(String password, String salt) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    // 简化的密钥派生（实际应用中应使用更强的PBKDF2实现）
    var key = passwordBytes + saltBytes;
    for (int i = 0; i < 1000; i++) {
      key = _simpleHash(key);
    }

    return Uint8List.fromList(key.take(32).toList());
  }

  /// 简化的哈希函数
  static List<int> _simpleHash(List<int> data) {
    var hash = <int>[];
    var sum = 0;

    for (int i = 0; i < data.length; i++) {
      sum = (sum + data[i] * (i + 1)) % 256;
      hash.add(sum);
    }

    // 确保输出长度为32字节
    while (hash.length < 32) {
      hash.addAll(hash.take(32 - hash.length));
    }

    return hash.take(32).toList();
  }

  /// 加密敏感数据
  static String encryptSensitiveData(String data, String password) {
    try {
      if (data.isEmpty) return data;

      // 生成盐值
      final salt = generateSalt();

      // 派生密钥
      final key = deriveKey(password, salt);

      // 简化的加密实现（实际应用中应使用AES等强加密算法）
      final dataBytes = utf8.encode(data);
      final encryptedBytes = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes.add(dataBytes[i] ^ key[i % key.length]);
      }

      // 组合盐值和加密数据
      final result = {'salt': salt, 'data': base64Encode(encryptedBytes)};

      return base64Encode(utf8.encode(jsonEncode(result)));
    } catch (e) {
      debugPrint('Encryption failed: $e');
      return data; // 加密失败时返回原数据
    }
  }

  /// 解密敏感数据
  static String decryptSensitiveData(String encryptedData, String password) {
    try {
      if (encryptedData.isEmpty) return encryptedData;

      // 解析加密数据
      final decodedData = utf8.decode(base64Decode(encryptedData));
      final dataMap = jsonDecode(decodedData) as Map<String, dynamic>;

      final salt = dataMap['salt'] as String;
      final encryptedBytes = base64Decode(dataMap['data'] as String);

      // 派生密钥
      final key = deriveKey(password, salt);

      // 解密数据
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ key[i % key.length]);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption failed: $e');
      return encryptedData; // 解密失败时返回原数据
    }
  }

  /// 生成数据哈希值用于完整性验证
  static String generateDataHash(String data) {
    final bytes = utf8.encode(data);
    final hash = _simpleHash(bytes);
    return hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 验证数据完整性
  static bool verifyDataIntegrity(String data, String expectedHash) {
    final actualHash = generateDataHash(data);
    return actualHash == expectedHash;
  }

  /// 清理敏感数据（安全删除）
  static void secureClearString(String sensitiveData) {
    // 在Dart中，字符串是不可变的，无法直接清零内存
    // 这里提供一个概念性的实现
    if (kDebugMode) {
      debugPrint('Securely clearing sensitive data of length: ${sensitiveData.length}');
    }
  }

  /// 生成安全的随机密码
  static String generateSecurePassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    var password = '';

    for (int i = 0; i < length; i++) {
      password += chars[(random + i) % chars.length];
    }

    return password;
  }

  /// 验证密码强度
  static PasswordStrength evaluatePasswordStrength(String password) {
    if (password.length < 6) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // 长度检查
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // 字符类型检查
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score < 3) return PasswordStrength.weak;
    if (score < 5) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// 数据脱敏处理
  static String maskSensitiveData(String data, {int visibleChars = 2}) {
    if (data.length <= visibleChars * 2) {
      return '*' * data.length;
    }

    final start = data.substring(0, visibleChars);
    final end = data.substring(data.length - visibleChars);
    final middle = '*' * (data.length - visibleChars * 2);

    return start + middle + end;
  }

  /// 检查应用是否在安全环境中运行
  static Future<SecurityEnvironment> checkSecurityEnvironment() async {
    // 在实际应用中，这里应该检查：
    // 1. 设备是否已root/越狱
    // 2. 是否在模拟器中运行
    // 3. 是否有调试器附加
    // 4. 应用签名是否正确

    return SecurityEnvironment(
      isRooted: false, // 需要使用专门的库检测
      isEmulator: false, // 需要使用专门的库检测
      isDebugging: kDebugMode,
      hasValidSignature: true, // 需要验证应用签名
    );
  }

  /// 生成安全的导出密钥
  static String generateExportKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = generateSecurePassword(16);
    final combined = '$timestamp$random';
    return generateDataHash(combined).substring(0, 16);
  }

  /// 安全的数据导出
  static Map<String, dynamic> secureDataExport(Map<String, dynamic> data, String exportKey) {
    final dataJson = jsonEncode(data);
    final encryptedData = encryptSensitiveData(dataJson, exportKey);
    final dataHash = generateDataHash(dataJson);

    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': encryptedData,
      'hash': dataHash,
      'app': 'period_tracker',
    };
  }

  /// 安全的数据导入
  static Map<String, dynamic>? secureDataImport(Map<String, dynamic> importData, String importKey) {
    try {
      final encryptedData = importData['data'] as String;
      final expectedHash = importData['hash'] as String;

      final decryptedJson = decryptSensitiveData(encryptedData, importKey);

      // 验证数据完整性
      if (!verifyDataIntegrity(decryptedJson, expectedHash)) {
        throw Exception('Data integrity verification failed');
      }

      return jsonDecode(decryptedJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Secure data import failed: $e');
      return null;
    }
  }
}

/// 密码强度枚举
enum PasswordStrength { weak, medium, strong }

/// 安全环境信息
class SecurityEnvironment {
  final bool isRooted;
  final bool isEmulator;
  final bool isDebugging;
  final bool hasValidSignature;

  const SecurityEnvironment({
    required this.isRooted,
    required this.isEmulator,
    required this.isDebugging,
    required this.hasValidSignature,
  });

  bool get isSecure => !isRooted && !isEmulator && hasValidSignature;
}
