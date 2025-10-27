import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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