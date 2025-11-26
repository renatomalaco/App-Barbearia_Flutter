import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../view/chat_view.dart'; // Para navegação

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- MODAL 1: ADICIONAR AGENDAMENTO ---
  void _showAddAppointmentDialog() {
    final _formKey = GlobalKey<FormState>();
    String? selectedBarber;
    String? selectedService = 'Corte Simples';
    TimeOfDay selectedTime = TimeOfDay.now();
    
    final List<String> barbers = ['Jhon Cortes', 'Marcos da Navalha', 'Barbearia Old School'];
    final List<String> services = ['Corte Simples', 'Barba', 'Completo'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Novo Agendamento', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateModal) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Barbeiro'),
                      items: barbers.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => selectedBarber = v,
                      validator: (v) => v == null ? 'Selecione um barbeiro' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: const InputDecoration(labelText: 'Serviço'),
                      items: services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => selectedService = v,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(context: context, initialTime: selectedTime);
                            if (time != null) setStateModal(() => selectedTime = time);
                          },
                          child: Text(selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF844333)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _saveAppointment(selectedBarber!, selectedService!, selectedTime);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Agendar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAppointment(String barber, String service, TimeOfDay time) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DateTime fullDate = DateTime(
      _selectedDay.year, _selectedDay.month, _selectedDay.day, time.hour, time.minute
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('appointments')
        .add({
      'barberName': barber,
      'service': service,
      'date': Timestamp.fromDate(fullDate),
      'status': 'agendado',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agendado com sucesso!")));
    }
  }

  // --- FUNÇÃO PARA APAGAR (DESMARCAR) ---
  Future<void> _deleteAppointment(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Mostra confirmação antes de apagar
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(docId)
          .delete();

      if (mounted) {
        Navigator.pop(context); // Fecha o modal de detalhes
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agendamento desmarcado.")));
      }
    }
  }

  // --- MODAL 2: VER DETALHES (COM OPÇÃO DESMARCAR) ---
  void _showAppointmentDetails(String docId, Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp).toDate();
    final timeString = DateFormat('HH:mm').format(date);
    final dateString = DateFormat('dd/MM/yyyy').format(date);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.event_available, color: Color(0xFF844333)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data['barberName'] ?? 'Barbeiro', 
                  style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
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
            // BOTÃO DESMARCAR (NOVO)
            TextButton(
              onPressed: () => _deleteAppointment(docId),
              child: Text("Desmarcar", style: GoogleFonts.baloo2(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            // BOTÃO FECHAR (MANTIDO)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar"),
            ),
            // BOTÃO MENSAGEM (MANTIDO)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF844333)),
              icon: const Icon(Icons.chat, color: Colors.white, size: 18),
              label: const Text("Mensagem", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatView(
                      chatName: data['barberName'],
                      avatarUrl: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                    ),
                  ),
                );
              },
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
                children: [_buildDayAppointments(), _buildAllHistory()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Faça login"));

    final startOfDay = Timestamp.fromDate(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));
    final endOfDay = Timestamp.fromDate(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 23, 59, 59));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("Sem agendamentos."));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index]; // Pega o documento
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id; // Pega o ID

            return GestureDetector(
              onTap: () => _showAppointmentDetails(docId, data), // Passa o ID e os dados
              child: Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.cut, color: Color(0xFF844333)),
                  title: Text(data['service']),
                  subtitle: Text(data['barberName']),
                  trailing: Text(DateFormat('HH:mm').format((data['date'] as Timestamp).toDate())),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllHistory() {
     final user = FirebaseAuth.instance.currentUser;
     return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('appointments')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index]; // Pega o documento
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id; // Pega o ID

            return ListTile(
              title: Text(data['service']),
              subtitle: Text(DateFormat('dd/MM - HH:mm').format((data['date'] as Timestamp).toDate())),
              trailing: Text(data['barberName']),
              onTap: () => _showAppointmentDetails(docId, data), // Passa o ID e os dados
            );
          },
        );
      },
    );
  }
}