title: Cocos Studio自定义控件--编辑器9Grid控件使用
date: 2016-01-10 00:56:00
layout: post
comments: true
categories: Blog
toc: true 
tags: [9Grid]
keywords: Cocos Studio, 九宫

---
# 0. 介绍
**Cocos Studio**编辑器



**Cocos Studio**编辑器中只开放了仅有的几种数据类型的控件
* 用于输入字符串的文本控件(string)
* 用于输入整数的文本控件(int)
* 用于输入小数类型的文本控件(double, float)
* CheckBox(bool)
* 列表控件，用于显示枚举类型
* 颜色选择器（Color）
* 用于显示（X, Y）的Tuple（PointF， ScaleValue）

其实，编辑器属性中使用的控件还有好几种没有开放出来。未开放的控件中就有9Grid的控件。在编写自己的控件的时候，难免会要支持9Grid









