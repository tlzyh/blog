title: Appium(Android) Window平台安装(Python Client)
date: 2016-01-23
layout: post
comments: true
categories: Blog
toc: false 
tags: [Appium]
keywords: Appium

---
# 0. 背景
软件开发都知道，测试是保证软件质量的一个重要手段，因此，产品开发的一定阶段的时候就会加入测试人员进行跟进测试。但是，一个不是特别大的项目中也不会有很多的测试人员，特别是在移动端的应用，一般都只有2-3个测试跟进测试的。那么，测试的覆盖的用例都是有限的，而且，有些bug，需要大量的重复测试才能重现。这个时候再仅仅让测试人员测试，效率其实是非常低的。因此，自动化测试是一个很好的解决方案。而且，现在有大量的免费的云测试平台可供选择，但是，这些平台测试的效果，或者说针对你的产品的测试效果怎么样，那就看情况了。为此，自己研究一下，这方面的技术也是十分必要的。公司项目也在往这方面发展，我因此变成了探路人了。

<!--more-->

# 1. Appium
其实在没有关注**自动化测试**这方面技术的时候，我也不知道这个项目的存在。在比较了好几个开源框架之后，感觉这个项目非常不错。只是其中涉及到的具体技术细节，自己不是很清楚。也有了想一探究竟的想法。不过，它同样存在和其他开源项目一样的通病，文档不齐全，文档跟不上代码的情况，因此，做好踩坑的准备。
主要工具版本：
* 操作系统：Windows8.1（64位）
* Python版本：2.7.10
* Appium版本：1.4.16.1

# 2. 安装
在安装之前，你需要确认你使用什么作为你测试代码的语言，这里我选择的是Python（之前感觉不怎么好，用多了，这语言写起代码来和C#一样，快感十足）。分为以下几个步骤：
1. 安装Appium
2. 安装Python
3. 安装setuptools
4. 安装Python-client
5. 2.5 配置Android SDK环境变量

## 2.1 安装Appium
网上关于安装Appium，说起来十分复杂，如果你只是使用Appium，其实非常简单，到[Bitbucket](https://bitbucket.org/appium/appium.app/downloads)直接下载对应版本的安装包即可。然后，就是直接安装即可。

## 2.2 安装Python
打开[Python官网](https://www.python.org/)，下载2.7.x版本。因为3.x版本和2.7.x版本差别很大。为了稳定，兼容起见，选择2.7.x。如果在cmd环境下执行python，提示命令无效，手动添加python bin目录到path环境变量中。

## 2.3 安装setuptools
**python-client**中依赖了**setuptools**，所以，需要先安装setuptools。这个工具的安装在win7 32位64位，Win8中略有不同，具体安装，方法参见[官网](https://pypi.python.org/pypi/setuptools)，从官网的介绍中，推荐Windows平台下使用运行[ez_setup.py](https://bootstrap.pypa.io/ez_setup.py)脚本安装。在**ez_setup.py**所在目录下，打开cmd，输入一下命令安装即可。
```
python ez_setup.py
```
## 2.4 安装Python-client
打开[python-client](https://github.com/appium/python-client)的仓库地址。在ReadMe中提供了3中安装方法。选择第三种安装方式。
```
git clone git@github.com:appium/python-client.git
cd python-client
python setup.py install
```
直到提示安装完成。

## 2.5 配置Android SDK环境变量
添加一个**ANDROID_HOME**的环境变量，指向Android SDK的根目录。要注意的是，如果你在未设置环境变量之前就打开了Appium的话，设置要环境变量之后，需要重启才能生效。

# 3. 测试
以上步骤执行完成之后，环境也就基本搭建好了。Appium git上已经给我们提供了一些[示例](https://github.com/appium/sample-code)了。直接下载zip或者clone。打开sample-code\examples\python\android_contacts.py测试脚本。找到**desired_caps['deviceName']**代码处，修改该caps的设备名称为你连接到机器上的手机或者虚拟机（使用adb devices -l命令查看）。按照以下步骤执行：
1. 启动**Appium**
2. 在脚本所在目录打开cmd执行：python android_contacts.py。
此时，自动测试就已经在开始运行了。



