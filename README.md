### version: 8

---

配置文件

```yml
---
# 执行模式,  默认值: normal
# [可选]
# normal: 
# - 执行全模块流程
# local: 
# - 只执行 asset & warn 模块操作
# pod_with_branch: 
# - pod 以 branch 方式接入, git 将不生成相对应的tag
# - variables: [version]
mode: "normal"

# 执行模式可能需要的参数
mode_variables:

# [可选] 版本号
# 模式: 
# - pod_with_branch
#   - 不填则以分支名作为版本号
  version: null
    
    

# 消息模块, 用于输出带特定参数的文本
# [可选]
# 支持替换文本参数
# - [version]: 版本号
message:
  # [必选] 模板模块
  template: 
    text: ""
    # [可选] 模板文件路径, 优先级低于 `text`
    path: "./template/message.template"
    # [可选] 文件输出路径
    output: "./message.txt"

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
    
# 警告⚠️模块, 用于输出一些警告
# [可选]
warn:
  #[必选] 警告文件输出路径
  output: "./warn.txt"

# 资源处理模块
# [必选]
asset:

  # [必选] 模板模块
  template: 
    text: ""
    # [可选] 模板文件路径, 优先级低于 `text`
    path: "./template/asset.template"
    # [可选] 文件输出路径
    output: "../Sources/Asset.swift"

  # [可选] 图片模块
  images: 
    # [必选] 模板文件路径
    path: "../icon"
    # [必选] 输出文件路径
    output: "../icon.xcassets"
    # [可选] 描述文件路径
    contents_path: "../Contents/images"

  # [可选] 图片模块
  gifs: 
    # [必选] 模板文件路径
    path: "../icon"
    # [必选] 输出文件路径
    output: "../icon.xcassets"
    # [可选] 描述文件路径
    contents_path: "../Contents/images"

```

