import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/fuel_calculator_cubit.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Fuel Cost'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<FuelCalculatorCubit, FuelCalculatorState>(
            builder: (context, state) {
              final cubit = context.read<FuelCalculatorCubit>();
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTotalCostCard(context, state),
                    const SizedBox(height: 28),
                    _buildMapButton(context, state),
                    const SizedBox(height: 28),
                    _buildInputForm(context, cubit, state),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCostCard(BuildContext context, FuelCalculatorState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: Column(
          children: [
            Text(
              'Estimated Cost',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  state.totalCost.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    'EGP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            if (state.frequency != TripFrequency.oneTime) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Per Month',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(BuildContext context, FuelCalculatorState state) {
    final hasDistance = state.distanceKm > 0;
    
    return ElevatedButton(
      onPressed: () async {
        final distance = await Navigator.push<double>(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        if (distance != null && context.mounted) {
          context.read<FuelCalculatorCubit>().setDistance(distance);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: hasDistance ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: hasDistance ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: hasDistance ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(hasDistance ? Icons.map : Icons.add_location_alt, size: 28),
          const SizedBox(width: 12),
          Text(
            hasDistance
                ? 'Distance: ${state.distanceKm.toStringAsFixed(1)} km'
                : 'Select Destination',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(
      BuildContext context, FuelCalculatorCubit cubit, FuelCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Fuel Type Dropdown
            _buildDropdown<FuelType>(
              initialValue: state.fuelType,
              label: 'Fuel Type',
              icon: Icons.local_gas_station,
              items: FuelType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text('${type.label} (${type.price} EGP/L)'),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) cubit.setFuelType(type);
              },
            ),
            const SizedBox(height: 20),

            // Consumption Rate Input
            TextFormField(
              initialValue: state.consumptionRate.toString(),
              decoration: InputDecoration(
                labelText: 'Consumption (L/100km)',
                prefixIcon: const Icon(Icons.speed),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  cubit.setConsumptionRate(parsed);
                }
              },
            ),
            const SizedBox(height: 20),

            // Frequency Dropdown
            _buildDropdown<TripFrequency>(
              initialValue: state.frequency,
              label: 'Trip Frequency',
              icon: Icons.calendar_month,
              items: TripFrequency.values.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(freq.label),
                );
              }).toList(),
              onChanged: (freq) {
                if (freq != null) cubit.setFrequency(freq);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T initialValue,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
      ),
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      borderRadius: BorderRadius.circular(16),
    );
  }
}

