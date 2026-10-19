String $(Map<String, dynamic> c) => '''
@import Foundation;

typedef NS_ENUM(UInt8, CodecType) {
\t${c['types'].map((e) => 'CodecType${_capitalize(e['name'] as String)} = ${e['value']},').join('\n\t')}
};


// flutter platform channel method names
${c['methods'].map((e) => 'extern NSString *const AblyPlatformMethod_${e['name']};').join('\n')}

${c['objects'].map((e) => '''
// key constants for ${e['name']}
${e['properties'].map((name) => 'extern NSString *const Tx${e['name']}_$name;').join('\n')}
''').join('\n')}''';

String _capitalize(String sentence) =>
    '${sentence[0].toUpperCase()}${sentence.substring(1)}';
