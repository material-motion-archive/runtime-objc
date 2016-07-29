abstract_target 'MaterialMotionRuntime' do
  pod 'MaterialMotionRuntime', :path => './'
  workspace 'MaterialMotionRuntime.xcworkspace'
  use_frameworks!

  target "UnitTests" do
    project 'examples/apps/Catalog/Catalog.xcodeproj'
  end

  target "Catalog" do
    project 'examples/apps/Catalog/Catalog.xcodeproj'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        configuration.build_settings['SWIFT_VERSION'] = "3.0"
      end
    end
  end
end
