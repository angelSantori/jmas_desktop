import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomAutocompleteField<T extends Object> extends StatefulWidget {
  final T? value;
  final String labelText;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T) itemLabelBuilder;
  final String Function(T) itemValueBuilder;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool showClearButton;

  const CustomAutocompleteField({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    required this.itemLabelBuilder,
    required this.itemValueBuilder,
    this.prefixIcon,
    this.validator,
    this.showClearButton = true,
  });

  @override
  State<CustomAutocompleteField<T>> createState() =>
      _CustomAutocompleteFieldState<T>();
}

class _CustomAutocompleteFieldState<T extends Object>
    extends State<CustomAutocompleteField<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showClearButton = false;

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
    _updateControllerText();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CustomAutocompleteField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    if (widget.value != null) {
      _controller.text = widget.itemLabelBuilder(widget.value!);
      _showClearButton = true;
    } else {
      _controller.clear();
      _showClearButton = false;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _controller.text.isNotEmpty) {
      final matchingItem = widget.items.cast<T?>().firstWhere(
            (item) =>
                item != null &&
                widget.itemLabelBuilder(item).toLowerCase() ==
                    _controller.text.toLowerCase(),
            orElse: () => null,
          );

      if (matchingItem == null) {
        _controller.clear();
        widget.onChanged(null);
        setState(() => _showClearButton = false);
      }
    }
  }

  void _clearSelection() {
    _controller.clear();
    widget.onChanged(null);
    setState(() => _showClearButton = false);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: TypeAheadField<T>(
        controller: _controller,
        focusNode: _focusNode,
        builder: (context, controller, focusNode) {
          return Container(
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
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
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
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: Colors.blue.shade900)
                    : null,
                suffixIcon: widget.showClearButton && _showClearButton
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _clearSelection,
                      )
                    : null,
              ),
              validator: widget.validator,
            ),
          );
        },
        suggestionsCallback: (pattern) async {
          if (pattern.isEmpty) {
            return [];
          }
          return widget.items.where((T option) {
            return widget
                .itemLabelBuilder(option)
                .toLowerCase()
                .contains(pattern.toLowerCase());
          }).toList();
        },
        itemBuilder: (context, T suggestion) {
          return ListTile(
            title: Text(widget.itemLabelBuilder(suggestion)),
          );
        },
        onSelected: (T suggestion) {
          widget.onChanged(suggestion);
          setState(() => _showClearButton = true);
        },
        // noItemsFoundBuilder: (context) => const Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: Text('No se encontraron elementos'),
        // ),
        loadingBuilder: (context) => const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
