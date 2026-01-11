class UserService {
  Future<Map<String, dynamic>> getUserInfo() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return simulated user data
    return {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'joinDate': 'January 2023',
    };
  }

  Future<void> updateUserInfo(Map<String, dynamic> updatedData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful update
    // In a real implementation, this would send data to a server
    print('User data updated: $updatedData');

    // Throw an error randomly to simulate occasional failures (for testing)
    if (DateTime.now().second % 5 == 0) {
      // 20% chance of error
      throw Exception('Network error: Failed to update user data');
    }
  }

  // Alias for getUserInfo to match both names
  Future<Map<String, dynamic>> fetchUser() async => getUserInfo();
}
