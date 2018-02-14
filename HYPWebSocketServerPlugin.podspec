Pod::Spec.new do |s|

  s.name         = "HYPWebSocketServerPlugin"
  s.version      = "0.1.0"
  s.summary      = "An on device web socket server plugin for Hyperion"

  s.homepage     = "http://github.com/fuzzybinary/HYPWebSocketServerPlugin"

  s.license      = "MIT" 

  s.author       = { "Jeff Ward" => "jeff.ward@willowtreeapps.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/fuzzybinary/HYPWebSocketServerPlugin.git", :tag => "#{s.version}" }
  s.source_files  = "HYPWebSocketServerPlugin", "HYPWebSocketServerPlugin/**/*.{h,m}"
  s.resources = "HYPWebSocketServerPlugin/Resources/*.png"

  s.compiler_flags  = "-Wnon-modular-include-in-framework-module"
  s.ios.user_target_xcconfig = {
    "OTHER_LDFLAGS" => "-Wnon-modular-include-in-framework-module", 
    "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES"
  }

  s.dependency "HyperioniOS/Core"
  s.dependency "PocketSocket"

end
