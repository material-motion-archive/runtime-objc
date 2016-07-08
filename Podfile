abstract_target 'MaterialMotionRuntime' do
	pod 'MaterialMotionRuntime', :path => './'
  workspace 'MaterialMotionRuntime.xcworkspace'
	use_frameworks! 
	
	target "RuntimeTests" do
		project 'tests/apps/MDMRuntimeTests/RuntimeTests.xcodeproj'
	end
	
	target "PlanCatalog" do
		project 'examples/apps/PlanCatalog/PlanCatalog.xcodeproj'
	end
end
