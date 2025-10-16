import 'package:flutter/material.dart';
import '../controller/barbershop_detail_controller.dart';
import '../model/barbershop_detail_model.dart';

class BarbershopDetailView extends StatefulWidget {
  final String barbershopName;

  const BarbershopDetailView({super.key, required this.barbershopName});

  @override
  State<BarbershopDetailView> createState() => _BarbershopDetailViewState();
}

class _BarbershopDetailViewState extends State<BarbershopDetailView> {
  final BarbershopDetailController _controller = BarbershopDetailController();
  BarbershopDetail? _detail;

  @override
  void initState() {
    super.initState();
    // Busca os detalhes da barbearia com base no nome recebido
    _detail = _controller.getDetailsFor(widget.barbershopName);
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se os detalhes foram encontrados
    if (_detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Detalhes da barbearia não encontrados.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_detail!.name),
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
                  Image.network(
                    _detail!.imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _detail!.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.location_on, 'Endereço', '${_detail!.address}, ${_detail!.cityState}'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.access_time, 'Horário', _detail!.openingHours),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção "Barbeiro Responsável"
            const Text('Barbeiro Responsável', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop'),
              ),
              title: Text('João da Silva', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Especialista em cortes clássicos'),
            ),
            const SizedBox(height: 24),

            // Seção "Especialidades"
            const Text('Especialidades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset('lib/images/man-hair_icon.png', width: 30, color: Colors.black87),
                const SizedBox(width: 12),
                const Text('Corte', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar as linhas de informação
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
              Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }
}