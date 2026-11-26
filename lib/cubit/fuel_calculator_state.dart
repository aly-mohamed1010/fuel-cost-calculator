part of 'fuel_calculator_cubit.dart';

enum FuelType {
  octane92(21.0, '92 Standard'),
  octane95(24.0, '95 Premium');

  final double price;
  final String label;
  const FuelType(this.price, this.label);
}

enum TripFrequency {
  oneTime(1, 'One-time Trip'),
  daily(30, 'Daily (Monthly Cost)'),
  weekly(4, 'Weekly (Monthly Cost)'),
  monthly(1, 'Monthly Cost');

  final int multiplier;
  final String label;
  const TripFrequency(this.multiplier, this.label);
}

class FuelCalculatorState extends Equatable {
  final FuelType fuelType;
  final double consumptionRate; // L/100km
  final double distanceKm;
  final TripFrequency frequency;

  const FuelCalculatorState({
    this.fuelType = FuelType.octane92,
    this.consumptionRate = 8.0, // Default average
    this.distanceKm = 0.0,
    this.frequency = TripFrequency.oneTime,
  });

  double get costPerTrip {
    // Distance * 2 to account for round trip, or just distance? 
    // Usually "a drive" implies one direction, let's keep it one direction for now, 
    // or add a multiplier. Let's do a simple calculation based on one way distance.
    return (distanceKm / 100) * consumptionRate * fuelType.price;
  }

  double get totalCost {
    return costPerTrip * frequency.multiplier;
  }

  FuelCalculatorState copyWith({
    FuelType? fuelType,
    double? consumptionRate,
    double? distanceKm,
    TripFrequency? frequency,
  }) {
    return FuelCalculatorState(
      fuelType: fuelType ?? this.fuelType,
      consumptionRate: consumptionRate ?? this.consumptionRate,
      distanceKm: distanceKm ?? this.distanceKm,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  List<Object?> get props => [fuelType, consumptionRate, distanceKm, frequency];
}
