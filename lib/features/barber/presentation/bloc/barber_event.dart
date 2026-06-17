import '../../data/models/barber_model.dart';

abstract class BarberEvent {}

class LoadBarbers extends BarberEvent {
  final bool onlyActive;
  LoadBarbers({this.onlyActive = false});
}

class BarbersUpdated extends BarberEvent {
  final List<BarberModel> barbers;
  BarbersUpdated(this.barbers);
}

class BarbersFailed extends BarberEvent {
  final String message;
  BarbersFailed(this.message);
}

class PromoteBarber extends BarberEvent {
  final String email;
  final String specialty;
  PromoteBarber({required this.email, required this.specialty});
}

class UpdateBarber extends BarberEvent {
  final BarberModel barber;
  UpdateBarber(this.barber);
}

class ToggleBarberActive extends BarberEvent {
  final String id;
  final bool isActive;
  ToggleBarberActive(this.id, this.isActive);
}

class RemoveBarber extends BarberEvent {
  final String id;
  RemoveBarber(this.id);
}
