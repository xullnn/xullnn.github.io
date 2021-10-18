---
title:  "Rubyist-c1: Bootstrapping your ruby literacy"
categories: [Ruby/Rails ℗]
tags: [Ruby & Rails, Notes of Rubyist]
---



*注：这一系列文章是《The Well-Grounded Rubyist》的学习笔记。*


---

Ruby 中不同 scope 的 variable:

local_variable

@instance_variable

@@class_variable

$global_variable

local variable 通常不带前缀， instance variable 前面带 @ ， global variable 前带 $ 且字母大写。

**Keywords**

Ruby has numerous keywords: predefined, reserved terms associated with specific programming tasks and contexts. Keywords include def (for method definitions), class (for class definitions), if (conditional execution), and " \__FILE__ " (the name of the file currently being executed). There are about 40 of them, and they’re generally short, single-word (as opposed to underscore-composed) identifiers.

Ruby 中有很多 keywords 关键词：有些是预定义的，保留词汇（术语），这些用词与特定程序任务相关。 比如用来定义方法的 `def`, 用来定义类的 `class`, 用来写条件判断逻辑的 `if`, 以及 "\__FILE__"（当前正在执行的文件的名称）。这些保留词大概有40个，通常都是短小的单个词汇或符号。

Ruby 中呼叫方法一般用 点号 . 比如
```ruby
"string".to_i
```

但也有不用点号的：
```ruby
puts "string"
```

后一种情况中其实存在一个隐含的 `self`

—

"The most important concept in Ruby is the concept of the object. Closely related, and playing an important supporting role, is the concept of the class."

ruby 中最重要的概念是 object


可以在不实际运行 .rb 文件的前提下，检查 文件的语法 使用 -cw flag
```ruby
ruby -cw c2f.rb
Syntax OK

ruby c2f.rb
The result is: 212.
```

```ruby
celsius = gets
fahrenheit = (celsius.to_i * 9 / 5) + 32
```
可以简化为

```ruby
fahrenheit = (gets.to_i * 9 / 5) + 32
```

**Anatomy of the Ruby installation**

如果你已经安装了Ruby，那么通常Ruby都知道应该去哪里找需要的的文件，但你自己了解安装目录的情况会成为很好的基础。

Looking at the Ruby source code


除了Ruby 的安装目录层级，你也应该了解你电脑中的ruby源代码层级结构。如果电脑中没有，可以去Ruby主页下载。你会看到下载的源码中有一部分是实际安装在你电脑路径中的，还有很多用C语言写的文件被整合之后再进行的安装。另外，源码中还包含 ruby 语言自己的 change log 和 软件执照。

Ruby can tell you where its installation files are located. To get the information while in an irb session, you need to preload a Ruby library package called rbconfig into your irb session. rbconfig is an interface to a lot of compiled-in configuration information about your Ruby installation, and you can get irb to load it by using irb’s -r command-line flag and the name of the package:

Ruby 会告诉你他的安装文件在哪里。你可以在 irb 中获得你想要的信息，这需要你预加载一个叫 `rbconfig` 的库在irb中。rbconfig 是一个可以取得很多Ruby安装文件的接口。

`irb —simple-prompt —rrbconfig` 可以加载到 ruby 的安装目录

然后使用一种标准格式来查看安装文件

`RbConfig::CONFIG["内容选项"]`

`RbConfig::CONFIG` is a constant referring to the hash (a kind of data structure) where Ruby keeps its configuration knowledge. The string "bindir" is a hash key. Querying the hash with the "bindir" key gives you the corresponding hash value, which is the name of the binary-file installation directory.

`RbConfig::CONFIG` 指向一个hash， 这个hash中保存了 ruby 的配置信息。 "bindir" 是hash中的一个 key ，通过不同的 key 拿到不同的信息。

> Table 1.5. Key Ruby directories and their RbConfig terms
Term
>
**Directory** contents
>
**rubylibdir**	Ruby standard library
>
**bindir**	Ruby command-line tools
>
**archdir**	Architecture-specific extensions and libraries (compiled, binary files)
>
**sitedir**	Your own or third-party extensions and libraries (written in Ruby)
>
**vendordir**	Third-party extensions and libraries (written in Ruby)
>
**sitelibdir**	Your own Ruby language extensions (written in Ruby)
>
**sitearchdir**	Your own Ruby language extensions (written in C)

```ruby
2.5.0 :002 > RbConfig::CONFIG["rubylibdir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0"
2.5.0 :003 >
2.5.0 :004 > RbConfig::CONFIG["bindir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/bin"
2.5.0 :005 >
2.5.0 :006 > RbConfig::CONFIG["archdir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/x86_64-darwin17"
2.5.0 :007 >
2.5.0 :008 > RbConfig::CONFIG["sitedir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby"
2.5.0 :009 >
2.5.0 :010 > RbConfig::CONFIG["vendordir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby"
2.5.0 :011 >
2.5.0 :012 > RbConfig::CONFIG["sitelibdir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0"
2.5.0 :013 >
2.5.0 :014 > RbConfig::CONFIG["sitearchdir"]
 => "/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0/x86_64-darwin17"
```

**The Ruby standard library subdirectory (RbConfig::CONFIG[rubylibdir])**

In rubylibdir, you’ll find program files written in Ruby. These files provide standard library facilities, which you can require from your own programs if you need the functionality they provide.
Here’s a sampling of the files you’ll find in this directory:
 
Some of the standard libraries, such as the drb library (the last item on the previous list), span more than one file; you’ll see both a drb.rb file and a whole drb subdirectory containing components of the drb library.

Browsing your rubylibdir directory will give you a good (if perhaps initially overwhelming) sense of the many tasks for which Ruby provides programming facilities. Most programmers use only a subset of these capabilities, but even a subset of such a large collection of programming libraries gives you a lot to work with.

在这个目录下,你会找到很多用 ruby 写的程序文件。 这些文件提供标准库的功能，你可以在自己的程序中 require 他们。比如你可以找到以下文件

**cgi.rb** —Tools to facilitate CGI programming

**fileutils.rb** —Utilities for manipulating files easily from Ruby programs

**tempfile.rb** —A mechanism for automating the creation of temporary files

**drb.rb** —A facility for distributed programming with Ruby

有些库文件比如 drb 库，会横跨多个文件(drb是lib下的一个文件夹而不是单独的文件)。探索一下standard lib路径下的文件可以让你对ruby提供的功能有更好的理解。很多开发者虽然只用到了这些功能中很少的一部分，但是这已经能做很多事了。

**The C extensions directory (RbConfig::CONFIG[archdir])**

Usually located one level down from rubylibdir, archdir contains architecture-specific extensions and libraries. The files in this directory typically have names ending in .so, .dll, or .bundle (depending on your hardware and operating system). These files are C extensions: binary, runtime-loadable files generated from Ruby’s C-language extension code, compiled into binary form as part of the Ruby installation process.

Like the Ruby-language program files in rubylibdir, the files in archdir contain standard library components that you can load into your own programs. (Among others, you’ll see the file for the rbconfig extension—the extension you’re using with irb to uncover the directory names.) These files aren’t human-readable, but the Ruby interpreter knows how to load them when asked to do so. From the perspective of the Ruby programmer, all standard libraries are equally useable, whether written in Ruby or written in C and compiled to binary format.

通常这类文件就在 rubylibdir 路径的下一层，这个文件夹中包含很多与结构相关的拓展文件和库。基于不同的操作系统，这个路径下的文件通常以 .so, .dll, .bundle 等结尾。 这些文件都是 ruby 中的C语言文件生成的：2进制的，运行中可加载的文件，以2进制格式压缩作为ruby安装进程的一部分。

同样这个路径也包含可以被你引入的库。这些文件对于人来说很难读但Ruby解析器知道在需要时如何加载。从ruby开发者的角度来看，所有库都是同样有用的，不管他们是以什么语言或什么格式写的。

**The site_ruby (RbConfig::CONFIG[sitedir]) and vendor_ruby (RbConf- fig::CONFIG[vendordir]) directories**

Your Ruby installation includes a subdirectory called site_ruby, where you and/or your system administrator store third-party extensions and libraries. Some of these may be code you write, while others are tools you download from other people’s sites and archives of Ruby libraries.

The site_ruby directory parallels the main Ruby installation directory, in the sense that it has its own subdirectories for Ruby-language and C-language extensions (sitelibdir and sitearchdir, respectively, in RbConfig::CONFIG terms). When you require an extension, the Ruby interpreter checks for it in these subdirectories of site_ruby, as well as in both the main rubylibdir and the main archdir.

Alongside site_ruby you’ll find the directory vendor_ruby. Some third-party extensions install themselves here. The vendor_ruby directory was new as of Ruby 1.9, and standard practice as to which of the two areas gets which packages is still developing.

Ruby安装文件中包含一个子目录叫 site_ruby， 你或者你的系统可以在这里存放第三方的拓展文件或库。这些文件可以是你自己写的，或是你从其他地方引入的。

site_ruby 路径平行于 Ruby 安装路径，其中包含更多的子路径（同样含有很多库）。当你的程序想引入一个功能时，ruby 会同时在 rubylibdir, archdir, 以及site_ruby中搜索你需要的库。

在ruby_site路径中你会找到 vendor_ruby 这个文件夹。有些第三方的组件安装在这里，vendor_ruby是1.9版本才加入的，以什么样的标准分配不同包到这两个路径(site_ruby / vendor_ruby)中仍然在开发中。

**The gems directory**

The RubyGems utility is the standard way to package and distribute Ruby libraries. When you install gems (as the packages are called), the unbundled library files land in the gems directory. This directory isn’t listed in the config data structure, but it’s usually at the same level as site_ruby; if you’ve found site_ruby, look at what else is installed next to it. You’ll learn more about using gems in section 1.4.5.

Let’s look now at the mechanics and semantics of how Ruby uses its own extensions as well as those you may write or install.

RubyGems 功能是打包和分配ruby库的标准方式。当你安装 gem 时（或你用到包时），解压好的库文件就在 gems 的文件路径中。 这个目录没有出现在配置数据结构中，但他通常和 site_ruby 在同一个层级；如果你找到了 site_ruby 路径，看一下紧邻他的地方安装有什么。让我们看看ruby中引入拓展功能的机制和方法。


**Ruby extensions and programming libraries**

使用 library 的方法有两种

	•	require
	•	load

**Feature, extension, or library ?**

  	•	features 很少单独用到，语义不明，一般会以 requiring a feature 的方式出现
  	•	library 比较常用，指的是可引用的库
  	•	extension 与 library 有部分重叠，但对专业开发者来说，extension 指的是那些 使用 C 语言写的拓展组件

在执行命令时，ruby 会沿着一个特定的 loading path 查找需要的文件

```ruby
caven@caven ⮀ ~/Downloads/ruby-2.5.0 ⮀ ruby -e "puts $:"
/Users/caven/.rvm/gems/ruby-2.5.0@global/gems/did_you_mean-1.2.0/lib
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby/2.5.0/x86_64-darwin17
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/site_ruby
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby/2.5.0/x86_64-darwin17
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/vendor_ruby
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0
/Users/caven/.rvm/rubies/ruby-2.5.0/lib/ruby/2.5.0/x86_64-darwin17
caven@caven ⮀ ~/Downloads/ruby-2.5.0 ⮀
```

When you load a file, Ruby looks for it in each of the listed directories, in order **from top to bottom.**

load 和 require 的区别在于

如果在第一次 load 某个文件之后，再次，多次 load 同一个文件，ruby 仍然会执行

但是 require 在第一次 require 到之后，就不再需要 require  同样的文件

```ruby
2.5.0 :018 > require 'json'
 => true
2.5.0 :019 > require 'json'
 => false
2.5.0 :020 > require 'json'
 => false
```

现在有两个文件

**loadee.rb**
```ruby
puts ">> Puts this line when require/load successfully."
```

**loaddemo.rb**
```ruby
puts "Here I load loadee.rb 3 times."
3.times do
 load "loadee.rb"
end

puts "-" * 30

puts "Here I require loadee.rb 3 times."
3.times do
 require "./loadee.rb"
end

puts "-" * 30

puts "Here I require_relative loadee 3 times."
3.times do
 require_relative "loadee"
end
```

运行 loaddemo.rb 的结果

```ruby
caven@192 ⮀ ~/Notes & Articles/Note of Rubyist/code examples ⮀ ⭠ 01-Rubyist± ⮀ ruby loaddemo.rb
Here I load loadee.rb 3 times.
>> Puts this line when require/load successfully.
>> Puts this line when require/load successfully.
>> Puts this line when require/load successfully.
------------------------------
Here I require loadee.rb 3 times.
>> Puts this line when require/load successfully.
------------------------------
Here I require_relative loadee 3 times.
```

每一次 load 文件都被执行

只有第一次 require 文件被执行

**require 要写明文件路径**，使用 require ‘loadee.rb’ 会报错 必须用 require ‘./loadee.rb’

但是 require_relative 就可以直接用 require_relative ‘loadee.rb’ 甚至不用
 .rb

**Out-of-the-box Ruby tools and applications**

 When you install Ruby, you get a handful of important command-line tools, which are installed in whatever directory is configured as bindir—usually /usr/local/bin, /usr/bin, or the /opt equivalents. (You can require "rbconfig" and examine Rb-Config::CONFIG["bindir"] to check.) These tools are

 当你安装 Ruby 之后，你同时得到了一些重要的 command-line 工具，他们被安装在 /usr/local/bin, /usr/bin, /opt 这些文件夹中。

ruby —The interpreter 解释程序/解析器

irb —The interactive Ruby interpreter 互动式ruby解析器

rdoc and ri —Ruby documentation tools ruby文档工具

rake —Ruby make, a task-management utility ruby的任务管理工具

gem —A Ruby library and application package-management utility 库和组件包管理工具

erb —A templating system 前端样板系统（embeded ruby）

testrb —A high-level tool for use with the Ruby test framework ruby的高层级测试框架

Ruby has more than 20 command-line switches. Some of them are used rarely, while others are used every day by many Ruby programmers. Table 1.6 summarizes the most commonly used ones.

Ruby中有超过20个命令行开关，有些很少用到，有些经常用，下面是最常见的几个。

Table 1.6. Summary of commonly used Ruby command-line switches

-c	Check the syntax of a program file without executing the program	`ruby -c c2f.rb`
在不执行代码的前提下检查文件中的句法

-w	Give warning messages during program execution	`ruby -w c2f.rb`
在程序运行时给出警告

-e	Execute the code provided in quotation marks on the command line	`ruby -e 'puts "Code demo!"'`
执行引号中的代码

-l	Line mode: print a newline after every line of output	`ruby -le 'print "+ newline!"'`
每一行输出后插入新行

-rname	Require the named feature	`ruby –rprofile`
require给出名称的功能

-v	Show Ruby version information and execute the program in verbose mode	`ruby –v`

--version	Show Ruby version information	`ruby –-version`
显示ruby版本信息

-h	Show information about all command-line switches for the interpreter   `ruby -h`
显示所有 command-line 开关的帮助信息

```ruby
caven@192 ⮀ ~/Notes & Articles/Note of Rubyist/code examples ⮀ ⭠ 01-Rubyist± ⮀ ruby -h
Usage: ruby [switches] [--] [programfile] [arguments]
 -0[octal]       specify record separator (\0, if no argument)
 -a              autosplit mode with -n or -p (splits $_ into $F)
 -c              check syntax only
 -Cdirectory     cd to directory before executing your script
 -d              set debugging flags (set $DEBUG to true)
 -e 'command'    one line of script. Several -e's allowed. Omit [programfile]
 -Eex[:in]       specify the default external and internal character encodings
 -Fpattern       split() pattern for autosplit (-a)
 -i[extension]   edit ARGV files in place (make backup if extension supplied)
 -Idirectory     specify $LOAD_PATH directory (may be used more than once)
 -l              enable line ending processing
 -n              assume 'while gets(); ... end' loop around your script
 -p              assume loop like -n but print line also like sed
 -rlibrary       require the library before executing your script
 -s              enable some switch parsing for switches after script name
 -S              look for the script using PATH environment variable
 -T[level=1]     turn on tainting checks
 -v              print version number, then turn on verbose mode
 -w              turn warnings on for your script
 -W[level=2]     set warning level; 0=silence, 1=medium, 2=verbose
 -x[directory]   strip off text before #!ruby line and perhaps cd to directory
 -h              show this message, --help for more info
```

ruby 每执行一次代码，默认都会有一个返回值，并印出来

也可以把 irb 设成不显示返回值的风格 使用 —noecho 无回声模式…

```ruby
caven@192 ⮀ ~ ⮀ irb --simple-prompt --noecho
>> puts "Hi"
Hi
>> exit
caven@192 ⮀ ~ ⮀ irb
2.5.0 :001 > puts  "Hi"
Hi
=> nil
2.5.0 :002 >
```


**ri and RDoc**

ri (Ruby Index) and RDoc (Ruby Documentation), originally written by Dave Thomas, are a closely related pair of tools for providing documentation about Ruby programs. ri is a command-line tool; the RDoc system includes the command-line tool rdoc. ri and rdoc are standalone programs; you run them from the command line. (You can also use the facilities they provide from within your Ruby programs, although we’re not going to look at that aspect of them here.)
ri 和 RDoc 最初是 Dave Thomas 写的，他们很像一对给ruby程序提供文档的工具。ri是一个命令行工具；RDoc系统包含了命令行工具 rdoc。 ri 和 rdoc 是相互独立的程序，你可以在命令行中运行他们。你同样可以在你的ruby程序中使用他们的功能。

RDoc is a documentation system. If you put comments in your program files (Ruby or C) in the prescribed RDoc format, rdoc scans your files, extracts the comments, organizes them intelligently (indexed according to what they comment on), and creates nicely formatted documentation from them. You can see RDoc markup in many of the source files, in both Ruby and C, in the Ruby source tree, and in many of the Ruby files in the Ruby installation.
Rdoc 是一个文档系统。如果你在你的程序代码中以 RDoc的格式要求 写入了一些 注释，那么 rdoc 命令就可以扫描你的文件，提取出你的注释内容并将他们智能地组织成好看的格式。你可以在很多源码文件中看到 RDoc 标记，不管是 ruby 文件还是 C 文件。

ri dovetails with RDoc: it gives you a way to view the information that RDoc has extracted and organized. Specifically (although not exclusively, if you customize it), ri is configured to display the RDoc information from the Ruby source files. Thus on any system that has Ruby fully installed, you can get detailed information about Ruby with a simple command-line invocation of ri.

For example, here’s how you request information about the upcase method of string objects:
ri和 RDoc 铆接在一起：ri 能让你读取 RDoc 抽取出的信息。ri是用来显示 Ruby 源码中的 RDoc 信息的。这样在任何安装有 ruby 的系统中你都可以使用 ri 读到关于 ruby 的细节信息。比如可以查询到String类下的instance method `upcase`的信息。

注意：书中给出的代码示例与当前ruby版本中的 ri 用法有所不同，可能是版本更新所致，使用 `ri String#upcase` 会报错"no matches found: String#upcase"， ruby 现在使用的是与实际method使用语法一致的 `ri String.upcase`，查询类方法还是使用原来的 :: 连接比如 `ri String::new`

直接在命令行中(不是irb中)执行 `ri String.new` 会返回下面的信息：

```ruby
= String.upcase

(from ruby site)
------------------------------------------------------------------------------
  str.upcase              -> new_str
  str.upcase([options])   -> new_str

------------------------------------------------------------------------------

Returns a copy of str with all lowercase letters replaced with their
uppercase counterparts.

See String#downcase for meaning of options and use with different encodings.

  "hEllO".upcase   #=> "HELLO"
```

By default, ri runs its output through a pager (such as more on Unix). It may pause at the end of output, waiting for you to hit the spacebar or some other key to show the next screen of information or to exit entirely if all the information has been shown. Exactly what you have to press in this case varies from one operating system, and one pager, to another. Spacebar, Enter, Escape, Ctrl-C, Ctrl-D, and Ctrl-Z are all good bets. If you want ri to write the output without filtering it through a pager, you can use the –T command-line switch (ri –T topic).

默认情况下 ri 通过 pager 来输出返回的结果。这可能会中断你之前的屏幕显示，退出当前显示页面的方法会因不同操作系统而有所不同。如果你不想 ri 返回的结果是以 pager 的形式呈现，可以使用 -T 选项，会直接在命令行中输出结果 `ri -T String.upcase`。

**The rake task-management utility**

As its name suggests (it comes from "Ruby make"), rake is a make-inspired task-management utility. It was written by the late Jim Weirich. Like make, rake reads and executes tasks defined in a file—a Rakefile. Unlike make, however, rake uses Ruby syntax to define its tasks.

从 `rake` 这个名字看出他是受 `make` 启发而建立的任务管理功能，像 make 一样， `rake` 可以读取和执行 rakefile 中定义好的任务，只不过 rakefile 文件中的任务是用 ruby 语言写的。

`rake --help` 可以查看 rake 命令相关的用法

`rake --tasks` 可以列出所有 rake 任务

rake 文件中的 namespace 可以嵌套很多层

如果一个 rake 任务外嵌套了很多层 namespace 那么在执行它的之后也要写完每一层的 namespace， 比如`rake admin:clean:tmp` 而不能直接 `rake tmp`。

**Installing packages with the gem command**

gem 的安装也可以从本地来

```ruby
gem install /home/me/mygems/ruport-1.4.0.gem
```

安装gem 时的两个 flag

-l 告诉ruby只在本地搜寻此gem安装

-r 告诉ruby只在远端(互联网上)搜索安装

但通常还是只用

gem install name

会同时在本地和远端搜索安装


手动规定使用 某个特定的 gem 版本

gem "name", "n.n.n"

执行上面的命令后不用再 require 一次

### Summary
In this chapter, we’ve looked at a number of important foundational Ruby topics, including
 
The difference between Ruby (the language) and ruby (the Ruby interpreter)
Ruby 语言和 ruby 命令(使用 ruby 解释器)的区别
The typography of Ruby variables (all of which you’ll meet again and study in more depth)
Ruby 中的各种变数
Basic Ruby operators and built-in constructs
基本的Ruby运算符和一些内建结构
Writing, storing, and running a Ruby program file
写入，存储，以及运行一个 Ruby 程序文件
Keyboard input and screen output
键盘输入和屏幕输出
Manipulating Ruby libraries with require and load
使用 require 和 load 引入 Ruby 库
The anatomy of the Ruby installation
Ruby 的安装细节
The command-line tools shipped with Ruby
Ruby的命令行工具

You now have a good blueprint of how Ruby works and what tools the Ruby programming environment provides, and you’ve seen and practiced some important Ruby techniques. You’re now prepared to start exploring Ruby systematically.
