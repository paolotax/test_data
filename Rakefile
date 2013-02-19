# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'

Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'test_data'

  app.device_family = [:iphone, :ipad]
  app.icons = ["appicon.png", "appicon@2x.png", "appicon~ipad.png", "appicon~ipad@2x.png"]

  app.provisioning_profile = '/Users/paolotax/Library/MobileDevice/Provisioning Profiles/EA8F07F2-DB5C-43D5-A722-BEF7C43408FB.mobileprovision' 
  app.codesign_certificate = 'iPhone Developer: Paolo Tassinari (9L6JUZD52Q)' 


  app.frameworks << 'CFNetwork'
  app.frameworks << 'CoreData'
  app.frameworks << 'QuartzCore'
  
  app.pods do
    pod 'RestKit', :git => "https://github.com/RestKit/RestKit.git", commit: 'ee00e59'
    pod 'SVProgressHUD'
    pod 'NVUIGradientButton'
    pod 'CustomBadge'
  end
end
