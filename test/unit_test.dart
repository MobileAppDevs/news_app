import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/repository/user_data_repository.dart';

void main() {
  test("unit test", () {
    UserDataRepository userDataRepository = UserDataRepository();

    String result = userDataRepository.getApiUrl();

    expect(result, 'https://api.github.com/users');
  });
}
