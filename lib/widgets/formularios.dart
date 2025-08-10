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
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CustomTextFielTexto({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.prefixIcon = Icons.text_fields,
    this.inputFormatters,
    this.enabled = true,
    this.onChanged,
  });

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
            enabled: widget.enabled,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.enabled
                    ? Colors.blue.shade900
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor:
                  widget.enabled ? Colors.blue.shade50 : Colors.grey.shade200,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabled
                        ? Colors.blue.shade200
                        : Colors.grey.shade400,
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabled
                        ? Colors.blue.shade900
                        : Colors.grey.shade600,
                    width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: widget.enabled ? Colors.black : Colors.grey.shade600,
            ),
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
  final bool enabled;
  final VoidCallback onTap;

  const CustomTextFielFecha({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.prefixIcon = Icons.calendar_today,
    this.enabled = true,
    this.inputFormatters,
    required this.onTap, // Se requiere el callback
  });

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
            enabled: widget.enabled,
            inputFormatters: widget.inputFormatters,
            readOnly: true, // Hace que el campo sea de solo lectura
            onTap: widget.onTap, // Llama al callback cuando se toca el campo
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.enabled
                    ? Colors.blue.shade900
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor:
                  widget.enabled ? Colors.blue.shade50 : Colors.grey.shade200,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabled
                        ? Colors.blue.shade200
                        : Colors.grey.shade200,
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabled
                        ? Colors.blue.shade900
                        : Colors.grey.shade600,
                    width: 2.0),
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
            style: TextStyle(
                fontSize: 18,
                color: widget.enabled ? Colors.black : Colors.grey.shade600),
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
  final bool allowNegative;
  final bool isDecimal;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final void Function(String)? onChanged;

  const CustomTextFieldNumero({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.allowNegative = false,
    this.isDecimal = true,
    this.enabled = true,
    this.onChanged,
  });

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
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.enabled
                    ? Colors.blue.shade900
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor:
                  widget.enabled ? Colors.blue.shade50 : Colors.grey.shade200,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabled
                        ? Colors.blue.shade200
                        : Colors.grey.shade400,
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabled
                        ? Colors.blue.shade900
                        : Colors.grey.shade600,
                    width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: widget.enabled ? Colors.black : Colors.grey.shade600,
            ),
            validator: widget.validator,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.isDecimal,
              signed: widget.allowNegative,
            ),
            inputFormatters: [
              // Opcional: Filtra caracteres no numéricos (excepto '-' si allowNegative=true)
              FilteringTextInputFormatter.allow(
                widget.allowNegative
                    ? RegExp(
                        r'^-?\d*\.?\d*') // Permite números negativos y decimales
                    : RegExp(
                        r'^\d*\.?\d*'), // Solo números positivos y decimales
              )
            ],
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
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
  final bool enabled;
  final IconData icon;

  const CustomListaDesplegable({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.icon = Icons.arrow_drop_down,
  });

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
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _animation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.enabled
                      ? Colors.blue.shade900
                      : Colors.grey.shade600,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: widget.value,
              icon: Icon(
                widget.icon,
                color: widget.enabled
                    ? Colors.blue.shade900
                    : Colors.grey.shade600,
              ),
              style: TextStyle(
                fontSize: 14,
                color: widget.enabled ? Colors.black : Colors.grey.shade600,
              ),
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: widget.enabled
                      ? Colors.blue.shade900
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                filled: true,
                fillColor:
                    widget.enabled ? Colors.blue.shade50 : Colors.grey.shade200,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: widget.enabled
                          ? Colors.blue.shade200
                          : Colors.grey.shade400,
                      width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: widget.enabled
                          ? Colors.blue.shade900
                          : Colors.grey.shade600,
                      width: 2.0),
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.enabled
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.enabled ? widget.onChanged : null,
              validator: widget.validator,
            ),
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
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon = Icons.arrow_drop_down,
    required this.itemLabelBuilder,
  });

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
      duration: const Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: const Offset(0, -1), // Comienza fuera de la pantalla (arriba)
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
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900, // Color de la sombra
                  blurRadius: 8, // Difuminado de la sombra
                  offset: const Offset(0, 4), // Desplazamiento de la sombra
                ),
              ],
            ),
            child: DropdownButtonFormField<T>(
              isExpanded: true,
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
                  borderSide:
                      BorderSide(color: Colors.blue.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.blue.shade900, width: 2.0),
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: Text(
                      widget.itemLabelBuilder(item),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.onChanged,
              validator: widget.validator,
            ),
          ),
        ),
      ),
    );
  }
}

//Autocomplete
class CustomAutocomplete<T extends Object> extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final List<T> options;
  final String Function(T) displayStringForOption;
  final void Function(T?) onSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onSelectionConfirmed;
  final bool clearOnSelect;

  const CustomAutocomplete({
    super.key,
    required this.controller,
    required this.labelText,
    required this.options,
    required this.displayStringForOption,
    required this.onSelected,
    this.validator,
    this.enabled = true,
    this.onSelectionConfirmed,
    this.clearOnSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return Iterable<T>.empty();
        }
        return options.where((T option) {
          return displayStringForOption(option)
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (T selection) {
        // Notificar la selección primero
        onSelected(selection);

        // Limpiar el campo si es necesario
        if (clearOnSelect) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.clear();
          });
        } else {
          controller.text = displayStringForOption(selection);
        }

        // Ejecutar callback de confirmación
        onSelectionConfirmed?.call();
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        // Sincronizar nuestro controlador con el interno de Autocomplete
        controller.addListener(() {
          if (controller.text != fieldTextEditingController.text) {
            fieldTextEditingController.text = controller.text;
          }
        });

        return TextFormField(
          controller:
              fieldTextEditingController, // Usamos el controlador interno
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      fieldTextEditingController.clear();
                      onSelected(null);
                    },
                  )
                : null,
          ),
          validator: validator,
          enabled: enabled,
          onChanged: (value) {
            // Sincronizar ambos controladores
            if (controller.text != value) {
              controller.text = value;
            }
            if (value.isEmpty) {
              onSelected(null);
            }
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(displayStringForOption(option)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
