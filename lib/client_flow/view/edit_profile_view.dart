// lib/client_flow/view/edit_profile_view.dart

import 'package:flutter/material.dart';
import '../controller/edit_profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _controller = EditProfileController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = _controller.userProfile.value;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // Navega para a tela principal e abre a aba de configurações (índice 3)
                        Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false,
                            arguments: 3);
                      },
                    ),
                  ),
                  Text(
                    'Editar Perfil',
                    style: GoogleFonts.abyssinicaSil(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  clipBehavior: Clip.none, // Permite que o ícone saia dos limites do Stack
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: Adicionar lógica para alterar a imagem de perfil aqui
                      },
                      child: CircleAvatar( // Círculo externo para a borda
                        radius: 62,
                        backgroundColor: Colors.grey.shade300,
                        child: CircleAvatar( // Círculo interno para a imagem
                          radius: 60,
                          backgroundImage: NetworkImage(_controller.userProfile.value.profileImageUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 0,
                      right: 0,
                      child: Icon(Icons.camera_alt_outlined, color:  Color(0xFF844333), size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF844333), width: 1.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF844333), width: 2.0),
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF844333), width: 1.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF844333), width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF844333), width: 1.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF844333), width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF844333),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Atualiza os dados no controller antes de salvar
                    _controller.userProfile.value.name = _nameController.text;
                    _controller.userProfile.value.email = _emailController.text;
                    _controller.userProfile.value.phone = _phoneController.text;
                    _controller.saveProfile(context);
                  }
                },
                child: Text(
                  'Salvar Alterações',
                  style: GoogleFonts.abyssinicaSil(fontSize: 18, color: Colors.white),
                ), 
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}