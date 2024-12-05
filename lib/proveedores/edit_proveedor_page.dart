import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditProveedorPage extends StatefulWidget {
  final Proveedores proveedor;
  const EditProveedorPage({super.key, required this.proveedor});

  @override
  State<EditProveedorPage> createState() => _EditProveedorPageState();
}

class _EditProveedorPageState extends State<EditProveedorPage> {
  final ProveedoresController _proveedoresController = ProveedoresController();
  final _formkey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _direccionController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.proveedor.proveedor_Name);
    _direccionController =
        TextEditingController(text: widget.proveedor.proveedor_Address);
    _phoneController =
        TextEditingController(text: widget.proveedor.proveedor_Phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _direccionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      final updateProveedor = widget.proveedor.copyWith(
        proveedor_Name: _nameController.text,
        proveedor_Address: _direccionController.text,
        proveedor_Phone: _phoneController.text,
      );

      final result =
          await _proveedoresController.editProveedor(updateProveedor);
      setState(() {
        _isLoading = false;
      });
      if (result) {
        await showOk(context, 'Proveedor editado correctamente.');
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al editar el proveedor');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Proveedor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  //Nombre
                  buildFormRow(
                    label: 'Nombre:',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre del proveedor no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Dirección
                  buildFormRow(
                    label: 'Dirección:',
                    child: TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La dirección del proveedor no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Phone
                  buildFormRow(
                    label: 'Telefono:',
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Telefono'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El telefono del proveedor no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Botón
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
