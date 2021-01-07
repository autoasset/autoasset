# Version 24

```yaml
---
# 模块: 运行模式
mode:
    # 1. normal: tag 模式
    # 2. local: 本地模式
    # 3. pod_with_branch: 分支模式
    type: normal
    variables: 
        # [local / pod_with_branch]  
        # [local] 模式运行时, 组成版本号的数字将尝试从 Git Tag 中提取, 无法获取时将采用 `version` 字段数值.
        # [pod_with_branch] 模式运行时, 组成版本号的数字将尝试从 Git 分支名中提取, 无法获取时将采用 `version` 字段数值.
        version: 1000
        # [pod_with_branch] 模式运行时, 启用组成版本号的数字将尝试从Git分支名中提取, default: true
        enable_automatic_version_number_generation: true

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
        output: autoassetAssets.podspec
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
    
    # 额外的代码文件
    xcassets:
        output: Sources/Resources/custom/
        inputs:
            - custom-xcassets

    # [19] 额外的代码文件
    codes:
        output: Sources/
        inputs:
            - custom-codes

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
        # [可选] 统计报告输出路径
        report: report/images.csv
        # [可选] xcasset文件夹前缀
        prefix: autoasset_
        # [可选] 自定义描述文件所在文件夹
        contents:
            - Contents/images
        # 资源所在文件夹目录
        inputs:
            - UI

    # GIF
    gifs:
        # 输出路径
        output: Sources/Resources/gifs.xcassets
        # [可选] 统计报告输出路径
        report: report/gifs.csv
        # [可选] xcasset文件夹前缀
        prefix: autoasset_
        # [可选] 自定义描述文件所在文件夹
        contents:
            - Contents/gifs
        # [可选] 与 podspec 中 resource_bundles 一致
        bundle_name: autoassetGIFs
        # 资源所在文件夹目录
        inputs:
            - UI/gifs

```

# Report - Example

| variable_name                | output_folder_name                    | input_files_size | input_files_size_description | output_folder_path                                           | input_file_paths                                             |
| ---- | ------------- | -------------------- | -------- | ------------ | ------------ |
| 变量名 | 输出文件夹名      | 输入的文件总大小       | 输入的文件总大小格式化       | 输出文件夹路径     | 输入的文件,以 \| 号分割             |
| loreDefaultBanner            | dxyer_lore_default_banner             | 507177               | 507 KB                           | /Sources/Resources/icon.xcassets/dxyer_lore_default_banner.imageset | /UI/icon/lore_default_banner@3x.png                          |
| receiveSuccessIcon           | dxyer_receive_success_icon            | 1599                 | 2 KB                             | /Sources/Resources/icon.xcassets/dxyer_receive_success_icon.imageset | /UI/icon/receive_success_icon@2x.png                         |
| badgeNot11                   | dxyer_badge_not_11                    | 65669                | 66 KB                            | /Sources/Resources/icon.xcassets/dxyer_badge_not_11.imageset | /UI/icon/badge_not_11@2x.png                                 |
