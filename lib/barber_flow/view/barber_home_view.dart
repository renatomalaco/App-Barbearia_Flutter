import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/list_model.dart';

class BarberHomeView extends StatefulWidget {
  const BarberHomeView({super.key});

  @override
  State<BarberHomeView> createState() => _BarberHomeViewState();
}

class _BarberHomeViewState extends State<BarberHomeView> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers Gerais
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();
  
  // Controllers Novos (Solicitados)
  final _barberNameCtrl = TextEditingController();
  final _barberSpecialtyCtrl = TextEditingController();
  final _specialtiesListCtrl = TextEditingController(); // Texto separado por vírgula

  // Carrega os dados existentes para os controladores
  void _loadDataIntoControllers(Map<String, dynamic> data) {
    _nameCtrl.text = data['name'] ?? '';
    _descCtrl.text = data['description'] ?? '';
    _addrCtrl.text = data['address'] ?? '';
    _cityCtrl.text = data['cityState'] ?? '';
    _zipCtrl.text = data['zipCode'] ?? '';
    _hoursCtrl.text = data['openingHours'] ?? '';
    _imgCtrl.text = data['imageUrl'] ?? '';
    
    // Novos campos
    _barberNameCtrl.text = data['barberName'] ?? '';
    _barberSpecialtyCtrl.text = data['barberSpecialty'] ?? '';
    
    // Converte a lista de especialidades de volta para string separada por vírgula
    List<dynamic> specs = data['specialties'] ?? [];
    _specialtiesListCtrl.text = specs.join(', ');
  }

  Future<void> _saveBarbershop() async {
    if (!_formKey.currentState!.validate()) return;

    // Converte a string de especialidades em Lista
    List<String> specialtiesList = _specialtiesListCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final shopData = {
      'name': _nameCtrl.text,
      'description': _descCtrl.text,
      'address': _addrCtrl.text,
      'cityState': _cityCtrl.text,
      'zipCode': _zipCtrl.text,
      'openingHours': _hoursCtrl.text,
      'imageUrl': _imgCtrl.text.isNotEmpty ? _imgCtrl.text : 'https://via.placeholder.com/300',
      // Novos Campos Salvos
      'barberName': _barberNameCtrl.text,
      'barberSpecialty': _barberSpecialtyCtrl.text,
      'specialties': specialtiesList,
      'barberUid': user?.uid,
    };

    await FirebaseFirestore.instance
        .collection('barbershops')
        .doc(user!.uid)
        .set(shopData, SetOptions(merge: true));
        
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("Erro: Não logado"));

    return Scaffold(
      appBar: AppBar(
        // Removemos o leading (seta) pois esta é a tela principal do barbeiro
        automaticallyImplyLeading: false, 
        title: Text(
          _isEditing ? 'Editar Informações' : 'Minha Barbearia', 
          style: GoogleFonts.baloo2(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão de alternar entre Visualização e Edição
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF844333)),
              onPressed: () => setState(() => _isEditing = true),
            )
          else 
             IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => setState(() => _isEditing = false),
            )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('barbershops').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Cenário 1: Sem dados ou Modo Edição Ativo -> MOSTRA FORMULÁRIO
          if (!snapshot.data!.exists || _isEditing) {
            // Se existirem dados, carrega nos controllers apenas uma vez ao entrar na edição
            if (snapshot.data!.exists && _nameCtrl.text.isEmpty) {
               _loadDataIntoControllers(snapshot.data!.data() as Map<String, dynamic>);
            }
            return _buildForm();
          }

          // Cenário 2: Dados Existem e Modo Visualização -> MOSTRA CARD (Sem botão agendar)
          final data = snapshot.data!.data() as Map<String, dynamic>;
          
          // Cria objeto para facilitar uso (opcional, pode usar data['key'] direto)
          final shop = Barbershop(
            id: snapshot.data!.id,
            name: data['name'],
            description: data['description'],
            address: data['address'],
            cityState: data['cityState'],
            zipCode: data['zipCode'],
            imageUrl: data['imageUrl'],
            openingHours: data['openingHours'],
            barberName: data['barberName'] ?? 'Nome do Barbeiro',
            barberSpecialty: data['barberSpecialty'] ?? 'Especialidade',
            barberImageUrl: data['barberImageUrl'] ?? '', // Se tiver foto do perfil
            specialties: List<String>.from(data['specialties'] ?? []),
          );

          return _buildShopPreview(shop);
        },
      ),
    );
  }

  // --- WIDGET DO FORMULÁRIO ---
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dados da Barbearia", style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(_nameCtrl, 'Nome da Barbearia'),
            _buildTextField(_descCtrl, 'Descrição Curta'),
            _buildTextField(_addrCtrl, 'Endereço'),
            Row(children: [
              Expanded(child: _buildTextField(_cityCtrl, 'Cidade - UF')),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(_zipCtrl, 'CEP')),
            ]),
            _buildTextField(_hoursCtrl, 'Horário (ex: 09:00 - 18:00)'),
            _buildTextField(_imgCtrl, 'URL da Imagem de Capa'),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            Text("Dados do Profissional", style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // NOVOS CAMPOS SOLICITADOS
            _buildTextField(_barberNameCtrl, 'Nome do Barbeiro'),
            _buildTextField(_barberSpecialtyCtrl, 'Especialidade (ex: Rei do Degradê)'),
            _buildTextField(_specialtiesListCtrl, 'Especialidades da loja (separe por vírgula)', maxLines: 2),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF844333)),
                onPressed: _saveBarbershop,
                child: const Text('Salvar Alterações', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  // --- WIDGET DE PREVIEW (Visualização do Barbeiro) ---
  // É basicamente o código da DetailView, mas SEM o Scaffold/AppBar/Leading/Botão Agendar
  Widget _buildShopPreview(Barbershop shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do topo
          if (shop.imageUrl.isNotEmpty)
            Image.network(
              shop.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(height: 250, child: Center(child: Icon(Icons.broken_image, size: 50))),
            )
          else
             Container(height: 250, color: Colors.grey[300], child: const Center(child: Text("Sem imagem"))),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título duplicado removido pois já está na AppBar, ou mantém como subtítulo
                Text(shop.name, style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Informações Gerais
                Text(shop.description, style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on, 'Endereço', '${shop.address}, ${shop.cityState}'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, 'Horário', shop.openingHours),
                const Divider(height: 32),

                // Barbeiro Responsável (Dados vindos do formulário agora)
                Text('Barbeiro Responsável', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 28,
                    // Usa imagem salva ou padrão
                    backgroundImage: (shop.barberImageUrl.isNotEmpty)
                        ? NetworkImage(shop.barberImageUrl)
                        : const AssetImage('lib/images/user.png') as ImageProvider,
                  ),
                  title: Text(shop.barberName, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(shop.barberSpecialty, style: GoogleFonts.baloo2(fontSize: 14)),
                ),
                const SizedBox(height: 24),

                // Especialidades (Lista dinâmica vinda do formulário)
                Text('Especialidades', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (shop.specialties.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: shop.specialties.map((specialty) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Image.asset('lib/images/man-hair_icon.png', width: 20, color: const Color(0xFF844333)),
                      ),
                      label: Text(specialty, style: GoogleFonts.baloo2()),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                    )).toList(),
                  )
                else
                  const Text("Nenhuma especialidade listada."),

                // OBSERVAÇÃO: O BOTÃO DE AGENDAR FOI REMOVIDO DAQUI COMO SOLICITADO
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF844333), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}