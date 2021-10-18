---
title:  "Remove drm from kindle"
categories:
  - Life
tags:
  - ebook decryption
  - kindle
layout: post
---

记录如何使用 calibre 插件移除从kindle购买的电子图书的加密设置，以便使用 calibre 转换为 epub 等其他格式。

原因：
- 不适应kindle的阅读器界面和操作
- 习惯了系统自带的ibook，自动在不同设备之间同步，增加其他的阅读器只会增加管理书籍的难度

---

#### 1 下载 calibre 安装

https://calibre-ebook.com/

#### 2 将kindle for mac 降级

这一步很有必要，因为amazon经常会更新 kindle 阅读器，带上一些新的图书格式，有时插件进度跟不上就会导致解密失败。

目前是建议降级到 1.17

http://www.mediafire.com/file/8facwgnzbgar55z/KindleForMac-44173.dmg

然后在阅读器设置里关掉自动升级，每次打开app会有提醒让你升级，不要点。

#### 3 给calibre安装解码插件

https://www.epubor.com/3-ways-to-remove-drm-from-kindle-books.html#M1

按照介绍安装。

插件作者的blog, 有很多详细的文字介绍，以及相关主题的其他内容。

https://apprenticealf.wordpress.com/

#### 4 从操作系统中找到图书存储位置

在mac中通常是，/Users/user_name/Library/Application Support/Kindle/My Kindle Content

将图书拖到 calibre 中，处理过程中就自动解密了，之后就可以使用 calibre 的格式转换进行操作。

#### 5 总结

要点是：

- 保持旧版的kindle 阅读器版本。
- 关注插件的更新情况，通常新版会更好用或支持新的文件格式。
- 支持正版，与其google上到处搜罗免费电子书，不如认真选书，买好书，支持作者，把更多精力用在阅读而不是淘免费书上面。


---

Update 2020.12.14

昨天测试旧版Kindle现已无法在较新的MacOS上兼容，需要从appstore下载安装kindle,所以之前的解密方式也失效。

安装新版kindle后，找到 'My Kindle Content' 文件夹，删除里面的文件。然后使用[插件FAQ页面](https://github.com/apprenticeharper/DeDRM_tools/blob/master/FAQs.md#macintosh)中提到的方式来禁用kindle下载KFX格式图书文件到 'My Kindle Content' 文件夹。如果使用的是 Mac, 可以在command line中执行

`sudo chmod -x /Applications/Kindle.app/Contents/MacOS/renderer-test`

输入系统密码确认。


calibre 新版本 5.7.2
- https://calibre-ebook.com/download_osx

插件新版本 v7.0.0b4， 要求 calibre 版本 > 5

- https://apprenticealf.wordpress.com/
- https://github.com/apprenticeharper/DeDRM_tools/releases/tag/7.0.0b4

安装好之后重开calibre和kindle.

该方法目前测试有效。

- Mac OS Big Sur v11.01
- calibre 5.7.2
- kindle 1.30.0(59057)
  - kindle 此版本在本机存在闪退但不影响图书下载


---

Update 2021.05.13

kindle.app 升级至 `1.31.0(60176)` 后无法破解

操作步骤

- [更新calibre](https://calibre-ebook.com/)
- [下载新版插件](https://apprenticealf.wordpress.com/)
- 找到 'My Kindle Content' 文件夹，删除里面的文件。然后使用[插件FAQ页面](https://github.com/apprenticeharper/DeDRM_tools/blob/master/FAQs.md#macintosh)中提到的方式来禁用kindle下载KFX格式图书文件
- 在calibre中安装插件
  - preferences 面板最下面找到 Advanced 中的 plugin 项点进去
  - 点击右下方 load plugin from file, 选中插件解压包中的DeDRM_plugin.zip 文件， 确认安装
- 重新打开kindle.app 下载图书到本地
  - 从 'My Kindle Content' 中找到下载的图书文件用calibre可以顺利打开
