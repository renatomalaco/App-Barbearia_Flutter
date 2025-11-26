import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../model/list_model.dart';
import '../../view/chat_view.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- FUNÇÃO PARA APAGAR (DESMARCAR) ---
  Future<void> _deleteAppointment(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desmarcar"),
        content: const Text("Tem certeza que deseja cancelar este agendamento?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Não")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Sim")),
        ],
      ),
    ) ?? false;

    if (confirm) {
      // Apaga da coleção do usuário
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(docId)
          .delete();
      
      // Nota: Para apagar da coleção do Barbeiro, precisaríamos ter salvo o ID 
      // do documento do barbeiro no documento do usuário. 
      // Por enquanto, apagamos apenas a visualização do cliente.

      if (mounted) {
        Navigator.pop(context); // Fecha o modal de detalhes
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agendamento desmarcado.")));
      }
    }
  }

  // --- MODAL DE DETALHES (AO CLICAR NO CARD) ---
  void _showAppointmentDetails(String docId, Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp).toDate();
    final timeString = DateFormat('HH:mm').format(date);
    final dateString = DateFormat('dd/MM/yyyy').format(date);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(data['barberName'] ?? 'Barbeiro', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Serviço: ${data['service']}", style: GoogleFonts.baloo2(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Data: $dateString", style: GoogleFonts.baloo2()),
              Text("Horário: $timeString", style: GoogleFonts.baloo2()),
              const SizedBox(height: 8),
              Text("Status: ${data['status']}", style: GoogleFonts.baloo2(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _deleteAppointment(docId),
              child: Text("Desmarcar", style: GoogleFonts.baloo2(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF844333)),
              onPressed: () {
                Navigator.pop(context);
                final barberUid = data['barberUid'];
                final barberName = data['barberName'] ?? 'Barbeiro';

                if (barberUid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Este agendamento antigo não tem o ID do barbeiro. Crie um novo."))
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatView(
                      chatId: barberUid, // Aqui vai o ID do Barbeiro
                      title: barberName,
                      avatarUrl: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                      
                        isBarberView: false, // É FALSO porque quem está clicando é o Cliente
                    ),
                  ),
                );
              },
              child: const Text("Mensagem", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- SALVAR AGENDAMENTO ---
  Future<void> _saveAppointment(Barbershop shop, String service, TimeOfDay time) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DateTime fullDate = DateTime(
      _selectedDay.year, _selectedDay.month, _selectedDay.day, time.hour, time.minute
    );

    final appointmentData = {
      'clientUid': user.uid,
      'clientName': user.displayName ?? 'Cliente', // Tenta pegar o nome do Auth ou usa padrão
      'barberUid': shop.id,
      'barberName': shop.name,
      'service': service,
      'date': Timestamp.fromDate(fullDate),
      'status': 'agendado',
    };

    try {
      // 1. Salvar no Cliente
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .add(appointmentData);

      // 2. Salvar no Barbeiro
      await FirebaseFirestore.instance
          .collection('barbershops')
          .doc(shop.id)
          .collection('appointments')
          .add(appointmentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agendado com sucesso!")));
        Navigator.pop(context); // Fecha o modal de agendamento
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  // --- MODAL DE NOVO AGENDAMENTO ---
  void _showAddAppointmentDialog() {
    final _formKey = GlobalKey<FormState>();
    Barbershop? selectedBarber;
    String? selectedService;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Novo Agendamento', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateModal) {
              return SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('barbershops').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const LinearProgressIndicator();
                          
                          List<DropdownMenuItem<Barbershop>> items = [];
                          for (var doc in snapshot.data!.docs) {
                             final data = doc.data() as Map<String, dynamic>;
                             // Cria o objeto com ID para o operador == funcionar
                             final b = Barbershop(
                               id: doc.id,
                               name: data['name'] ?? 'Sem Nome',
                               description: '', address: '', cityState: '', zipCode: '', imageUrl: '', openingHours: '',
                               specialties: List<String>.from(data['specialties'] ?? [])
                             );
                             items.add(DropdownMenuItem(value: b, child: Text(b.name, overflow: TextOverflow.ellipsis)));
                          }

                          return DropdownButtonFormField<Barbershop>(
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Barbeiro'),
                            items: items,
                            value: selectedBarber, // O operador == no model fará isso funcionar
                            onChanged: (v) {
                              setStateModal(() {
                                selectedBarber = v;
                                selectedService = null;
                              });
                            },
                            validator: (v) => v == null ? 'Selecione um barbeiro' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      
                      if (selectedBarber != null)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedService,
                          decoration: const InputDecoration(labelText: 'Serviço'),
                          items: selectedBarber!.specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setStateModal(() => selectedService = v),
                          validator: (v) => v == null ? 'Selecione um serviço' : null,
                        ),

                      const SizedBox(height: 20),
                      ListTile(
                        title: Text("Horário: ${selectedTime.format(context)}"),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: selectedTime);
                          if (time != null) setStateModal(() => selectedTime = time);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF844333)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveAppointment(selectedBarber!, selectedService!, selectedTime);
                }
              },
              child: const Text('Agendar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: const Color(0xFF844333),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Minha Agenda', style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Color(0xFF844333), shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF844333),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF844333),
              tabs: const [Tab(text: 'Do Dia'), Tab(text: 'Histórico')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAppointmentsList(true), _buildAppointmentsList(false)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(bool isDayView) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Faça login"));

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('appointments')
        .orderBy('date', descending: !isDayView); 

    if (isDayView) {
      final start = Timestamp.fromDate(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));
      final end = Timestamp.fromDate(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 23, 59, 59));
      query = query.where('date', isGreaterThanOrEqualTo: start).where('date', isLessThanOrEqualTo: end);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Erro: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("Nenhum agendamento."));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                // --- AQUI ESTA A CORREÇÃO DO CLIQUE NOS CARDS ---
                onTap: () => _showAppointmentDetails(doc.id, data), 
                leading: const Icon(Icons.content_cut, color: Color(0xFF844333)),
                title: Text(data['service'], style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
                subtitle: Text("${data['barberName']} - ${DateFormat('dd/MM HH:mm').format(date)}"),
                trailing: Text(data['status'].toString().toUpperCase(), style: GoogleFonts.baloo2(fontSize: 12)),
              ),
            );
          },
        );
      },
    );
  }
}