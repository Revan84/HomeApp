String ageLabel(DateTime? t) {
  if (t == null) return '';
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 10) return "Mis à jour à l’instant";
  if (d.inMinutes < 1) return "Mis à jour il y a ${d.inSeconds}s";
  if (d.inHours < 1) return "Mis à jour il y a ${d.inMinutes} min";
  return "Mis à jour il y a ${d.inHours} h";
}
