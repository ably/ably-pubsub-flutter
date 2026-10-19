String getPrefix(String str) => (str.length > 26) ? '\n      ' : ' ';

String $(Map<String, dynamic> c) => '''
// ignore_for_file: public_member_api_docs

class CodecTypes {
${c['types'].map((e) => "  static const int ${e['name']} ="
        " ${e['value']};").join('\n')}
}

class PlatformMethod {
${c['methods'].map((e) => "  static const String ${e['name']} =${getPrefix(e['value'] as String)}'${e['value']}';").join('\n')}
}

${c['objects'].map((e) => '''
class Tx${e['name']} {
${e['properties'].map((_p) => "  static const String $_p = '$_p';").join('\n')}
}
''').join('\n')}''';
