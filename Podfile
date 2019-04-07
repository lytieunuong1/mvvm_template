# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MVVMTemplate' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ios-project1template-mvvm
pod 'Alamofire', '~> 4.5.0'
#pod 'ObjectMapper', '~> 3.1.0'
pod 'EVReflection', '~> 5.5.1'
pod 'RxSwift',    '~> 4.0.0'
pod 'RxCocoa',    '~> 4.0.0'
pod 'TNSocialNetWorkLogin'
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
  target 'MVVMTemplateTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MVVMTemplateUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
