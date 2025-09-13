import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_fan/domain/enums/logout_reason.dart';

abstract class AuthEvents extends DomainEvent {}

sealed class AuthChecked extends AuthEvents {}

class AuthCheckFailed extends AuthChecked {}

class AuthCheckSuccessful extends AuthChecked {
  AuthCheckSuccessful();
}

class UserLoggedIn extends AuthEvents {
  final String password;
  final String accountId;

  UserLoggedIn({
    required this.password,
    required this.accountId,
  });
}

class UserLoggedOut extends AuthEvents {
  final LogoutReason reason;

  UserLoggedOut({required this.reason});
}
