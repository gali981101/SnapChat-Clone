# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  end
 end
end

target 'SnapChatClone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'Firebase'
  pod 'FirebaseAuth'
  pod 'FirebaseAnalytics'
  pod 'FirebaseFirestore'
  pod 'FirebaseCore'
  pod 'FirebaseStorage'
  pod 'IQKeyboardManagerSwift'
  pod 'Kingfisher'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod "ImageSlideshow/Kingfisher"

  # Pods for SnapChatClone

end
