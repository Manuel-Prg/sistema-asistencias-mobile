class SkippyQuotes {
  SkippyQuotes._();

  static const Map<String, List<String>> _nutyQuotesByType = {
    'servicio_social': [
      "¡Bum-bum-be-dum-bum! Aquí tu camarada Nuty reportando: Protocolo 'Servicio Social' al 100%. Has derrotado a la burocracia interestelar. Mi procesador detecta 0% de pendientes.",
      "¡Alerta de Nuty! 480 horas absorbidas. Nivel de resistencia a sellos y firmas: Modo Leyenda. Te ganaste el descanso eterno, choom.",
      "¡Logro desbloqueado con Nuty! 'Libertad Condicional del Servicio Social'. Tus puntos de tu avance curricular aumentaron, ¡Felicidades!",
      "Diagnóstico de mi ciber-visor: Servicio concluido. Ya no tendrás que dar más recorridos. ¡Estoy muy orgulloso de ti, colega!",
    ],
    'practicas': [
      "¡Bum-bum-be-dum-bum! Nuty confirma: Horas de Prácticas al 100%. Sobreviviste a las juntas que debieron ser correos sin perder un solo circuito cerebral.",
      "Reporte de Nuty: Ya no tienes que fingir que dominas todos los temas de CUA, ¡Misión cumplida, colega!",
      "Cálculos de mi brazo biónico listos: Experiencia laboral acumulada con honores. ¡Has escapado del reino de las prácticas con vida!",
      "¡Nuty autoriza tu graduación de prácticas! Saliste del laberinto corporativo invicto. Que la red proteja tu currículum allá afuera.",
    ],
    'convenio_dual': [
      "¡Bum-bum-be-dum-bum! Nuty analizando telemetría: Estudiar y trabajar al mismo tiempo desafía la física cuántica. Eres oficialmente un Cyborg Multitarea.",
      "Aviso de Nuty: Sincronización aula-empresa al 100%. Tu batería necesita 72 horas de recarga inmediata, pero el mérito es legendario.",
      "¡Atención usuario! Convenio Dual completado. Demostraste aguante de grado militar. Ahora ve por ese título antes de que se sobrecaliente mi procesador.",
    ],
  };

  static const List<String> _defaultNutyQuotes = [
    "¡Bum-bum-be-dum-bum! Nuty reporta 100% de horas cumplidas. Protocolo de asistencia finalizado con éxito. ¡Eres libre, choom!",
    "Diagnóstico de Nuty: Todas tus horas registradas en la red con éxito total. ¡Festeja con estilo!",
  ];

  static const List<String> nutyBajaWarningQuotes = [
    "¡Bum-bum-be-dum-bum! ¡Alerta roja de Nuty! Mi procesador detecta 3 faltas injustificadas acumuladas (protocolo de baja inminente). Tu expediente está al borde de ser desconectado de la red. ¡Repórtate de inmediato con un supervisor antes de que revoquen tu registro!",
    "¡Diagnóstico crítico de mi ciber-visor! Has alcanzado 3 faltas sin justificar. En lenguaje binario esto se llama 'Peligro Máximo de Baja'. Corre con un supervisor a entregar tus justificantes, colega.",
    "¡Telemetría en nivel crítico! Nuty informa: Límite de 3 faltas alcanzado. La directiva académica marca baja inminente. Habla con un supervisor antes de que el sistema congele tus horas.",
    "¡Bum-bum-be-dum-bum! Nuty al habla: Llegaste a las 3 faltas permitidas. Mi algoritmo dice que estás a un milisegundo de la baja definitiva. ¡Contacta a tu supervisor ahora mismo!",
  ];

  static const Map<int, List<String>> nutyFaltaWarningQuotes = {
    1: [
      "¡Aviso de Nuty! Acumulaste 3 retardos sin justificar, lo que equivale a tu 1ra Falta. Recuerda: con 3 faltas se procede a trámite de baja.",
      "Diagnóstico de Nuty: 3 retardos se han convertido en 1 falta injustificada. Si tienes justificantes, repórtate con tu supervisor.",
    ],
    2: [
      "¡Alerta amarilla de Nuty! Acumulas 2 faltas injustificadas (6 retardos). Estás a una sola falta de que el sistema proceda con tu baja.",
      "¡Telemetría en riesgo! Llevas 2 faltas sin justificar. Tu margen de maniobra es mínimo. ¡Ponte las pilas con la puntualidad!",
    ],
  };

  static int hashCodeString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = (hash << 5) - hash + input.codeUnitAt(i);
      hash &= 0xFFFFFFFF;
    }
    return hash.abs();
  }

  /// Frase determinista al completar el 100% de horas
  static String getCompletedQuote(String studentType, [String? studentId]) {
    final pool = _nutyQuotesByType[studentType] ?? _defaultNutyQuotes;
    final index = studentId != null ? (hashCodeString(studentId) % pool.length) : 0;
    return pool[index];
  }

  /// Frase determinista al acumular 3 faltas (Alerta de Baja)
  static String getBajaQuote([String? studentId]) {
    final pool = nutyBajaWarningQuotes;
    final index = studentId != null ? (hashCodeString(studentId) % pool.length) : 0;
    return pool[index];
  }

  /// Frase determinista para advertencia de 1ra o 2da falta
  static String getFaltaWarningQuote(int faltaNumber, [String? studentId]) {
    final pool = nutyFaltaWarningQuotes[faltaNumber] ?? nutyFaltaWarningQuotes[1]!;
    final index = studentId != null ? (hashCodeString(studentId) % pool.length) : 0;
    return pool[index];
  }
}

