import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/settings.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<SettingsBloc>()..add(const LoadSettings()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsLoaded) {
              return _SettingsForm(settings: state.settings);
            }
            if (state is SettingsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  final Settings settings;

  const _SettingsForm({required this.settings});

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late final TextEditingController _businessNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _prefixController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _businessNameController =
        TextEditingController(text: widget.settings.businessName);
    _addressController =
        TextEditingController(text: widget.settings.address);
    _phoneController =
        TextEditingController(text: widget.settings.phone);
    _prefixController =
        TextEditingController(text: widget.settings.invoicePrefix);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(labelText: 'Business Name'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prefixController,
            decoration: const InputDecoration(labelText: 'Invoice Prefix'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.settings.copyWith(
      businessName: _businessNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      invoicePrefix: _prefixController.text.trim(),
    );

    context.read<SettingsBloc>().add(UpdateSettings(updated));
    Navigator.pop(context);
  }
}
