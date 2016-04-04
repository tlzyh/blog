title: 第1篇 - C/C++调用Lua
date: 2016-04-02
layout: post
comments: true
categories: Lua源码分析
toc: false
tags: [Lua]
keywords: Lua, 源码阅读

---

# 0. 介绍
Lua是胶水语言，它本身独立存在是没有意义的，只有和宿主语言结合，才能体现出它的价值。既然作为胶水语言，宿主语言肯定是可以调用到Lua脚本程序中的东西的。Lua的一种简单的应用场景就是作为程序的配置文件。那么，宿主程序怎么样获取Lua脚本中配置的变量的过程，就是一个从C/C++（如果你的宿主程序使用的是C/C++）调用Lua的一个过程。

# 1. 获取脚本中的全局变量
在配置文件中一般都是以Key-Value的形式来保存值的。


<!--more-->
