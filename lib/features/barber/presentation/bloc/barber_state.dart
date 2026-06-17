import '../../data/models/barber_model.dart';

abstract class BarberState {}

class BarberInitial extends BarberState {}

class BarberLoading extends BarberState {}

class BarberLoaded extends BarberState {
  final List<BarberModel> barbers;
  BarberLoaded(this.barbers);
}

class BarberError extends BarberState {
  final String message;
  BarberError(this.message);
}

/// Feedback transitorio de una acción (promover, eliminar, etc.)
/// para mostrar en un SnackBar sin afectar la lista visible.
class BarberFeedback extends BarberState {
  final String message;
  final bool isError;
  BarberFeedback(this.message, {this.isError = false});
}
