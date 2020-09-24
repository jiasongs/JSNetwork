
Pod::Spec.new do |s|
  s.name         = "JSNetwork"
  s.version      = "0.7.2"
  s.summary      = "离散式网络框架，面向协议编程，类似Swift的Moya"
  s.homepage     = "https://github.com/jiasongs/JSNetwork"
  s.author       = { "jiasong" => "593908937@qq.com" }
  s.platform     = :ios, "9.0"
  s.swift_versions = ["4.2", "5.0"]
  s.source       = { :git => "https://github.com/jiasongs/JSNetwork.git", :tag => "#{s.version}" }
  s.frameworks   = 'Foundation'
  s.source_files = "JSNetwork", "JSNetwork/*.{h,m}"
  s.license      = "MIT"
  s.requires_arc = true
end
