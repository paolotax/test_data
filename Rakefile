# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'

Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'youpropa'

  app.device_family = [:iphone, :ipad]
  app.icons = ["appicon.png", "appicon@2x.png", "appicon~ipad.png", "appicon~ipad@2x.png"]

  #app.fonts += ["Cassannet.ttf"]

  app.provisioning_profile = '/Users/paolotax/Library/MobileDevice/Provisioning Profiles/1D9EC448-6330-4E22-91BB-861E0E1433F3.mobileprovision' 
  app.codesign_certificate = 'iPhone Developer: Paolo Tassinari (9L6JUZD52Q)' 


  app.frameworks << 'CFNetwork'
  app.frameworks << 'CoreData'
  app.frameworks << 'QuartzCore'
  app.frameworks << 'AddressBook'
  app.frameworks << 'CoreLocation'
  app.frameworks << 'MapKit'
  app.frameworks << 'EventKit'

  app.pods do
    pod 'RestKit', :git => "https://github.com/RestKit/RestKit.git", commit: 'ee00e59'
    pod 'SVProgressHUD'
    pod 'NVUIGradientButton'
    pod 'NVSlideMenuController'
    pod 'CustomBadge'
  end

  app.vendor_project('vendor/MTLabel', :xcode, :target => 'MTLabel', :headers_dir => 'MTLabel')
  
end
