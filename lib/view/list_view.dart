import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/list_controller.dart';
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
  final _controller = ListController();

  // ADICIONADO: Lista de telas que serão navegadas
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _controller.loadBarbershops();

    // A lista de páginas agora é inicializada aqui
    _pages = [
      _buildBarbershopListPage(), // A sua tela de lista de barbearias
      const ScheduleView(),       // A tela da Agenda
      const ChatListView(),       // A tela do Chat
      const ConfigView(),         // ADICIONADO: A tela de Configurações
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
            icon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.home),
            ), // Ícone quando ativo
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.calendar_today_outlined),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.calendar_today),
            ),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.chat_bubble),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.settings_outlined),
            ),
            activeIcon: Padding(padding: const EdgeInsets.only(top: 4.0), child: Icon(Icons.settings)),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'edit_profile');
                      },
                      child: const CircleAvatar(
                        backgroundImage: NetworkImage('https://media.discordapp.net/attachments/1249450843002896516/1428545035283992586/jsus_cristo.png?ex=68f2e3bd&is=68f1923d&hm=060b3bddd2cf74cfcdeffa521b00f4c6492013281478d3e2976bcc613d1f822c&=&format=webp&quality=lossless&width=786&height=810'), // Imagem de perfil de exemplo
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
            child: ValueListenableBuilder<List<Barbershop>>(
              valueListenable: _controller.barbershops,
              builder: (context, barbershops, child) {
                return ListView.builder(
                  controller: _controller.scrollController,
                  itemCount: barbershops.length,
                  itemBuilder: (context, index) {
                    final barbershop = barbershops[index];
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
    _controller.dispose();
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
              builder: (context) => BarbershopDetailView(barbershopName: widget.barbershop.name),
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