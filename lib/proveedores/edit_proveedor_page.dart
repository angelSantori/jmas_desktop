import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  //Nombre
                  CustomTextFielTexto(
                    controller: _nameController,
                    labelText: 'Nombre',
                    prefixIcon: Icons.person_2_rounded,
                    validator: (provName) {
                      if (provName == null || provName.isEmpty) {
                        return 'Nombre proveedor obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Dirección
                  CustomTextFielTexto(
                    controller: _direccionController,
                    labelText: 'Dirección',
                    prefixIcon: Icons.location_on,
                    validator: (provDir) {
                      if (provDir == null || provDir.isEmpty) {
                        return 'Dirección obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Phone
                  CustomTextFielTexto(
                    controller: _phoneController,
                    labelText: 'Teléfono',
                    prefixIcon: Icons.phone,
                    validator: (provPh) {
                      if (provPh == null || provPh.isEmpty) {
                        return 'Teléfono obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

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
