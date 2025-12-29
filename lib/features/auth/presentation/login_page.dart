import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_vm.dart';
import '../../transactions/state/transactions_vm.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // FakeStoreAPI demo account
  final _usernameCtrl = TextEditingController(text: 'mor_2314');
  final _passwordCtrl = TextEditingController(text: '83r5^_');

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final authVm = context.read<AuthVm>();
    await authVm.login(_usernameCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (authVm.status == AuthStatus.authenticated) {
      // auto sync transactions (không chặn UI)
      context.read<TransactionsVm>().syncNow();
    }
  }

  void _openRegisterSheet() {
    final usernameCtrl = TextEditingController(text: 'demo_user_${DateTime.now().millisecondsSinceEpoch % 10000}');
    final passCtrl = TextEditingController(text: 'demo123');

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          title: const Text('Tạo tài khoản (Demo)'),
          message: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: usernameCtrl,
                    placeholder: 'Username',
                    autocorrect: false,
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: passCtrl,
                    placeholder: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Demo API: FakeStoreAPI\n'
                    'Login mẫu: mor_2314 / 83r5^_\n'
                    'Register sẽ tạo user và tự login.',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                final authVm = context.read<AuthVm>();

                await authVm.register(
                  usernameCtrl.text.trim(),
                  passCtrl.text,
                );

                if (!mounted) return;

                Navigator.of(context).pop();

                if (authVm.status == AuthStatus.authenticated) {
                  context.read<TransactionsVm>().syncNow();
                }
              },
              child: const Text('Tạo tài khoản'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
        );
      },
    ).whenComplete(() {
      usernameCtrl.dispose();
      passCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthVm>();
    final loading = vm.status == AuthStatus.loading;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('MoneyTrack Login'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoTextField(
              controller: _usernameCtrl,
              placeholder: 'Username',
              autocorrect: false,
              enabled: !loading,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _passwordCtrl,
              placeholder: 'Password',
              obscureText: true,
              enabled: !loading,
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: loading ? null : _doLogin,
              child: loading
                  ? const CupertinoActivityIndicator()
                  : const Text('Đăng nhập'),
            ),
            const SizedBox(height: 10),
            CupertinoButton(
              onPressed: loading ? null : _openRegisterSheet,
              child: const Text('Tạo tài khoản'),
            ),
            if (vm.status == AuthStatus.error &&
                (vm.errorMessage?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              Text(
                vm.errorMessage!,
                style: const TextStyle(color: CupertinoColors.systemRed),
              ),
            ],
            const SizedBox(height: 22),
            const Text(
              'Demo FakeStoreAPI:\n'
              '- Login: mor_2314 / 83r5^_\n'
              '- Register: tạo username/password bất kỳ (demo)\n\n'
              'Sau khi login/register, app sẽ tự sync transactions.',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
