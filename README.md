<div align="center">
    <img alt = "logo" src="Data/256-mac.png" />
</div>

# 文颜

[![App Store](https://img.shields.io/badge/App_Store-Download-blue?logo=apple)](https://apps.apple.com/cn/app/%E6%96%87%E9%A2%9C/id6670157335?mt=12&amp;itsct=apps_box_badge&amp;itscg=30200)
[![License](https://img.shields.io/github/license/caol64/wenyan)](LICENSE)
[![Stars](https://img.shields.io/github/stars/caol64/wenyan?style=social)](https://github.com/caol64/wenyan)

本项目的起源是我平常使用`markdown`写文章，再使用`hugo`生成静态页面发布到我的博客。但当我想把文章发布到诸如“公众号”、“知乎”、“今日头条”等平台时，发现需要针对每个平台进行格式转换，这会让我每次浪费很多时间。

后来我找到了 [Markdown Editor](https://markdown.com.cn/editor/) 网站，确实能很好的解决这些问题。但毕竟这是一个在线网站，我希望有个离线也能使用的工具，且我最近也在学`swift`，因此本项目应运而生。

**文颜**现已推出多个版本：

* [macOS App Store 版](https://github.com/caol64/wenyan) - MAC 桌面应用
* [跨平台版本](https://github.com/caol64/wenyan-pc) - Windows/Linux 跨平台桌面应用
* [CLI 版本](https://github.com/caol64/wenyan-cli) - CI/CD 或脚本自动化发布公众号文章
* [MCP 版本](https://github.com/caol64/wenyan-mcp) - 让 AI 自动发布公众号文章

## 3.0版本升级

**支持图片上传功能。**

现在你可以通过「文颜」将本地图片上传到公共图床了。[阅读文档](https://yuzhi.tech/docs/wenyan/upload)。

## 功能

本项目的核心功能是将编辑好的`markdown`文章转换成适配各个发布平台的格式，通过一键复制，可以直接粘贴到平台的文本编辑器，无需再做额外调整。

- 支持发布到多平台：
  - 公众号
  - 知乎
  - 今日头条
  - 掘金、CSDN等
  - Medium
- 支持代码高亮
- 支持公式
- 支持链接转脚注
- 支持识别`front matter`语法
- 集成多种主题样式模版（👉 [内置主题预览](https://yuzhi.tech/docs/wenyan/theme)）
  - [Orange Heart](https://github.com/evgo2017/typora-theme-orange-heart)
  - [Rainbow](https://github.com/thezbm/typora-theme-rainbow)
  - [Lapis](https://github.com/YiNNx/typora-theme-lapis)
  - [Pie](https://github.com/kevinzhao2233/typora-theme-pie)
  - [Maize](https://github.com/BEATREE/typora-maize-theme)
  - [Purple](https://github.com/hliu202/typora-purple-theme)
  - [物理猫-薄荷](https://github.com/sumruler/typora-theme-phycat)
- 自定义主题
  - 支持自定义样式
  - 支持导入现成的主题
  - [使用教程](https://babyno.top/posts/2024/11/wenyan-supports-customized-themes/)
  - [功能讨论](https://github.com/caol64/wenyan/discussions/9)
  - [主题分享](https://github.com/caol64/wenyan/discussions/13)
- 支持导出长图

## 应用截图

![](Data/1.webp)

## 更多功能介绍

[https://yuzhi.tech/wenyan](https://yuzhi.tech/wenyan)

## 下载

本项目已上架`App Store`，你可以直接点击下方链接或搜索“文颜”下载：

<a href="https://apps.apple.com/cn/app/%E6%96%87%E9%A2%9C/id6670157335?mt=12&amp;itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="Data/black.svg" alt="Download on the Mac App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## 如何贡献

- 通过 [Issue](https://github.com/caol64/wenyan/issues) 报告**bug**或进行咨询。
- 提交 [Pull Request](https://github.com/caol64/wenyan/pulls)。
- 分享 [自定义主题](https://github.com/caol64/wenyan/discussions/13)。
- 推荐美观的 `Typora` 主题。

## 赞助

如果您觉得不错，可以给我家猫咪买点罐头吃。[喂猫❤️](https://yuzhi.tech/sponsor)

## License

Apache License Version 2.0
