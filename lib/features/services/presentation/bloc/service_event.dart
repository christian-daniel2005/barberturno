import '../../data/models/service_model.dart';

abstract class ServiceEvent {}

class LoadServices extends ServiceEvent {
  final bool onlyActive;
  LoadServices({this.onlyActive = false});
}

class ServicesUpdated extends ServiceEvent {
  final List<ServiceModel> services;
  ServicesUpdated(this.services);
}

class ServicesFailed extends ServiceEvent {
  final String message;
  ServicesFailed(this.message);
}

class CreateService extends ServiceEvent {
  final ServiceModel service;
  CreateService(this.service);
}

class UpdateService extends ServiceEvent {
  final ServiceModel service;
  UpdateService(this.service);
}

class DeleteService extends ServiceEvent {
  final String id;
  DeleteService(this.id);
}

class ToggleServiceActive extends ServiceEvent {
  final String id;
  final bool isActive;
  ToggleServiceActive(this.id, this.isActive);
}
