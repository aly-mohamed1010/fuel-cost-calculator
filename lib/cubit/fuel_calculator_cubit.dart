import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'fuel_calculator_state.dart';

class FuelCalculatorCubit extends Cubit<FuelCalculatorState> {
  FuelCalculatorCubit() : super(const FuelCalculatorState());

  void setFuelType(FuelType type) {
    emit(state.copyWith(fuelType: type));
  }

  void setConsumptionRate(double rate) {
    emit(state.copyWith(consumptionRate: rate));
  }

  void setDistance(double distance) {
    emit(state.copyWith(distanceKm: distance));
  }

  void setFrequency(TripFrequency freq) {
    emit(state.copyWith(frequency: freq));
  }
}
