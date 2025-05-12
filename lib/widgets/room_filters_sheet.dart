import 'package:flutter/material.dart';

class RoomsFilter {
  final String status;
  final RangeValues capacityRange;
  final double maxPrice;
  final List<String> amenities;

  const RoomsFilter({
    required this.status,
    required this.capacityRange,
    required this.maxPrice,
    required this.amenities,
  });

  static RoomsFilter empty() => const RoomsFilter(
        status: 'Todas',
        capacityRange: RangeValues(0, 50),
        maxPrice: 100,
        amenities: [],
      );
}

Future<RoomsFilter?> showRoomFiltersSheet(BuildContext context, RoomsFilter currentFilter) {
  return showModalBottomSheet<RoomsFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      String selectedStatus = currentFilter.status;
      RangeValues selectedCapacity = currentFilter.capacityRange;
      double selectedMaxPrice = currentFilter.maxPrice;
      List<String> selectedAmenities = [...currentFilter.amenities];

      final List<String> allAmenities = ['Proyector', 'Pizarra', 'TV', 'Climatización', 'Wifi'];

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              runSpacing: 16,
              children: [
                const Text('Estado', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (value) {
                    if (value != null) setState(() => selectedStatus = value);
                  },
                  items: ['Todas', 'Disponible', 'Ocupada'].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                ),

                const Text('Capacidad (personas)', style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: selectedCapacity,
                  min: 0,
                  max: 50,
                  divisions: 10,
                  labels: RangeLabels(
                    '${selectedCapacity.start.round()}',
                    '${selectedCapacity.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() => selectedCapacity = values);
                  },
                ),

                const Text('Precio máximo por hora (€)', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: selectedMaxPrice,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${selectedMaxPrice.round()} €',
                  onChanged: (value) {
                    setState(() => selectedMaxPrice = value);
                  },
                ),

                const Text('Amenidades', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: allAmenities.map((amenity) {
                    final isSelected = selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedAmenities.add(amenity);
                          } else {
                            selectedAmenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('Restablecer'),
                      onPressed: () {
                        Navigator.pop(context, RoomsFilter.empty());
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Aplicar filtros'),
                      onPressed: () {
                        final result = RoomsFilter(
                          status: selectedStatus,
                          capacityRange: selectedCapacity,
                          maxPrice: selectedMaxPrice,
                          amenities: selectedAmenities,
                        );
                        Navigator.pop(context, result);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

