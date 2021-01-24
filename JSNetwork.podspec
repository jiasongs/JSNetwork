
Pod::Spec.new do |s|
  s.name         = "JSNetwork"
  s.version      = "0.7.8"
  s.summary      = "离散式网络框架，面向协议编程，类似Swift的Moya"
  s.homepage     = "https://github.com/jiasongs/JSNetwork"
  s.author       = { "jiasong" => "593908937@qq.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = ["4.2", "5.0"]
  s.source       = { :git => "https://github.com/jiasongs/JSNetwork.git", :tag => "#{s.version}" }
  s.frameworks   = "Foundation"
  s.license      = "MIT"
  s.requires_arc = true

  s.default_subspec = "Core"
  s.subspec "Core" do |ss|
    ss.source_files = "Sources/**/*.{swift,h,m}"
    ss.exclude_files = ["Sources/Extension/Swift", "Sources/Request/AFNetworking", "Sources/Request/Alamofire", "Sources/Plugins"]
  end

  s.subspec "ExtensionForSwift" do |ss|
    ss.source_files = "Sources/Extension/Swift/*.{swift,h,m}"
    ss.dependency "JSNetwork/Core"
  end

  s.subspec "RequestForAFNetworking" do |ss|
    ss.source_files = "Sources/Request/AFNetworking/*.{swift,h,m}"
    ss.dependency "JSNetwork/Core"
    ss.dependency "AFNetworking", "~> 4.0"
  end

  s.subspec "RequestForAlamofire" do |ss|
    ss.source_files = "Sources/Request/Alamofire/*.{swift,h,m}"
    ss.dependency "JSNetwork/Core"
    ss.dependency "Alamofire", "~> 5.0"
  end

  s.subspec "Plugins" do |ss|
    ss.source_files = "Sources/Plugins/*.{swift,h,m}"
    ss.dependency "JSNetwork/Core"
  end
end
