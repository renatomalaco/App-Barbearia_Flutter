import 'package:flutter/material.dart';
import '../model/list_model.dart'; // Certifique-se de importar o modelo correto

class BarbershopDetailView extends StatefulWidget {
  // 1. Mudamos de String para o Objeto Barbershop
  final Barbershop barbershop;

  const BarbershopDetailView({super.key, required this.barbershop});

  @override
  State<BarbershopDetailView> createState() => _BarbershopDetailViewState();
}

class _BarbershopDetailViewState extends State<BarbershopDetailView> {
  @override
  Widget build(BuildContext context) {
    // 2. Agora usamos 'widget.barbershop' para acessar os dados
    // Não precisamos mais de controller ou initState para buscar dados
    final shop = widget.barbershop;

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal com a imagem e informações
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shop.imageUrl.isNotEmpty)
                    Image.network(
                      shop.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(height: 220, child: Center(child: Icon(Icons.broken_image))),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.location_on, 'Endereço',
                            '${shop.address}, ${shop.cityState}'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.access_time, 'Horário', shop.openingHours),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção "Barbeiro Responsável"
            const Text('Barbeiro Responsável',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                // Se não tiver foto do barbeiro, usa a padrão
                backgroundImage: (shop.barberImageUrl.isNotEmpty)
                    ? NetworkImage(shop.barberImageUrl)
                    : const AssetImage('lib/images/user.png') as ImageProvider,
              ),
              title: Text(shop.barberName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(shop.barberSpecialty),
            ),
            const SizedBox(height: 24),

            // Seção "Especialidades"
            const Text('Especialidades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Gera a lista de especialidades dinamicamente
            if (shop.specialties.isNotEmpty)
              ...shop.specialties.map((specialty) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Image.asset('lib/images/man-hair_icon.png',
                            width: 30, color: Colors.black87),
                        const SizedBox(width: 12),
                        Text(specialty, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ))
            else
              const Text("Nenhuma especialidade listada."),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }
}