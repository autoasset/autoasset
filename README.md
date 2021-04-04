# autoasset



### Mode

> 任务编排模块, 由上至下依次执行任务.

- `download: <name>`: 执行 `download` 模块中同名任务.

- `tidy: <name>`: 执行 tidy模块中同名任务.

- `xcassets`: 执行 iOS中xcassets 资源文件处理模块任务.

#### download

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




#### tidy

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



#### xcassets

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
      {"light": "#faefe6", dark: "#faefe6" },
      {"any": "#faefe6", dark: "#faefe6" }
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
          - UI/gifs
  ```
  
  


