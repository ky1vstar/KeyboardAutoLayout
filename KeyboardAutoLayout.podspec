Pod::Spec.new do |s|
  s.name                      = "KeyboardAutoLayout"
  s.version                   = ENV["LIB_VERSION"] || "1.0.0"
  s.summary                   = "KeyboardAutoLayout"
  s.homepage                  = "https://github.com/ky1vstar/KeyboardAutoLayout"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "ky1vstar" => "general@ky1vstar.dev" }
  s.source                    = { :git => "https://github.com/ky1vstar/KeyboardAutoLayout.git", :tag => s.version.to_s }
  s.swift_version             = "5.0"
  s.ios.deployment_target     = "10.0"
  s.source_files              = "Sources/**/*"
  s.frameworks                = ["Foundation", "UIKit"]
end
