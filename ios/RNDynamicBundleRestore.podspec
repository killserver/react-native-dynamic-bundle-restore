
Pod::Spec.new do |s|
  s.name           = "RNDynamicBundleRestore"
  s.version        = "0.7.4"
  s.summary        = "RNDynamicBundleRestore"
  s.description    = <<-DESC
                  RNDynamicBundleRestore
                   DESC

  s.homepage       = "https://github.com/killserver/react-native-dynamic-bundle-restore"
  s.license        = "MIT"
  s.author         = { "author" => "killeserver@gmail.com" }
  s.platform       = :ios, "7.0"
  s.source         = { :git => "https://github.com/killserver/react-native-dynamic-bundle-restore.git", :tag => "master" }
  s.source_files   = '*.{h,m}'
  s.preserve_paths = "**/*.js"
  s.requires_arc   = true

  s.dependency "React"
  #s.dependency "others"

end
