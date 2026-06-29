class TokenManager {
  static final TokenManager instance = TokenManager._internal();
  
  factory TokenManager() {
    return instance;
  }
  
  TokenManager._internal();

  String token = '';
  String refreshToken = '';
}
