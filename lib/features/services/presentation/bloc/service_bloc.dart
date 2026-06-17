import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository _repository;
  StreamSubscription<List<ServiceModel>>? _subscription;

  ServiceBloc(this._repository) : super(ServiceInitial()) {
    on<LoadServices>(_onLoad);
    on<ServicesUpdated>(_onUpdated);
    on<ServicesFailed>(_onFailed);
    on<CreateService>(_onCreate);
    on<UpdateService>(_onUpdate);
    on<DeleteService>(_onDelete);
    on<ToggleServiceActive>(_onToggle);
  }

  void _onLoad(LoadServices event, Emitter<ServiceState> emit) {
    emit(ServiceLoading());
    _subscription?.cancel();
    _subscription = _repository
        .watchServices(onlyActive: event.onlyActive)
        .listen(
          (services) => add(ServicesUpdated(services)),
          onError: (e) => add(ServicesFailed('Error al cargar servicios')),
        );
  }

  void _onUpdated(ServicesUpdated event, Emitter<ServiceState> emit) {
    emit(ServiceLoaded(event.services));
  }

  void _onFailed(ServicesFailed event, Emitter<ServiceState> emit) {
    emit(ServiceError(event.message));
  }

  Future<void> _onCreate(CreateService event, Emitter<ServiceState> emit) async {
    try {
      await _repository.createService(event.service);
    } catch (_) {
      emit(ServiceError('No se pudo crear el servicio'));
    }
  }

  Future<void> _onUpdate(UpdateService event, Emitter<ServiceState> emit) async {
    try {
      await _repository.updateService(event.service);
    } catch (_) {
      emit(ServiceError('No se pudo actualizar el servicio'));
    }
  }

  Future<void> _onDelete(DeleteService event, Emitter<ServiceState> emit) async {
    try {
      await _repository.deleteService(event.id);
    } catch (_) {
      emit(ServiceError('No se pudo eliminar el servicio'));
    }
  }

  Future<void> _onToggle(
    ToggleServiceActive event,
    Emitter<ServiceState> emit,
  ) async {
    try {
      await _repository.toggleActive(event.id, event.isActive);
    } catch (_) {
      emit(ServiceError('No se pudo cambiar el estado'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
