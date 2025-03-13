import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CustomTextFieldAzul extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onVisibilityToggle;
  final IconData prefixIcon;

  const CustomTextFieldAzul({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.isVisible = false,
    this.onVisibilityToggle,
    this.prefixIcon = Icons.text_fields,
  }) : super(key: key);

  @override
  State<CustomTextFieldAzul> createState() => _CustomTextFieldAzulState();
}

class _CustomTextFieldAzulState extends State<CustomTextFieldAzul>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        widget.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue.shade900,
                      ),
                      onPressed: widget.onVisibilityToggle,
                    )
                  : null,
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            validator: widget.validator,
            obscureText: widget.isPassword && !widget.isVisible,
            inputFormatters: widget.isPassword
                ? null
                : [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          ),
        ),
      ),
    );
  }
}

class CustomTextFielTexto extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final IconData prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFielTexto({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.prefixIcon = Icons.text_fields,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomTextFielTexto> createState() => _CustomTextFielTextoState();
}

class _CustomTextFielTextoState extends State<CustomTextFielTexto>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}

class CustomTextFielFecha extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final IconData prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback onTap;

  const CustomTextFielFecha({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.prefixIcon = Icons.calendar_today,
    this.inputFormatters,
    required this.onTap, // Se requiere el callback
  }) : super(key: key);

  @override
  State<CustomTextFielFecha> createState() => _CustomTextFielFechaState();
}

class _CustomTextFielFechaState extends State<CustomTextFielFecha>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            inputFormatters: widget.inputFormatters,
            readOnly: true, // Hace que el campo sea de solo lectura
            onTap: widget.onTap, // Llama al callback cuando se toca el campo
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}

class CustomTextFieldNumero extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final IconData prefixIcon;

  const CustomTextFieldNumero({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomTextFieldNumero> createState() => _CustomTextFieldNumeroState();
}

class _CustomTextFieldNumeroState extends State<CustomTextFieldNumero>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            validator: widget.validator,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomListaDesplegable extends StatefulWidget {
  final String? value;
  final String labelText;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final IconData icon;

  const CustomListaDesplegable({
    Key? key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon = Icons.arrow_drop_down,
  }) : super(key: key);

  @override
  State<CustomListaDesplegable> createState() => _CustomListaDesplegableState();
}

class _CustomListaDesplegableState extends State<CustomListaDesplegable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: widget.value,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            items: widget.items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}

class CustomImagePicker extends StatelessWidget {
  final VoidCallback onPickImage;
  final XFile? selectedImage;
  final String buttonText;
  final String? Function()? validator;

  const CustomImagePicker({
    Key? key,
    required this.onPickImage,
    required this.selectedImage,
    this.buttonText = 'Seleccionar imagen',
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (selectedImage != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900, // Color de la sombra
                  blurRadius: 8, // Difuminado de la sombra
                  offset: Offset(0, 4), // Desplazamiento de la sombra
                ),
              ],
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  selectedImage!.path,
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        else
          Center(
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'No hay imagen seleccionada',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20), // Espacio entre la imagen y el botón
        Center(
          child: ElevatedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.image, color: Colors.white),
            label: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: Colors.blue.shade900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (validator != null)
          Center(
            child: Text(
              validator!() ?? '',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

class CustomListaDesplegableTipo<T> extends StatefulWidget {
  final T? value;
  final String labelText;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData icon;
  final String Function(T) itemLabelBuilder;

  const CustomListaDesplegableTipo({
    Key? key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon = Icons.arrow_drop_down,
    required this.itemLabelBuilder,
  }) : super(key: key);

  @override
  State<CustomListaDesplegableTipo<T>> createState() =>
      _CustomListaDesplegableTipoState<T>();
}

class _CustomListaDesplegableTipoState<T>
    extends State<CustomListaDesplegableTipo<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis),
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            items: widget.items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(widget.itemLabelBuilder(item)),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}
