import 'package:barbado/view/search_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../controller/list_controller.dart';
import '../model/list_model.dart';
import '../client_flow/view/schedule_view.dart';
import '../client_flow/view/chat_list_view.dart';
import 'config_view.dart';
import 'barbershop_detail_view.dart';

class ListsView extends StatefulWidget {
  final int initialIndex;

  const ListsView({super.key, this.initialIndex = 0});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  // 1. ADICIONADO: Controlador de estado para o item selecionado na Bottom Bar
  int _selectedIndex = 0;

  // Manter o controller da sua lista original
  // final _controller = ListController();

  // ADICIONADO: Lista de telas que serão navegadas
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // A lista de páginas agora é inicializada aqui
    _pages = [
      _buildBarbershopListPage(), 
      const ScheduleView(),       
      const ChatListView(),       
      const ConfigView(),         
    ];
  }

  // 2. ADICIONADO: Função para atualizar o estado quando um item é tocado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. MODIFICADO: O Scaffold agora contém a BottomNavigationBar
    return Scaffold(
      // O IndexedStack é usado para manter o estado de cada página
      // ao alternar entre elas.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // 4. ADICIONADO: A implementação da BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.home),
            ), // Ícone quando ativo
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.calendar_today_outlined),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.calendar_today),
            ),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.chat_bubble),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(Icons.settings_outlined),
            ),
            activeIcon: const Padding(padding: EdgeInsets.only(top: 4.0), child: Icon(Icons.settings)),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF844333), // Cor do item ativo
        unselectedItemColor: Colors.grey,   // Cor dos itens inativos
        selectedLabelStyle: GoogleFonts.baloo2(),
        unselectedLabelStyle: GoogleFonts.baloo2(),
        showUnselectedLabels: true,        // Garante que todos os labels apareçam
        type: BottomNavigationBarType.fixed, // Layout fixo para os itens
      ),
    );
  }

  // 5. MOVIDO: Todo o conteúdo original do corpo foi movido para este método
  // para manter o código organizado.
  Widget _buildBarbershopListPage() {
    return SafeArea(
      child: Column(
        children: [
          // Topo da tela com os botões de categoria e perfil do usuário
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                    ),
                    // --- NOVO BOTÃO DE PESQUISA ---
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchView()),
                        );
                      },
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'edit_profile');
                      },
                      child: const CircleAvatar(
                      ),
                    ),
                  ],
                ),  
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryButton(context, 'Barbeiros', 'lib/images/barber_icon.png'),
                    _buildCategoryButton(context, 'Salões', 'lib/images/barber-chair_icon.png'),
                    _buildCategoryButton(context, 'Cortes', 'lib/images/man-hair_icon.png'),
                    _buildCategoryButton(context, 'Barba', 'lib/images/beard_icon.png'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Conecta na coleção 'barbershops' do Firestore
              stream: FirebaseFirestore.instance.collection('barbershops').snapshots(),
              builder: (context, snapshot) {
                // Tratamento de erros e carregamento
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar dados'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Se não tiver dados ou a lista estiver vazia
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma barbearia encontrada'));
                }

                final data = snapshot.requireData;

                return ListView.builder(
                  // controller: _controller.scrollController,
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    // Pega o documento atual
                    final doc = data.docs[index];
                    final dataMap = doc.data() as Map<String, dynamic>;
                    
                    // Converte os dados do Firestore para o seu Modelo
                    // IMPORTANTE: Certifique-se de que os nomes dos campos aqui ('name', 'address', etc.)
                    // sejam EXATAMENTE iguais aos que você criou no Firebase Console.
                    final barbershop = Barbershop(
                      id: doc.id,
                      name: doc['name'],
                      description: doc['description'],
                      address: doc['address'],
                      cityState: doc['cityState'],
                      zipCode: doc['zipCode'],
                      imageUrl: doc['imageUrl'],
                      openingHours: doc['openingHours'],
                      barberName: dataMap['barberName'] ?? 'Barbeiro', 
                      barberSpecialty: dataMap['barberSpecialty'] ?? 'Especialista',
                      barberImageUrl: dataMap['barberImageUrl'] ?? '',
                      specialties: (dataMap['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Corte'],
                    );
                    
                    return _BarbershopCard(barbershop: barbershop);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // O resto do seu código permanece o mesmo
  Widget _buildCategoryButton(BuildContext context, String text, String imagePath) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Image.asset(
            imagePath,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(text),
      ],
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}

class _BarbershopCard extends StatefulWidget {
  final Barbershop barbershop;

  const _BarbershopCard({required this.barbershop});

  @override
  State<_BarbershopCard> createState() => _BarbershopCardState();
}

class _BarbershopCardState extends State<_BarbershopCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarbershopDetailView(barbershop: widget.barbershop),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: _isHovered ? 8 : 2,
          clipBehavior: Clip.antiAlias, // Garante que a imagem não ultrapasse as bordas arredondadas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Image.network(
                  widget.barbershop.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.barbershop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.barbershop.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          widget.barbershop.openingHours,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${widget.barbershop.address} - ${widget.barbershop.cityState}, ${widget.barbershop.zipCode}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}