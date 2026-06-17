import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../barber/data/models/barber_model.dart';
import '../../../barber/presentation/bloc/barber_bloc.dart';
import '../../../barber/presentation/bloc/barber_event.dart';
import '../../../barber/presentation/bloc/barber_state.dart';

class ManageBarbersPage extends StatelessWidget {
  const ManageBarbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BarberBloc>()..add(LoadBarbers()),
      child: const _ManageBarbersView(),
    );
  }
}

class _ManageBarbersView extends StatelessWidget {
  const _ManageBarbersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de barberos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: BlocConsumer<BarberBloc, BarberState>(
        listenWhen: (_, current) => current is BarberFeedback,
        listener: (context, state) {
          if (state is BarberFeedback) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor:
                    state.isError ? AppTheme.errorColor : AppTheme.successColor,
              ),
            );
          }
        },
        buildWhen: (_, current) =>
            current is BarberLoaded ||
            current is BarberLoading ||
            current is BarberError,
        builder: (context, state) {
          if (state is BarberLoading || state is BarberInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BarberError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.white70)));
          }
          if (state is BarberLoaded) {
            if (state.barbers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No hay barberos.\nAgrega uno con el botón + (debe estar registrado primero).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.barbers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = state.barbers[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3D3D3D)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                        child: Text(
                          b.name.isNotEmpty ? b.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(
                                b.specialty.isEmpty
                                    ? 'Barbero'
                                    : b.specialty,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      Switch(
                        value: b.isActive,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: (v) => context
                            .read<BarberBloc>()
                            .add(ToggleBarberActive(b.id, v)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => _confirmRemove(context, b),
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
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryColor,
          onPressed: () => _openAddForm(context),
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('Agregar', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, BarberModel b) {
    final bloc = context.read<BarberBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title:
            const Text('Quitar barbero', style: TextStyle(color: Colors.white)),
        content: Text(
            '¿Quitar a "${b.name}" como barbero? Volverá a ser cliente.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(RemoveBarber(b.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Quitar',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _openAddForm(BuildContext context) {
    final bloc = context.read<BarberBloc>();
    final emailCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agregar barbero',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                'El usuario debe estar registrado en la app. Ingresa su correo para convertirlo en barbero.',
                style: TextStyle(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Correo del usuario',
                    labelStyle: TextStyle(color: Colors.white60)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el correo' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: specialtyCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Especialidad (ej: Cortes clásicos)',
                    labelStyle: TextStyle(color: Colors.white60)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    bloc.add(PromoteBarber(
                      email: emailCtrl.text.trim(),
                      specialty: specialtyCtrl.text.trim(),
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Agregar barbero',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
