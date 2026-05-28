import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe/core/constants/app_colors.dart';

const _screenBg = Color(0xFF111022);
const _panelBg = Color(0xFF1A182C);
const _fieldBg = Color(0xFF17172C);
const _cardBorder = Color(0xFF343049);
const _softText = Color(0xFFC9C1D2);
const _mutedLavender = Color(0xFF8E839C);

class LoginScreen extends StatefulWidget {
  final bool firebaseReady;
  final VoidCallback onDemoAccess;
  final VoidCallback? onAuthenticated;

  const LoginScreen({
    super.key,
    this.firebaseReady = true,
    required this.onDemoAccess,
    this.onAuthenticated,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCreatingAccount = false;
  bool _isLoading = false;
  Future<void>? _googleInitialize;
  bool _obscurePassword = true;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isCreatingAccount) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      }
      widget.onAuthenticated?.call();
    } on FirebaseAuthException catch (error) {
      setState(() {
        _message = _authMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Digite seu e-mail para recuperar a senha.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _message = 'Enviamos um link de recuperação para o seu e-mail.';
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _message = _authMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleAccountMode() {
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _message = null;
    });
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitialize ??= GoogleSignIn.instance.initialize();
  }

  Future<void> _signInWithGoogle() async {
    if (!widget.firebaseReady) {
      setState(() {
        _message = 'Firebase não foi inicializado neste dispositivo.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _ensureGoogleInitialized();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google não retornou um token de autenticação.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      widget.onAuthenticated?.call();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        setState(() {
          _message = 'Login com Google cancelado.';
        });
      } else {
        setState(() {
          _message =
              'Não foi possível entrar com Google. Confira o SHA-1 no Firebase.';
        });
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _message = _authMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Login com $provider em breve.')));
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este e-mail já tem uma conta.';
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'operation-not-allowed':
        return 'Ative login por e-mail/senha no Firebase Authentication.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'weak-password':
        return 'Use uma senha com pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com o Firebase. Verifique sua internet.';
      case 'missing-google-id-token':
        return 'Configure o login Google no Firebase e baixe o google-services.json atualizado.';
      case 'account-exists-with-different-credential':
        return 'Este e-mail já existe com outro método de login.';
      default:
        return 'Não foi possível entrar agora. Tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: _screenBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SafeWordmark(),
                    const SizedBox(height: 14),
                    const Text(
                      'Bem-vindo de volta. Sua segurança\ncomeça com sua consciência.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _softText,
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _LoginCard(
                      isCreatingAccount: _isCreatingAccount,
                      isLoading: _isLoading,
                      firebaseReady: widget.firebaseReady,
                      message: _message,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onResetPassword: widget.firebaseReady
                          ? _resetPassword
                          : null,
                      onSubmit: _submit,
                      onToggleAccountMode: _toggleAccountMode,
                    ),
                    const SizedBox(height: 34),
                    const _DividerLabel(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            onPressed: () {
                              _signInWithGoogle();
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SocialButton(
                            prefix: 'iOS',
                            icon: Icons.apple_rounded,
                            label: 'Apple',
                            onPressed: () => _showComingSoon('Apple'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Safe: Monitoramento preventivo e\neducação para um trânsito mais\nhumano.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _mutedLavender,
                        fontSize: 13,
                        height: 1.25,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!widget.firebaseReady) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading ? null : widget.onDemoAccess,
                        child: const Text(
                          'Entrar sem conta',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final bool isCreatingAccount;
  final bool isLoading;
  final bool firebaseReady;
  final String? message;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback? onResetPassword;
  final VoidCallback onSubmit;
  final VoidCallback onToggleAccountMode;

  const _LoginCard({
    required this.isCreatingAccount,
    required this.isLoading,
    required this.firebaseReady,
    required this.message,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onResetPassword,
    required this.onSubmit,
    required this.onToggleAccountMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!firebaseReady) ...[
            const _StatusBanner(
              text:
                  'Firebase não foi inicializado. Use o modo demonstração ou confira as configurações.',
            ),
            const SizedBox(height: 16),
          ],
          if (message != null) ...[
            _StatusBanner(text: message!),
            const SizedBox(height: 16),
          ],
          const _AuthLabel('E-mail'),
          const SizedBox(height: 8),
          _EmailField(controller: emailController),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _AuthLabel('Senha'),
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onResetPassword,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Esqueci minha senha',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFBBA7FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _PasswordField(
            controller: passwordController,
            obscureText: obscurePassword,
            onToggle: onTogglePassword,
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            enabled: firebaseReady,
            isLoading: isLoading,
            label: isCreatingAccount ? 'Criar conta' : 'Entrar',
            onPressed: onSubmit,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: isLoading ? null : onToggleAccountMode,
            child: Text.rich(
              TextSpan(
                text: isCreatingAccount
                    ? 'Já tem uma conta? '
                    : 'Não tem uma conta? ',
                children: [
                  TextSpan(
                    text: isCreatingAccount ? 'Entrar' : 'Criar conta',
                    style: const TextStyle(
                      color: _softText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                color: _softText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeWordmark extends StatelessWidget {
  const _SafeWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'SAFE',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.accent,
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _AuthLabel extends StatelessWidget {
  final String text;

  const _AuthLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _softText,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _fieldDecoration(
        hintText: 'nome@exemplo.com',
        prefixIcon: Icons.mail_outline_rounded,
      ),
      validator: (value) {
        final email = value?.trim() ?? '';
        if (email.isEmpty) return 'Digite seu e-mail.';
        if (!email.contains('@')) return 'Digite um e-mail válido.';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _fieldDecoration(
        hintText: '••••••••',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          tooltip: obscureText ? 'Mostrar senha' : 'Ocultar senha',
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _softText,
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if ((value ?? '').length < 6) {
          return 'Use pelo menos 6 caracteres.';
        }
        return null;
      },
    );
  }
}

InputDecoration _fieldDecoration({
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF706B7D),
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(prefixIcon, color: _softText, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _fieldBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFF24213A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFF24213A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.red),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.enabled,
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          foregroundColor: _screenBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          elevation: 8,
          shadowColor: AppColors.accent.withValues(alpha: 0.32),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _screenBg,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: _cardBorder, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU CONTINUE COM',
            style: TextStyle(
              color: _mutedLavender,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(child: Divider(color: _cardBorder, thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String? prefix;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: _cardBorder),
        backgroundColor: _panelBg,
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) ...[
            Text(
              prefix!,
              style: const TextStyle(
                color: _softText,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String text;

  const _StatusBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purpleBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(color: _softText, fontSize: 12, height: 1.35),
      ),
    );
  }
}
