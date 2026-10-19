String $(Map<String, dynamic> c) => '''
#import "AblyPlatformConstants.h"


// flutter platform channel method names
${c['methods'].map((e) => 'NSString *const AblyPlatformMethod_${e['name']}= @"${e['value']}";').join('\n')}

${c['objects'].map((e) => '''
// key constants for ${e['name']}
${e['properties'].map((name) => 'NSString *const Tx${e['name']}_$name = @"$name";').join('\n')}
''').join('\n')}''';
