title: 第0篇 - 阅读环境搭建
date: 2016-03-21
layout: post
comments: true
categories: Lua源码分析
toc: false 
tags: [Lua]
keywords: Lua, 源码阅读

---

# 0. 介绍
个人在看任何项目的源代码的时候都喜欢先把这个代码给想办法跑一遍。这样做的好处就是，
当遇到一些实在看不懂的代码的时候可以添加断点来跟踪，方便自己更好地理解。因此，
在阅读Lua代码的时候也先把源代码跑一遍。这里只讲如何在VS上跑Lua源代码，在linux
环境下，直接运行Makefile文件即可。本系列文章使用的Lua的版本为 5.1.0。


# 1. 创建工程
Lua 使用的是标准C编写而成的，所以，你只需要使用VS创建一个命令行的程序工程，把需要的源文件添加到工程就可以了。

将src目录下除了Makefile，luac.c 的所有文件拷贝到新创建的工程目录下面，并添加到工程中。

<!--more-->

# 2. 编译
在VS下，原来一些字符串操作的函数都被认为是不安全的，这个时候会出现如下的错误：

```
 This function or variable may be unsafe. Consider using fopen_s instead. 
	 To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
```

按照提示在预编译选项中加上**_CRT_SECURE_NO_WARNINGS_** 就可以了，再一次编译就OK了。
这样就可以在VS上调试，查看Lua的源代码了。