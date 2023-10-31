class User {
  String? username;
  String? password;
  String? driverId;
  String? csrfToken;
  String? sessionId;
  Map<String, String>? header;

  User(); // Constructor with no arguments

  void setCredentials({
    String? username,
    String? password,
    String? driverId,
    Map<String, String>? cookie,
    String? csrfToken,
    String? sessionId,
  }) {
    this.username = username;
    this.password = password;
    this.driverId = driverId;
    this.header = header;
    this.csrfToken = csrfToken;
    this.sessionId = sessionId;
  }
}
