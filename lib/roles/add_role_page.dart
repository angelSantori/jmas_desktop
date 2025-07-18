import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/role_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddRolePage extends StatefulWidget {
  const AddRolePage({super.key});

  @override
  State<AddRolePage> createState() => _AddRolePageState();
}

class _AddRolePageState extends State<AddRolePage> {
  final RoleController _roleController = RoleController();

  final TextEditingController _roleNombreContr = TextEditingController();
  final TextEditingController _roleDescContr = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submitForm() async {
    setState(() => _isLoading = true);
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newRol = Role(
          idRole: 0,
          roleNombre: _roleNombreContr.text,
          roleDescr: _roleDescContr.text,
          canView: false,
          canAdd: false,
          canEdit: false,
          canDelete: false,
          canManageUsers: false,
          canManageRoles: false,
          canEvaluar: false,
        );

        final success = await _roleController.addRol(newRol);

        if (success) {
          showOk(context, 'Rol registrado correctamente.');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar el rol.');
        }
      } catch (e) {
        showAdvertence(
            context, 'Por favor complete todos los campos correctamente.');
      }
    } else {
      showAdvertence(
          context, 'Por favor completa todos los campos obligatorios.');
    }

    setState(() => _isLoading = false);
  }

  void _clearForm() {
    _roleNombreContr.clear();
    _roleDescContr.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Rol'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //Nombre
                  CustomTextFielTexto(
                    controller: _roleNombreContr,
                    labelText: 'Nombre del Rol',
                    validator: (nomRol) {
                      if (nomRol == null || nomRol.isEmpty) {
                        return 'Nombre es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  //Descr
                  CustomTextFielTexto(
                    controller: _roleDescContr,
                    labelText: 'Descripción del rol',
                    validator: (descRol) {
                      if (descRol == null || descRol.isEmpty) {
                        return 'Descripción es obligatoria.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Botón save
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      elevation: 8,
                      shadowColor: Colors.blue.shade900,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Registrar Rol',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
