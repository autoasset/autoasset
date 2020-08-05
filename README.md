### version: 8

---

配置文件

```yml
---
# 执行模式,  默认值: normal
mode:
		# normal
		# local
    # pod_with_branch
    # test_message
    # test_podspec
    # test_warn
    type: pod_with_branch
    variables: 
        version: 30

warn: 
    output: output/warn

# 消息模块, 用于输出带特定参数的文本
# [可选]
# 支持替换文本参数
# - [version]: 版本号
message: 
    output: output/message
    text: |
        构建成功  🎉🎉🎉

# Cocoapods模块, 用于输出与上传 podspec 文件
# [可选]
# 支持替换文本参数
# - [version]: 版本号
podspec:
  # [必选] 模板模块
  template: 
    text: ""
    # [可选] 模板文件路径, 优先级低于 `text`
    path: "./template/podspec.template"
    # [可选] 文件输出路径
    output: "../autoasset.podspec"

  # [可选] 上传的私有仓库
  repo:
    # [必选] 私有仓库本地名称, 可使用 pod repo list 查看配置
    name: "myRepo"
    # [必选] 私有仓库远程链接
    url: "git@gitlab.linhey.net:ios/Specs.git"
    
# Git模块, 用于配置Git相关操作参数
# [可选]
git:
  # [可选] .git文件所在路径, 默认值: ../
  project_path: "../"
  # [可选] 指定被合并入的git分支
  branchs:
    - origin/UI

# 资源处理模块
asset:
    clear:
        inputs:
            - Sources/Resources
  # [必选] 模板模块
    template:
        output: Sources/AutoAssets.swift

    colors:
        inputs:
            - UI/colors

  # [可选] 图片模块
    images:
        output: Sources/Resources/icon.xcassets
				bundle_name: Images
        contents:
            - Contents/images
        inputs:
            - UI

  # [可选] 图片模块
    gifs:
        output: Sources/Resources/gifs.xcassets
        bundle_name: GIFs
				contents:
            - Contents/gifs
        inputs:
            - UI/gifs
```

