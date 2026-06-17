import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/presentation/bloc/service_bloc.dart';
import '../../../services/presentation/bloc/service_event.dart';
import '../../../services/presentation/bloc/service_state.dart';

class ManageServicesPage extends StatelessWidget {
  const ManageServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServiceBloc>()..add(LoadServices()),
      child: const _ManageServicesView(),
    );
  }
}

class _ManageServicesView extends StatelessWidget {
  const _ManageServicesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de servicios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading || state is ServiceInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ServiceLoaded) {
            if (state.services.isEmpty) {
              return Center(
                child: Text('No hay servicios. Crea el primero con el botón +',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final s = state.services[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: s.isActive
                          ? const Color(0xFF3D3D3D)
                          : AppTheme.errorColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(s.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                if (!s.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Inactivo',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.errorColor)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'S/ ${s.price.toStringAsFixed(2)}  •  ${s.durationMinutes} min',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      Switch(
                        value: s.isActive,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: (v) => context
                            .read<ServiceBloc>()
                            .add(ToggleServiceActive(s.id, v)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white54),
                        onPressed: () => _openForm(context, service: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => _confirmDelete(context, s),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceModel s) {
    final bloc = context.read<ServiceBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Eliminar servicio',
            style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${s.name}"? Esta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteService(s.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {ServiceModel? service}) {
    final bloc = context.read<ServiceBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ServiceForm(bloc: bloc, service: service),
    );
  }
}

class _ServiceForm extends StatefulWidget {
  final ServiceBloc bloc;
  final ServiceModel? service;

  const _ServiceForm({required this.bloc, this.service});

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _duration;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.service?.name ?? '');
    _desc = TextEditingController(text: widget.service?.description ?? '');
    _price =
        TextEditingController(text: widget.service?.price.toString() ?? '');
    _duration = TextEditingController(
        text: widget.service?.durationMinutes.toString() ?? '30');
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final model = ServiceModel(
      id: widget.service?.id ?? '',
      name: _name.text.trim(),
      description: _desc.text.trim(),
      price: double.parse(_price.text),
      durationMinutes: int.parse(_duration.text),
      isActive: widget.service?.isActive ?? true,
    );
    if (_isEdit) {
      widget.bloc.add(UpdateService(model));
    } else {
      widget.bloc.add(CreateService(model));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isEdit ? 'Editar servicio' : 'Nuevo servicio',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Nombre', labelStyle: TextStyle(color: Colors.white60)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _desc,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white60)),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa la descripción'
                  : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Precio (S/)',
                        labelStyle: TextStyle(color: Colors.white60)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (double.tryParse(v) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Duración (min)',
                        labelStyle: TextStyle(color: Colors.white60)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (int.tryParse(v) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEdit ? 'Guardar cambios' : 'Crear servicio',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
