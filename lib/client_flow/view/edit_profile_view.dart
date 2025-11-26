import 'package:flutter/material.dart';
import '../controller/edit_profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _controller.userProfile.addListener(() {
      if (mounted) {
        _nameController.text = _controller.userProfile.value.name;
        _emailController.text = _controller.userProfile.value.email;
        _phoneController.text = _controller.userProfile.value.phone;
        setState(() {}); 
      }
    });
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
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, 'list', (route) => false, arguments: 3),
                      ),
                    ),
                    Text(
                      'Editar Perfil',
                      style: GoogleFonts.abyssinicaSil(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _controller.pickAndUploadImage,
                        child: ValueListenableBuilder(
                          valueListenable: _controller.isLoading,
                          builder: (context, loading, _) {
                            if (loading) return const CircularProgressIndicator();
                            
                            // LÓGICA INSERIDA AQUI:
                            final path = _controller.userProfile.value.profileImageUrl;
                            ImageProvider imageProvider;

                            if (path.isEmpty) {
                              // Caso 1: Sem imagem -> Usa asset padrão
                              imageProvider = const AssetImage('lib/images/user.png');
                            } else if (path.startsWith('http')) {
                              // Caso 2: URL da Web -> Usa NetworkImage
                              imageProvider = NetworkImage(path);
                            } else {
                              // Caso 3: Caminho Local -> Usa FileImage (Requer dart:io)
                              imageProvider = FileImage(File(path));
                            }
                            
                            return CircleAvatar(
                              radius: 62,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: imageProvider,
                            );
                          },
                        ),
                      ),
                      const Positioned(
                        bottom: -10,
                        right: 0,
                        left: 0,
                        child: Icon(Icons.camera_alt, color: Color(0xFF844333), size: 30),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                  onChanged: (val) => _controller.userProfile.value.name = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                  onChanged: (val) => _controller.userProfile.value.email = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                  onChanged: (val) => _controller.userProfile.value.phone = val,
                ),
                const SizedBox(height: 80),
                
                ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  builder: (context, loading, child) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF844333),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _controller.saveProfile(context);
                              }
                            },
                      child: loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : Text('Salvar Alterações', style: GoogleFonts.abyssinicaSil(fontSize: 18, color: Colors.white)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}