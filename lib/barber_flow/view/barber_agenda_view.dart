import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BarberAgendaView extends StatelessWidget {
  const BarberAgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda de Clientes', style: GoogleFonts.baloo2(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lê da coleção da PRÓPRIA barbearia
        stream: FirebaseFirestore.instance
            .collection('barbershops')
            .doc(user!.uid)
            .collection('appointments')
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erro ao carregar agenda"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("Nenhum agendamento encontrado.", style: GoogleFonts.baloo2()));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)), // Poderia ser foto do cliente
                  title: Text(data['clientName'] ?? 'Cliente', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['service']} - ${DateFormat('dd/MM HH:mm').format(date)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () {
                      // Lógica para concluir/confirmar agendamento
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}