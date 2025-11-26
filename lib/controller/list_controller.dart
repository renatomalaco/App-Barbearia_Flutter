// import 'package:flutter/material.dart';
// import '../model/list_model.dart';

// class ListController {
//   final ScrollController scrollController = ScrollController();
//   final ValueNotifier<List<Barbershop>> barbershops = ValueNotifier<List<Barbershop>>([]);

//   void loadBarbershops() {
//     // No futuro, esta parte buscará os dados de uma fonte externa (API, banco de dados, etc.).
//     // Por enquanto, usamos dados mocados como solicitado.
//     barbershops.value = [
//       Barbershop(
//         name: 'Barbearia New Cut',
//         description: 'Barbearia Vintage especializada em cortes clássicos',
//         address: 'R. Augusta, 2212 - Cerqueira César',
//         cityState: 'São Paulo - SP',
//         zipCode: '01412-000',
//         imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
//         openingHours: '12:00 - 20:00',
//       ),
//       Barbershop(
//         name: 'Barbearia Old School',
//         description: 'Cortes e barbas tradicionais para o homem moderno',
//         address: 'Av. Paulista, 1000 - Bela Vista',
//         cityState: 'São Paulo - SP',
//         zipCode: '01310-100',
//         imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YmFyYmVyc2hvcHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600',
//         openingHours: '09:00 - 18:00',
//       ),
//       Barbershop(
//         name: 'Classic Cuts Barbershop',
//         description: 'Experiência única em estilo e elegância',
//         address: 'Rua da Consolação, 500 - Consolação',
//         cityState: 'São Paulo - SP',
//         zipCode: '01302-000',
//         imageUrl: 'https://images.unsplash.com/photo-1693755807658-17ce5331aacb?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGJhcmJlcnNob3B8ZW58MHwwfDB8fHww&auto=format&fit=crop&q=60&w=600',
//         openingHours: '10:00 - 19:00',
//       ),
//     ];
//   }

//   void dispose() {
//     scrollController.dispose();
//     barbershops.dispose();
//   }
// }