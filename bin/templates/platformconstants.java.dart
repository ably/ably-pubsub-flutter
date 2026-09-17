String $(Map<String, dynamic> c) => '''
package io.ably.flutter.plugin.generated;


final public class PlatformConstants {

\tstatic final public class CodecTypes {
\t\t${c['types'].map((e) => 'public static final byte ${e['name']} = (byte) ${e['value']};').join('\n\t\t')}
\t}

\tstatic final public class PlatformMethod {
\t\t${c['methods'].map((e) => 'public static final String ${e['name']} = "${e['value']}";').join('\n\t\t')}
\t}

${c['objects'].map((e) => '''
\tstatic final public class Tx${e['name']} {
\t\t${e['properties'].map((_p) => 'public static final String $_p = "$_p";').join('\n\t\t')}
\t}
''').join('\n')}
}
''';
