import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/list_model.dart';

class BarbershopDetailView extends StatefulWidget {
  final Barbershop barbershop;

  const BarbershopDetailView({super.key, required this.barbershop});

  @override
  State<BarbershopDetailView> createState() => _BarbershopDetailViewState();
}

class _BarbershopDetailViewState extends State<BarbershopDetailView> {
  @override
  Widget build(BuildContext context) {
    final shop = widget.barbershop;

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name, style: GoogleFonts.baloo2(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24.0), // Espaço extra no final
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
                    const SizedBox(height: 250, child: Center(child: Icon(Icons.broken_image))),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações Gerais
                  Text(shop.description, style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, 'Endereço', '${shop.address}, ${shop.cityState}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Horário', shop.openingHours),
                  const Divider(height: 32),

                  // Barbeiro Responsável
                  Text('Barbeiro Responsável', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: (shop.barberImageUrl.isNotEmpty)
                          ? NetworkImage(shop.barberImageUrl)
                          : const AssetImage('lib/images/user.png') as ImageProvider,
                    ),
                    title: Text(shop.barberName, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
                    subtitle: Text(shop.barberSpecialty, style: GoogleFonts.baloo2()),
                  ),
                  const SizedBox(height: 24),

                  // Especialidades
                  Text('Especialidades', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (shop.specialties.isNotEmpty)
                    ...shop.specialties.map((specialty) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Image.asset('lib/images/man-hair_icon.png', width: 24, color: const Color(0xFF844333)),
                              const SizedBox(width: 12),
                              Text(specialty, style: GoogleFonts.baloo2(fontSize: 16)),
                            ],
                          ),
                        ))
                  else
                    const Text("Nenhuma especialidade listada."),

                  const SizedBox(height: 32),

                  // --- BOTÃO MOVIDO PARA CÁ ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF844333),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Lógica para abrir modal de agendamento (Pode ser implementada aqui ou navegar para outra tela)
                        // Sugestão: Passar o ID do barbeiro para a ScheduleView ou abrir um modal aqui mesmo.
                        Navigator.pushNamed(context, 'agenda', arguments: shop);
                      },
                      child: Text('AGENDAR HORÁRIO', style: GoogleFonts.baloo2(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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