# Install

```shell
brew tap autoasset/autoasset
brew install autoasset/autoasset/autoasset
```



# Upgrade

```shell
brew upgrade autoasset/autoasset/autoasset
```



# Config:

> 配置信息

## variables

> 变量配置

内置变量集:

| autoasset.date.now                   | 获取当前时间                                       | 27   |
| ------------------------------------ | -------------------------------------------------- | ---- |
| autoasset.date.format                | 设置时间格式, 默认为 yyyy-MM-dd HH:mm:ss           | 27   |
| autoasset.git.branch.current         | 获取当前 Git Branch 名称                           | 27   |
| autoasset.git.branch.current.number  | 获取当前 Git Branch 名称中的数字部分               | 27   |
| autoasset.git.tag.next.number        | 获取远端 Git Tags 中最大的数字 + 1, 未创建分支为 1 | 27   |
| autoasset.git.tag.max.number         | 获取远端 Git Tags 中最大的数字, 未创建分支为 0     | 27   |
| autoasset.git.commit.current.hash    | 获取当前 Git Commit hash                           | 28   |
| autoasset.git.commit.current.author  | 获取当前 Git Commit 作者信息                       | 28   |
| autoasset.git.commit.current.date    | 获取当前 Git Commit 提交日期                       | 28   |
| autoasset.git.commit.current.message | 获取当前 Git Commit 提交信息                       | 28   |
| autoasset.git.remote.url             | 获取当前 Git 远端仓库 URL                          | 34   |
| recommend.package.name               | 获取当前 git URL 后缀名/根文件夹名                 | 35   |
| recommend.package.name(.camelCase)   | 获取当前 git URL 后缀名/根文件夹名(驼峰命名)       | 35   |
| recommend.package.name(.snakeCase)   | 获取当前 git URL 后缀名/根文件夹名(下划线分割命名) | 35   |

支持覆盖的系统变量

```
  [27] autoasset.date.format: yyyy-MM-dd
  [40] recommend.package.name: as-asset
  [40] recommend.package.name(.camelCase): as-asset-camel
  [40] recommend.package.name(.snakeCase): as-asset-snakeCase
```

自定义变量:

- 格式: <#key#>: <#value#>

- 使用: 在文本中插入${<#key#>}, 则在使用到该变量时自动替换.

- tips: 支持嵌套定义, 例如:

  ```yaml
  variables:
    MessageVersion: ${autoasset.git.tag.max.number}
    Message: ${MessageVersion}
  ```

- 范围: 只在以下两种情况下 `variables` 失效.

  - 不适用: mode 中 <xxx>: <name>, 需要搜索的任务名需要明确.
  - 不适用: tidy 中 copies 输入的文本内容. 因为直接复制文件,不读取内容, 需要替换可以使用`create`代替.

## mode

> 任务编排模块, 由上至下依次执行任务.

- `download: <name>`: 执行 `download` 模块中同名任务.
- `tidy: <name>`: 执行 tidy模块中同名任务.
- `xcassets`: 执行 iOS中xcassets 资源文件处理模块任务.
- `cocoapods`: 内置的 cocoapods 校验上传模块.
- `config: <name>`: 执行 `configs` 模块中同名任务.
- `bash: <command>`: 执行 bash 语句.



## [30] iconfonts

> iconfont 模块配置

- `package`: iconfont 资源文件夹
- `font`:
  - `output`: 字体文件输出路径
  - `type`: 字体文件格式 
- `flutter`: flutter 硬编码配置
  - `output`: 代码文件输出路径
  - `font_family`: `IconData(0xe3e6, fontFamily: '${font_family}');`

```yaml
iconfonts:
  - package: IconFont
    font:
        output: ${TTFOutput}
        type: ttf
    flutter: 
        output: ${CodeOutput}
        font_family: ${font_family}
        font_package:  ${font_family}
        class_name:  ${font_family}
    iOS:
        output: ${CodeOutput}
        bundle: 所在 bundle 名, 默认为 "", 在 Bundle.main
        prefix: 对应 xcassets.datas.prefix 值
```



## download

>下载模块配置.

在autoasset[27]版本中, 支持 

- `gits`: git 模式下载任务集

```yaml
mode:
      download: download-autoasset
      download: download-autoasset-2

download:
  #git数组
  gits:
    - name: download-autoasset
      output: autoasset
      input: git@github.com:autoasset/autoasset.git
      branch: master
      
    - name: download-autoasset-2
      output: autoasset2
      input: git@github.com:autoasset/autoasset.git
      branch: master
```



## tidy

>文件服务模块

在autoasset[27]版本中, 支持:

- `clears`: 删除文件任务集

  - `name`: 任务名, 用于Mode中任务搜寻.

  - `inputs`: 删除文件夹路径数组. (不支持*通配符)

    ```yaml
    mode:
      tidy: clear-sources
      tidy: clear-codes
    tidy:
      clears:
        - name: clear-sources
          inputs:
            - Sources
        - name: clear-codes
          inputs:
            - codes
    ```

- `copies`: 复制文件任务集

  - `name`: 任务名, 用于Mode中任务搜寻.

  - `inputs`: 复制文件夹路径数组. (不支持*通配符)

  - `output`: 目标文件夹路径. (不支持*通配符)

    ```yaml
    mode:
      tidy: copy-sources
      tidy: copy-codes
    tidy:
      copies:
        - name: copy-sources
          output: Sources/UI
          inputs:
            - UI
        - name: copy-codes
          output: Sources/codes
          inputs:
            - codes
    ```

- `create`: 创建文件任务集

  - `name`: 任务名, 用于Mode中任务搜寻.

  - `input`: 输入文本文件路径 (不支持*通配符)

  - `text`: 输入文本

  - `output`: 目标文件夹路径. (不支持*通配符)
  
    ```yaml
    mode:
      tidy: create-fastlane-env
      tidy: create-message
    tidy:
      create:
        - name: create-fastlane-env
          output: template-assets/work/fastlane/.env
          text: export DEVELOPERS="${users}"
    
        - name: create-message
          output: template-assets/work/fastlane/message
          input: ./message
    ```



## xcassets

>UI资源快速快速处理为 xcassets 文件, 生成映射代码模块.

在autoasset[27]版本中, 支持:

- `template`:

  - `output`: 生成代码存放的路径.

     默认生成文件, 如有需要可以在`xcassets`任务执行完替换以下对应文件:

    ```bash
    ├── autoasset_color.swift # 生成UIColor实体类, 如有需要推荐替换
    ├── autoasset_color_list.swift
    ├── autoasset_color_protocol.swift
    ├── autoasset_data.swift  # 生成Data实体类, 如有需要推荐替换
    ├── autoasset_data_protocol.swift
    ├── autoasset_gifs.swift  # 生成Data实体类, 如有需要推荐替换
    ├── autoasset_gifs_list_<BundleName>.swift
    ├── autoasset_gifs_protocol.swift
    ├── autoasset_image.swift # 生成UIImage实体类, 如有需要推荐替换
    ├── autoasset_image_list_<BundleName>.swift
    └── autoasset_image_protocol.swift
    ```

- `colors`: 颜色生成对应配置

  - `output`: 生成的 `xcassets` 文件存放路径.

  - `space`: 色域支持

  - `inputs`: 颜色配置的json文件路径集.

    颜色json示例:

    ```json
    [
      {"any": "#faefe6" },
      {"light": "#faefe6" },
      {"light": "#faefe6", "dark": "#faefe6" },
      {"any": "#faefe6", "dark": "#faefe6" }
    ]
    ```

- `images/gifs/datas`:图片/GIF/Data生成对应配置

  - `output`: 生成的 `xcassets` 文件存放路径.
  - `inputs`: 图片所在的文件路径集.
  - `report`: 报告输出路径, 配置了后任务结束会生成一份报告至指定路径.
  - `bundle_name`: 该参数实际使用于`template`模块中, 用于 ` Bundle` 查询.
  - `prefix`: 配置文件前缀.
  - `contents`: 自定义`Contents.json`文件所在路径, 生成``xcassets` `时优先查询该目录中与图片同名的json文件.

  示例: 

  ```yaml
  xcassets:
    template:
      output: ./Sources/codes
  
    colors:
      - output: Sources/Resources/colors.xcassets
        space: display-p3
        inputs:
          - UI/colors
  
    images:
      - output: Sources/Resources/icon.xcassets
        report: .report/images.csv
        bundle_name: IconBundle
        contents: .contents/images
        properties:
          # 启用保留矢量格式数据, 默认为 true
          preserves_vector_representation: true
          # render as
          template_rendering_intent: template
        prefix: as_
        inputs:
          - UI/icon
  
    gifs:
      - output: ./Sources/Resources/gifs.xcassets
        report: .report/gifs.csv
        bundle_name: GIFBundle
        prefix: as_
        inputs:
          - UI/gifs
          
	data:
      - output: ./Sources/Resources/gifs.xcassets
        report: .report/gifs.csv
        bundle_name: DataBundle
        prefix: as_
        inputs:
          - UI/data
  ```



## cocoapods

> 内置的 cocoapods 发布模块

- `podspec`: 指定的`podspec`文件路径.
- `git`: 推送/发布模块, 不配置不上传.
  - `pushToTag`: true, 在Git仓库中创建与 `podspec`文件中版本号相同的tag并推送, 之后在`cocoapods`中发布该版本.
  - `pushToBranch`: true, 在Git仓库推送变更至远端仓库.
  - `commitMessage`: git 提交信息.
- `trunk`:
  - `isGithub`: true,  推送官方仓库.
  - `repo`: 推送私有仓库的Git链接.

```yaml
cocoapods:
  podspec: APPName.podspec
  git:
    pushToTag: true
    pushToBranch: false
    commitMessage: "[ci skip] tag: ${Version}, date: ${timeNow}"
  trunk:
  	isGithub: false,
    repo: git@github.com:autoasset/specs.git
```



## configs

> 子任务集

- `name`: 任务名, 用于Mode中任务搜寻.
- `inputs`: 子任务路径集.
- `variables`: 从当前任务输入至子任务变量集.

```yaml
variables:
  APPName: AutoAssets
  Version: ${autoasset.git.tag.next.number}
  MessageVersion: ${autoasset.git.tag.max.number}
  timeNow: ${autoasset.date.now}

configs:
  - name: create-message-post
    inputs:
      - .autoasset/create-message-post.yml
    variables:
      message: |
        AutoAssets  🎉🎉🎉
        -------------------------------
        >  版本号: ${MessageVersion}
        ------------------------------
        > pod '${APPName}', '${MessageVersion}'
        -------------------------------
        > pod update ${APPName}
        -------------------------------
```
