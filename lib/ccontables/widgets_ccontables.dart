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
