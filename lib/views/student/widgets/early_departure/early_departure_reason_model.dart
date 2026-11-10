class EarlyDepartureReason {
  final String value;
  final String label;
  final String emoji;

  const EarlyDepartureReason({
    required this.value,
    required this.label,
    required this.emoji,
  });
}

const List<EarlyDepartureReason> kEarlyDepartureReasons = [
  EarlyDepartureReason(value: 'enfermedad', label: 'Enfermedad', emoji: '🤒'),
  EarlyDepartureReason(
      value: 'imprevisto', label: 'Imprevisto personal', emoji: '⚡'),
  EarlyDepartureReason(
      value: 'familiar', label: 'Emergencia familiar', emoji: '👨‍👩‍👧'),
  EarlyDepartureReason(value: 'otra', label: 'Otra razón', emoji: '📝'),
];

