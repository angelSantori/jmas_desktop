import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CustomTextFieldAzul extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.blue.shade900),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue.shade900,
                  ),
                  onPressed: onVisibilityToggle,
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
        validator: validator,
        obscureText: isPassword && !isVisible,
        inputFormatters: isPassword
            ? null
            : [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      ),
    );
  }
}

class CustomTextFielTexto extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.blue.shade900),
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
        validator: validator,
      ),
    );
  }
}

class CustomTextFieldNumero extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.blue.shade900),
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
        validator: validator,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
      ),
    );
  }
}

class CustomListaDesplegable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
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
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
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
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                selectedImage!.path,
                height: 180,
                width: 180,
                fit: BoxFit.cover,
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

class CustomListaDesplegableTipo<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
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
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemLabelBuilder(item)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
