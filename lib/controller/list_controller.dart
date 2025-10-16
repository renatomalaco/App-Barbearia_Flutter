import 'package:flutter/material.dart';
import '../model/list_model.dart';

class ListController {
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<List<Barbershop>> barbershops = ValueNotifier<List<Barbershop>>([]);

  void loadBarbershops() {
    // No futuro, esta parte buscará os dados de uma fonte externa (API, banco de dados, etc.).
    // Por enquanto, usamos dados mocados como solicitado.
    barbershops.value = [
      Barbershop(
        name: 'Barbearia New Cut',
        description: 'Barbearia Vintage especializada em cortes clássicos',
        address: 'R. Augusta, 2212 - Cerqueira César',
        cityState: 'São Paulo - SP',
        zipCode: '01412-000',
        imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
        openingHours: '12:00 - 20:00',
      ),
      Barbershop(
        name: 'Barbearia Old School',
        description: 'Cortes e barbas tradicionais para o homem moderno',
        address: 'Av. Paulista, 1000 - Bela Vista',
        cityState: 'São Paulo - SP',
        zipCode: '01310-100',
        imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
        openingHours: '09:00 - 18:00',
      ),
      Barbershop(
        name: 'Classic Cuts Barbershop',
        description: 'Experiência única em estilo e elegância',
        address: 'Rua da Consolação, 500 - Consolação',
        cityState: 'São Paulo - SP',
        zipCode: '01302-000',
        imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
        openingHours: '10:00 - 19:00',
      ),
    ];
  }

  void dispose() {
    scrollController.dispose();
    barbershops.dispose();
  }
}