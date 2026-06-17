import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/barber_model.dart';
import '../../data/repositories/barber_repository.dart';
import 'barber_event.dart';
import 'barber_state.dart';

class BarberBloc extends Bloc<BarberEvent, BarberState> {
  final BarberRepository _repository;
  StreamSubscription<List<BarberModel>>? _subscription;

  BarberBloc(this._repository) : super(BarberInitial()) {
    on<LoadBarbers>(_onLoad);
    on<BarbersUpdated>(_onUpdated);
    on<BarbersFailed>(_onFailed);
    on<PromoteBarber>(_onPromote);
    on<UpdateBarber>(_onUpdate);
    on<ToggleBarberActive>(_onToggle);
    on<RemoveBarber>(_onRemove);
  }

  void _onLoad(LoadBarbers event, Emitter<BarberState> emit) {
    emit(BarberLoading());
    _subscription?.cancel();
    _subscription = _repository.watchBarbers(onlyActive: event.onlyActive).listen(
          (barbers) => add(BarbersUpdated(barbers)),
          onError: (_) => add(BarbersFailed('Error al cargar barberos')),
        );
  }

  void _onUpdated(BarbersUpdated event, Emitter<BarberState> emit) {
    emit(BarberLoaded(event.barbers));
  }

  void _onFailed(BarbersFailed event, Emitter<BarberState> emit) {
    emit(BarberError(event.message));
  }

  Future<void> _onPromote(PromoteBarber event, Emitter<BarberState> emit) async {
    try {
      await _repository.promoteUserToBarber(
        email: event.email,
        specialty: event.specialty,
      );
      emit(BarberFeedback('Barbero agregado correctamente'));
    } on BarberException catch (e) {
      emit(BarberFeedback(e.message, isError: true));
    } catch (_) {
      emit(BarberFeedback('No se pudo agregar el barbero', isError: true));
    }
  }

  Future<void> _onUpdate(UpdateBarber event, Emitter<BarberState> emit) async {
    try {
      await _repository.updateBarber(event.barber);
      emit(BarberFeedback('Barbero actualizado'));
    } catch (_) {
      emit(BarberFeedback('No se pudo actualizar', isError: true));
    }
  }

  Future<void> _onToggle(
      ToggleBarberActive event, Emitter<BarberState> emit) async {
    try {
      await _repository.toggleActive(event.id, event.isActive);
    } catch (_) {
      emit(BarberFeedback('No se pudo cambiar el estado', isError: true));
    }
  }

  Future<void> _onRemove(RemoveBarber event, Emitter<BarberState> emit) async {
    try {
      await _repository.removeBarber(event.id);
      emit(BarberFeedback('Barbero eliminado'));
    } catch (_) {
      emit(BarberFeedback('No se pudo eliminar', isError: true));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
