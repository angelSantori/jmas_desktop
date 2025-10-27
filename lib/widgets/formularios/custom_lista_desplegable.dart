import 'package:flutter/material.dart';

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
