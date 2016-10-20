Pod::Spec.new do |s|
     
  s.name         = "XEBEventBus"
  s.version      = "1.0"
  s.summary      = "XEBEventBus base on object-c versiobn "
  s.author       = { "chausson" => "232564026@qq.COM" }
  s.license      = "MIT"
  s.description  = "Command Mode apply on iOS project "
  s.homepage     = "https://github.com/chausson/XEBEventBus.git"
    
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/chausson/XEBEventBus.git", :tag => "1.0" }
    
  s.source_files  = "XEBEventBus/*.{h,m}"
    
end
