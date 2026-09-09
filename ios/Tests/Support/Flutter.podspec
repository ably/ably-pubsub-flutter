#
# Development-only podspec. Not published, and not used when building an app.
#
# `pod lib lint ably_flutter.podspec` has to resolve `s.dependency 'Flutter'` from
# somewhere, and neither available option works for us:
#
#   * The `Flutter` pod published to CocoaPods trunk is pinned at 3.13.0, which
#     predates the UIScene plugin APIs (`FlutterSceneLifeCycleDelegate` and
#     `FlutterPluginRegistrar.addSceneDelegate:`, added in 3.38). Linting against it
#     fails to find those declarations.
#   * The `Flutter.podspec` that Flutter tooling generates inside an app project is a
#     placeholder with no headers at all, because real builds link the framework via
#     xcconfig rather than CocoaPods.
#
# So point CocoaPods at the engine artifacts of whichever Flutter SDK is on PATH, and
# pass this file to lint with `--include-podspecs`. See .github/workflows/ios_unit_tests.yml.
#

flutter_root = ENV['FLUTTER_ROOT']
if flutter_root.nil? || flutter_root.empty?
  require 'json'
  version_output = `flutter --version --machine`
  raise 'Could not run `flutter --version --machine`; set FLUTTER_ROOT or put flutter on PATH.' unless $?.success?
  flutter_root = JSON.parse(version_output)['flutterRoot']
end

engine_dir = File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios')
framework = File.join(engine_dir, 'Flutter.xcframework')
unless File.exist?(framework)
  raise "#{framework} is missing. Run `flutter precache --ios` first."
end

# CocoaPods rejects absolute file patterns and silently drops relative ones that
# escape the pod root, so link the framework in next to this podspec. `engine/` is
# gitignored.
require 'fileutils'
link_dir = File.join(__dir__, 'engine')
FileUtils.mkdir_p(link_dir)
link = File.join(link_dir, 'Flutter.xcframework')
FileUtils.rm_f(link)
File.symlink(framework, link)

Pod::Spec.new do |s|
  s.name             = 'Flutter'
  s.version          = '1.0.0'
  s.summary          = 'Local Flutter engine artifacts, for linting this plugin only.'
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://flutter.dev' }
  s.platform         = :ios
  s.ios.deployment_target = '13.0'
  s.vendored_frameworks = 'engine/Flutter.xcframework'
end
