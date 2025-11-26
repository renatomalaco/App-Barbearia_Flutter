import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necessário para ler o userType

class LoginView extends StatefulWidget {
  final String userType; // Mantemos, mas agora a lógica real vem do banco

  const LoginView({super.key, required this.userType});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LOGIN E ROTEAMENTO (Atualizada) ---
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Autenticação
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) throw Exception("Erro na autenticação");

      // 2. Verificação do Tipo de Usuário no Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final String role = data['userType'] ?? 'client'; // Padrão é client

        // 3. Redirecionamento baseado na role
        if (role == 'barber') {
          Navigator.pushNamedAndRemoveUntil(context, 'barber_home', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false);
        }
      } else {
        // Caso de borda: Usuário no Auth mas sem doc no Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil de usuário não encontrado.')),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao fazer login.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'E-mail ou senha incorretos.'; // Mensagem de segurança genérica
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // O layout permanece o mesmo que você já tinha, mantendo o botão de "Entrar"
    // conectado à função _login atualizada acima.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Image.asset('lib/images/logo.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  'Bem vindo de volta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty) ? 'Insira seu e-mail.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    labelText: 'Sua senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Insira sua senha.' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, 'forgot_password'),
                    child: const Text('Esqueceu sua senha?'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF844333),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Entrar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?'),
                    TextButton(
                      onPressed: () {
                        // Mantém a lógica visual, mas o registro real define o userType
                        if (widget.userType == 'client') {
                          Navigator.pushNamed(context, 'register');
                        } else {
                          Navigator.pushNamed(context, 'barber_register');
                        }
                      },
                      child: const Text('Registre agora'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}