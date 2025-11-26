import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/list_model.dart';
import '../view/barbershop_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";
  
  // Estado para controlar a ordenação (RF006)
  String _orderBy = 'name'; // Opções: name, cityState
  bool _isDescending = false;

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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.baloo2(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Pesquisar barbearia...',
            hintStyle: GoogleFonts.baloo2(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value.toLowerCase(); // Normaliza para busca (RF006)
            });
          },
        ),
        // Botão de Ordenação (RF006)
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: (String value) {
              setState(() {
                if (_orderBy == value) {
                  // Se clicar no mesmo, inverte a ordem
                  _isDescending = !_isDescending;
                } else {
                  _orderBy = value;
                  _isDescending = false;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Ordenar por Nome'),
              ),
              const PopupMenuItem<String>(
                value: 'cityState',
                child: Text('Ordenar por Cidade'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Busca todos os dados ou filtra se houver termo
        stream: _searchTerm.isEmpty
            ? FirebaseFirestore.instance.collection('barbershops').snapshots()
            : FirebaseFirestore.instance
                .collection('barbershops')
                .where('name_lowercase', isGreaterThanOrEqualTo: _searchTerm)
                .where('name_lowercase', isLessThan: '$_searchTerm\uf8ff')
                .snapshots(),
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

          // Lógica de Ordenação no Cliente (Cliente-side sorting)
          // Isso garante flexibilidade total sem precisar de índices compostos complexos no Firestore
          List<QueryDocumentSnapshot> docs = data.docs;
          docs.sort((a, b) {
            Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
            Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;
            
            String fieldA = (dataA[_orderBy] ?? '').toString().toLowerCase();
            String fieldB = (dataB[_orderBy] ?? '').toString().toLowerCase();

            return _isDescending 
                ? fieldB.compareTo(fieldA) 
                : fieldA.compareTo(fieldB);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final dataMap = doc.data() as Map<String, dynamic>;
              
              final barbershop = Barbershop(
                id: doc.id,
                name: dataMap['name'],
                description: dataMap['description'],
                address: dataMap['address'],
                cityState: dataMap['cityState'],
                zipCode: dataMap['zipCode'],
                imageUrl: dataMap['imageUrl'],
                openingHours: dataMap['openingHours'],
                barberName: dataMap['barberName'] ?? 'Barbeiro', 
                barberSpecialty: dataMap['barberSpecialty'] ?? 'Especialista',
                barberImageUrl: dataMap['barberImageUrl'] ?? '',
                specialties: (dataMap['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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