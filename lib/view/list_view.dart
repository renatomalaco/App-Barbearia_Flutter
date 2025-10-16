import 'package:flutter/material.dart';
import '../controller/list_controller.dart';
import '../model/list_model.dart';

class ListsView extends StatefulWidget {
  const ListsView({super.key});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  final _controller = ListController();

  @override
  void initState() {
    super.initState();
    _controller.loadBarbershops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.search),
                      ),
                      const Text(
                        'Search Barbershop',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop'), // Imagem de perfil de exemplo
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
                      return _buildBarbershopCard(barbershop);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String text, String imagePath) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(12), // Adiciona um respiro para a imagem
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Image.asset(
            imagePath,
            color: Colors.grey[700], // Aplica uma cor para consistência visual
          ),
        ),
        const SizedBox(height: 4),
        Text(text),
      ],
    );
  }

  Widget _buildBarbershopCard(Barbershop barbershop) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              barbershop.imageUrl,
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
                  barbershop.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  barbershop.description,
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
                      barbershop.openingHours,
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
                        '${barbershop.address} - ${barbershop.cityState}, ${barbershop.zipCode}',
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}