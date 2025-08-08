import 'package:flutter/material.dart';

DateTime parseFecha(String fecha) {
  try {
    // Limpiar espacios adicionales y normalizar
    fecha = fecha.trim().toLowerCase();

    // Casos especiales con "a. m." o "p. m."
    if (fecha.contains("a. m.") || fecha.contains("p. m.")) {
      return parseFechaConAMPM(fecha);
    }

    // Separar fecha y hora
    final partes = fecha.split(' ');
    final fechaPart = partes[0];
    final horaPart = partes.length > 1 ? partes[1] : null;

    // Parsear la parte de la fecha
    final dateParts = fechaPart.split('/');
    if (dateParts.length != 3)
      throw FormatException("Formato de fecha inválido");

    int day, month, year;

    // Determinar el formato (DD/MM/YY o MM/DD/YYYY)
    if (dateParts[0].length <= 2 && dateParts[1].length <= 2) {
      // Formato DD/MM/YY o DD/MM/YYYY
      day = int.parse(dateParts[0]);
      month = int.parse(dateParts[1]);
      year = dateParts[2].length == 2
          ? 2000 + int.parse(dateParts[2])
          : int.parse(dateParts[2]);
    } else {
      // Formato MM/DD/YYYY
      month = int.parse(dateParts[0]);
      day = int.parse(dateParts[1]);
      year = int.parse(dateParts[2]);
    }

    // Si no hay hora, retornar solo la fecha
    if (horaPart == null || horaPart.isEmpty) {
      return DateTime(year, month, day);
    }

    // Parsear la hora si existe
    final timeParts = horaPart.split(':');
    if (timeParts.length < 2) throw FormatException("Formato de hora inválido");

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

    return DateTime(year, month, day, hour, minute, second);
  } catch (e) {
    print('Error al parsear fecha: "$fecha" - $e');
    return DateTime.now(); // Fallback
  }
}

DateTime parseFechaConAMPM(String fecha) {
  // Normalizar el string
  fecha = fecha.replaceAll("a. m.", "am").replaceAll("p. m.", "pm").trim();

  // Separar fecha y hora
  final partes = fecha.split(' ');
  final fechaPart = partes[0];
  final horaPart = partes.length > 1 ? partes[1] : null;
  final ampm = partes.length > 2 ? partes[2] : null;

  // Parsear la fecha
  final dateParts = fechaPart.split('/');
  if (dateParts.length != 3) throw FormatException("Formato de fecha inválido");

  int day, month, year;

  // Determinar formato de fecha (DD/MM/YYYY o MM/DD/YYYY)
  if (dateParts[0].length <= 2 && dateParts[1].length <= 2) {
    // Formato DD/MM/YYYY
    day = int.parse(dateParts[0]);
    month = int.parse(dateParts[1]);
    year = int.parse(dateParts[2]);
  } else {
    // Formato MM/DD/YYYY
    month = int.parse(dateParts[0]);
    day = int.parse(dateParts[1]);
    year = int.parse(dateParts[2]);
  }

  // Si no hay hora, retornar solo fecha
  if (horaPart == null || ampm == null) {
    return DateTime(year, month, day);
  }

  // Parsear la hora con AM/PM
  final timeParts = horaPart.split(':');
  if (timeParts.length < 2) throw FormatException("Formato de hora inválido");

  int hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);
  final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

  // Ajustar hora para formato 24h
  if (ampm == "pm" && hour < 12) {
    hour += 12;
  } else if (ampm == "am" && hour == 12) {
    hour = 0;
  }

  return DateTime(year, month, day, hour, minute, second);
}

String getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Enero';
    case 2:
      return 'Febrero';
    case 3:
      return 'Marzo';
    case 4:
      return 'Abril';
    case 5:
      return 'Mayo';
    case 6:
      return 'Junio';
    case 7:
      return 'Julio';
    case 8:
      return 'Agosto';
    case 9:
      return 'Septiembre';
    case 10:
      return 'Octubre';
    case 11:
      return 'Noviembre';
    case 12:
      return 'Diciembre';
    default:
      return '';
  }
}

class CustomListaDesplegableMes extends StatefulWidget {
  final String? value;
  final String labelText;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData icon;

  const CustomListaDesplegableMes({
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
  State<CustomListaDesplegableMes> createState() =>
      _CustomListaDesplegableMesState();
}

class _CustomListaDesplegableMesState extends State<CustomListaDesplegableMes>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
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

  String _getMonthImagePath(String? monthName) {
    if (monthName == null) return 'assets/calendar/calendario.png';
    return 'assets/calendar/${monthName.toLowerCase()}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Imagen del mes
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.asset(
            _getMonthImagePath(widget.value),
            height: 150,
            width: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),

        // Selector de mes
        SlideTransition(
          position: _animation,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9),
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
                    fillColor: widget.enabled
                        ? Colors.blue.shade50
                        : Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
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
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                  ),
                  items: widget.items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.8),
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.enabled
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
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
        ),
      ],
    );
  }
}
