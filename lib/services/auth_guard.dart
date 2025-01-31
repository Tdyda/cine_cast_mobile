class AuthGuard extends AutoRouteGuard {
  final AuthProvider authProvider;

  AuthGuard(this.authProvider);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (authProvider.isLoggedIn) {
      resolver.next();
    } else {
      resolver.redirect(const LoginRoute());
    }
  }
}