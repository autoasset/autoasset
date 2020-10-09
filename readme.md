# Version

```yaml
---
# 模块: 运行模式
mode:
		# 1. normal: tag 模式
		# 2. local: 本地模式
		# 3. pod_with_branch: 分支模式
    type: normal
    variables: 
    		# [local / pod_with_branch] 模式运行时, 用于填充 [podspec / message] 中 [version] 的字段
        version: 1000

# 模块: 警告
warn: 
		# 输出路径
    output: output/warn

# 模块: 消息
message: 
		# 输出路径
    output: output/message
		# 输出文本
		# 可用占位符:
		# [branch] : 当前分支名
		# [version] : 当前 tag 或 [mode].variables.version 数值
    text: |
        autoasset  🎉🎉🎉
        ----------------------------------------------------------------------------
        > 构建分支: [branch]
        ----------------------------------------------------------------------------
        > pod 'autoasset', :git => 'git@github.com:autoasset/autoasset.git', :branch => '[branch]'
        ----------------------------------------------------------------------------
        > pod update autoasset
        ----------------------------------------------------------------------------

# 模块: podspec 文件
podspec:
		# [pod lint / pod repo push] 的额外参数
    attributes: 
        no_clean: false
        verbose: false
        allow_warnings: true
    # 模板
    template:
        # 输出路径
        output: DxyerAssets.podspec
				# 输出文本
				# 可用占位符:
        # [version] : 当前 tag 或 [mode].variables.version 数值
        text: |
            Pod::Spec.new do |s|
                s.name         = "autoasset"
                s.version      = "[version]"
                s.summary      = "Assets of AutoAssets app"
                s.description  = "Assets of AutoAssets app"
                s.homepage     = "http://app.autoasset.cn/"
                s.license      = "MIT"
                s.author       = { "autoasset" => "autoasset@autoasset.cn" }
                s.platform     = :ios, "10.0"
                s.source       = { :git => "git@github.com:autoasset/autoasset.git", :tag => "#{s.version}" }
                s.requires_arc = true
                s.swift_version = '5.0'
                s.source_files = ['Sources/*.swift']
                s.resources = ['Sources/Resources/icon.xcassets',
                               'Sources/Resources/colors.xcassets']
                s.resource_bundles = {
                    'autoassetGIFs' => ['Sources/Resources/gifs.xcassets']
                }
            end
    # 目标 specs, 不设置则为官方仓库
    repo:
        name: autoasset-autoassetSpecs
        url: git@gitlab.autoasset.netr/autoassetSpecs.git
        
# asset资源文件
asset:
		# 生成资源前需要清空的文件夹/ 文件
    clear:
        inputs:
            - Sources/Resources

		# 颜色
    colors:
        # 输出路径
        output: Sources/Resources/colors.xcassets
        space: display-p3
        inputs:
            - UI/colors

		# 图片
    images:
		    # 输出路径
        output: Sources/Resources/icon.xcassets
        prefix: dxyer_
        contents:
            - Contents/images
        inputs:
            - UI

		# GIF
    gifs:
			  # 输出路径
        output: Sources/Resources/gifs.xcassets
        prefix: dxyer_
        bundle_name: DxyerGIFs
        inputs:
            - UI/gifs

```



