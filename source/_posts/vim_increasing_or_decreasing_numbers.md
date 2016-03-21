title: Vim数字递增或者递减
date: 2016-03-07 11:01:00
layout: post
comments: true
categories: Vim
toc: true 
tags: [Vim]
keywords: Vim

---

# 0.介绍
有些时候总会要批量处理一些数字，比如，一系列递增和递减的数组。当然，方法有很多种，你可以使用excel，bat，python等等工具来实现。当你在编辑一个文件的时候，其实不想进行这些复杂的切换工作。对于Vim来说很容易做的这一点。

# 1.使用宏来实现
在Vim中，递增和递减一个数字快捷键分别为：Ctrl-A，Ctrl-X。这种递增，递减就是一个重复操作的过程。Vim简单的重复上一个命令为'.'(不包含单引号)。显然，只是简单地重复上一个命令是无法实现的。这个过程应该包含了一系列的命令，所以我们需要一个可以重复一系列命令的东西，显然Vim的宏操作是不二之选。
<!--more-->

假如，我们要实现一个100-110的数组（举例使用的数字小一点）。操作步骤如下：

1. 在文件新的一行中添加数字100.
2. 输入如下命令
```
qa
yy
p
Ctrl-A
q
9@a
```
这样就可以得到一组递增的数。递减只需要把*Ctrl-A*改为*Ctrl-X*即可。上面一组命令的意思如下：

* qa: 开始录制一个宏到寄存器a
* yy: 复制当前行
* Ctrl-A: 递增光标处的数字
* q: 完成宏的录制
* 9@a: 执行寄存器a中的宏9次

这个过程就是将复制一行，增加当前数字的两个操作进行了重复执行。
