import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/list_model.dart'; // Import do modelo Barbershop
import '../view/barbershop_detail_view.dart'; // Para navegar aos detalhes

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // RF006: Interface gráfica exclusiva para pesquisa
        title: TextField(
          controller: _searchController,
          autofocus: true, // Abre o teclado automaticamente
          style: GoogleFonts.baloo2(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Pesquisar barbearia...',
            hintStyle: GoogleFonts.baloo2(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
            });
          },
        ),
      ),
      body: _searchTerm.isEmpty
          ? Center(
              child: Text(
                "Digite o nome da barbearia",
                style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              // --- AQUI ESTÁ O TRECHO QUE VOCÊ ENVIOU ---
              // Observação: Para isso funcionar, você DEVE ter o campo 
              // 'name_lowercase' salvo no Firestore em cada documento.
              stream: FirebaseFirestore.instance
                  .collection('barbershops')
                  .where('name', isGreaterThanOrEqualTo: _searchTerm)
                  .where('name', isLessThan: '$_searchTerm\uf8ff') // '\uf8ff' é o caractere Unicode final para range de string
                  .snapshots(),
              // ------------------------------------------
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                if (data.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma barbearia encontrada.",
                      style: GoogleFonts.baloo2(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    final doc = data.docs[index];
                    final dataMap = doc.data() as Map<String, dynamic>;
                    
                    // Conversão do documento para o Modelo (igual na ListView)
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

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(barbershop.imageUrl),
                      ),
                      title: Text(barbershop.name, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
                      subtitle: Text(barbershop.cityState, style: GoogleFonts.baloo2()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarbershopDetailView(barbershop: barbershop),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}