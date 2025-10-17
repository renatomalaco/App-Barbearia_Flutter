import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  final String userType;

  const LoginView({super.key, required this.userType});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Adiciona um botão de "voltar" que retorna para a tela anterior (Welcome)
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
                Image.asset(
                  'lib/images/logo.png', 
                  height: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bem vindo de volta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 48),
                // RF001: Campo para informar o e-mail.
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // RF001: Verifica se o campo não está vazio.
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    // RF001: Verifica se o e-mail é válido (validação simples).
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // RF001: Campo para informar a senha.
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured, // Oculta o texto da senha
                  decoration: InputDecoration(
                    labelText: 'Sua senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // Altera o estado para mostrar/ocultar a senha.
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    // RF001: Verifica se o campo não está vazio.
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // RF001: Acesso à funcionalidade "Esqueceu a senha?".
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navega para a tela de recuperação de senha.
                      Navigator.pushNamed(context, 'forgot_password');
                    },
                    child: const Text('Esqueceu sua senha?'),
                  ),
                ),
                const SizedBox(height: 24),

                // RF001: Botão para "entrar" no aplicativo.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF844333), // Cor do Figma
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    // Aciona a validação de todos os TextFormField do formulário.
                    if (_formKey.currentState!.validate()) {
                      // Lógica de navegação baseada no tipo de usuário
                      if (widget.userType == 'barber') {
                        // Navega para o fluxo do barbeiro
                        Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false);
                      } else {
                        // Navega para o fluxo do cliente (ainda a ser criado)
                        // Por enquanto, vamos usar uma rota placeholder que precisa ser criada
                        // TODO: Criar a rota e a tela 'client_home'
                        Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false); // Temporariamente para 'list'
                      }
                    }
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),

                // RF001: Acesso à funcionalidade de Cadastro de Usuário.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?'),
                    TextButton(
                      onPressed: () {
                        // Navega para a tela de cadastro correta
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