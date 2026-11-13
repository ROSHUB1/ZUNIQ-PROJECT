const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsFil = ['Ene', 'Peb', 'Mar', 'Abr', 'May', 'Hun', 'Hul', 'Ago', 'Set', 'Okt', 'Nob', 'Dis'];

String formatDate(DateTime d, [String uiCode = 'en']) =>
    '${(uiCode == 'fil' ? _monthsFil : _months)[d.month - 1]} ${d.day}, ${d.year}';

String prettyType(String t) {
  final s = t.replaceAll('_', ' ').trim();
  if (s.isEmpty) return 'Document';
  return s[0].toUpperCase() + s.substring(1);
}
