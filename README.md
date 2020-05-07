### version: 5

---

配置文件

```yml
---
# 执行模式,  默认值: normal
# [可选]
# local: 只执行 asset & warn 模块操作
# none | normal: 执行全模块流程
mode: "normal"

# 消息模块, 用于输出带特定参数的文本
# [可选]
# 支持替换文本参数
# - [version]: 版本号
message:
  # [可选] 模板文本, 优先级高于 `template_path`
  template: ""
  # [可选] 模板文件路径, 优先级低于 `template`
  template_path: "./template/message.template"
  # [可选] 文件输出路径
  output_path: "./message.txt"

# Cocoapods模块, 用于输出与上传 podspec 文件
# [可选]
# 支持替换文本参数
# - [version]: 版本号
podspec:
  # [可选] 模板文本, 优先级高于 `template_path`
  template: ""
  # [可选] 模板文件路径, 优先级低于 `template`
  template_path: "./template/podspec.template"
  # [必选] 文件输出路径
  output_path: "../autoasset.podspec"
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
  ui:
    branch: origin/UI
    
# 警告⚠️模块, 用于输出一些警告
# [可选]
warn:
  #[可选] 警告文件输出路径
  output_path: "./warn.txt"

# 资源处理模块
# [必选]
asset:
  # [可选] asset.swift 模板文本, 优先级高于 `template_path`
  template: ""
  # [可选] asset.swift 模板文件路径, 优先级低于 `template`
  template_path: "./template/asset.template"
  # [可选] asset.swift 文件输出路径
  output_path: "../Sources/Asset.swift"
  
  # xcassets 配置
  # [必选]
  xcassets:
    input:
      # [可选] 输入图片路径
      images_path: "../icon"
      # [可选] 输入自定义描述文件路径
      images_contents_path: "../Contents/images"
      # [可选] 输入gifs路径, 可以与 `images_path` 相同
      gifs_path: "../gif"
    output:
      # [可选] 输出图片路径
      images_path: "../icon.xcassets"
      # [可选] 输出gifs路径, 可以与 `images_path` 相同
      gifs_path: "../gifs.xcassets"

```

