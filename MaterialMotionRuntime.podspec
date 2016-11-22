Pod::Spec.new do |s|
  s.name         = "MaterialMotionRuntime"
  s.summary      = "Material Motion Runtime for Apple Devices"
  s.version      = "6.0.1"
  s.authors      = "The Material Motion Authors."
  s.license      = "Apache 2.0"
  s.homepage     = "https://github.com/material-motion/material-motion-runtime-objc"
  s.source       = { :git => "https://github.com/material-motion/material-motion-runtime-objc.git", :tag => "v" + s.version.to_s }
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.default_subspec = "lib"

  s.subspec "lib" do |ss|
    ss.public_header_files = "src/*.h"
    ss.private_header_files = "src/private/*.h"
    ss.source_files = "src/*.{h,m}", "src/private/*.{h,m}"
  end

  s.subspec "tests" do |ss|
    ss.source_files = "tests/src/*.{swift}", "tests/src/private/*.{swift}"
    ss.dependency "MaterialMotionRuntime/lib"
  end
end
