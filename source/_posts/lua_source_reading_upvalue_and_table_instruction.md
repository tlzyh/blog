title: UpValue和Table指令
date: 2016-03-21
layout: post
comments: true
categories: Lua源码分析
toc: false 
tags: [Lua]
keywords: Lua, 源码阅读

---

# 0. 介绍
如果你是一个C++或者Java程序员的话，对于UpValue这个概念会比较陌生。在C语言中，
变量只有两种类型：1.局部变量。2.全局变量。这两种在Lua中也是有的，但是他还有一种
叫做UpValue的变量。在一个函数里面，如果一个变量在该函数里面而且使用了local关键
字修饰的变量叫做Lua的局部变量。如果一个函数的变量是外层函数的变量，那么，这个
变量就是一个UpValue了，全局变量就是全局有效的。在分析字节码文件结构的时候，可以
看到，其实一个文件就是一个函数。那么，所谓的对于全局变量的操作，其实，也是和UpValue
的操作是一样的。在Lua5.1的时候，全局变量是有固定的指令的，在5.2版本里面，统一
使用UpValue相关的操作指令了。

<!--more-->

