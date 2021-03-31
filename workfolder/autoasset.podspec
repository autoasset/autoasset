Pod::Spec.new do |s|
    s.name             = 'autoasset'
    s.version          = '27'
    s.summary          = 'AutoAsset appTime: 2021-03-31 14:42:24 - date.now: 2021-03-31 14:42:23'

    s.homepage         = 'https://github.com/autoasset/autoasset'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'autoasset' => 'is.autoasset@outlook.com' }
    s.source = { :git => 'https://github.com/autoasset/autoasset.git', :tag => s.version.to_s }

    s.ios.deployment_target = '9.0'
    s.requires_arc = true
    s.source_files = ['Sources/core/*.{h,swift}]
end
