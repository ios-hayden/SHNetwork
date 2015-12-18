Pod::Spec.new do |s|

  s.name         = "SHNetwork"
  s.version      = "0.1.0"
  s.summary      = "基于AFNetworking封装的网络请求库，使用中间件机制"

  s.description  = <<-DESC
                   基于AFNetworking封装的网络请求库，使用中间件机制.
                   DESC

  s.homepage     = "https://github.com/superhayden/SHNetwork"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.license      = "MIT"
  s.author             = { "SuperHayden" => "admin@yardlan.com" }
  
  s.platform     = :ios, "7.0"

  s.source       = { :git => "git@github.com:superhayden/SHNetwork.git", :tag => "0.1.0" }


  s.source_files  = "SHNetwork/**/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  s.public_header_files = "SHNetwork/SHNetwork.h"

  #s.resources = "SHNetwork/**/*"

  #s.framework  = "CoreData"
  
  s.requires_arc = true

  s.dependency "AFNetworking", "~> 3.0.3"

end