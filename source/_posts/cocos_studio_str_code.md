title: Cocos Studio自定义控件--字符乱码
date: 2016-01-03 00:56:00
layout: post
comments: true
categories: Blog
toc: true 
tags: [字符乱码]
keywords: Cocos Studio, 字符乱码, 自定义控件

---
# 0. 介绍
最近一直在做基于**Cocos Studio**编辑器下的插件开发，其中，就有自定义控件的开发。截止到最新的2.3.3版本，插件系统能够使用的就只有2.2.1和2.2.5两个版本。其他的版本的插件系统不能使用。而且，其中的坑也是不少。今天就来说说有关自定义控件中文字显示乱码的问题。

# 1. 乱码
**Cocos Studio**的插件实例工程中有一个比较完整的自定义控件的工程，其中一个叫做**Sprite Extend**(2.2.5)的工程就存在这个问题。使用VS2013打开示例工程编译生成。将生成的**Addins.Sample.dll**文件和**LuaScript**文件夹拷贝到编辑器的插件安装目录下。打开编辑器，拖选创建**Sprite Extend**控件，显示如下图1所示：
![图1](/images/cocos_studio_str_code/sprite_extend_normal.png)

<!--more-->

控件看起来一切正常，字符显示都是正确的。下面就来改变一下Label中的字符，改成中文看看。将字符改为**中文测试**，如下图2所示：
![图2](/images/cocos_studio_str_code/disorder_code.png)

可以看到字符乱码了。乱码的问题不过就是编码字符的方法和解码的方式不对应造成的。

# 2. 编码
既然是编码的问题，那么，编码的不同大概会出现在哪里呢？整个自定义插件中，包含了一下3个部分：
* 编辑器内部字符串（C#）
* Lua脚本
* Cocos2d-x引擎显示

整个字符串显示的过程就是：在编辑器输入一个字符串，这时字符串由编辑器的C#代码部分处理，然后传入Lua脚本，再由Lua脚本传给引擎Text控件显示。

Cosos2d-x引擎使用的是UTF-8的编码方式。那么，我们在Lua层处理的字符串也要是UTF-8编码的字符串，这样可以保持一致。如果对Windows平台和VS工具比较熟悉的话，应该大概能够猜到，在C#阶段应该使用的编码是GBK（GB2312）的编码方式。因此，问题最可能出现的地方就是，C#将字符串传给Lua的时候使用的是GBK的编码方式，因此，Lua传给引擎的编码也是GBK的，而引擎需要的UTF-8，因此，出现了乱码。下面来验证一下是否是这样。

只要将C#传递给Lua的字符串保存到文件中，查看一下编码方式就可以知道了。所以，打开文件**sprite0.lua**文件，修改**container.SetLabelText**函数为如下所示：
```
function container.SetLabelText(root, value)
    -- 在父控件中查找名字为 'labelName' 的子控件。
    local child = root:getChildByName('labelName')

	local f = assert(io.open("D:\\log.log", "a"));
	f:write(value .. "\r\n");
	f:close();

    child:setString(value)
end
```
每一次设置Text的文本的时候，就把字符串写入到文件的末尾。然后，使用二进制工具查看便知。然后打开编辑器，修改新创建的控件的Label的文本为**中文测试**，这时在D盘的根目录下会生成log文件。使用WinHex打开文件，如下图3所示：

![图3](/images/cocos_studio_str_code/string_gbk.png)

查询这四个字的编码如下图4所示：
![图4](/images/cocos_studio_str_code/string_code.png)

很明显，字符串是GBK的编码。既然问题就是这样，那么，解决起来也不会太复杂了。可能最直接的想法就是：C#代码中先将字符串转码成UTF-8的编码就可以了。开始我也是这么认为的，然而，这种方式并不能成功。仔细一想，你在传递给Lua代码的时候，还是需要通过一个C#函数来传递的，在参数传递的时候，还是会使用你转码之后的数据流构造一个新的String，那么，这时候，这个编码其实也发生了变换。因此，要想根本解决这个问题，在Lua端来做编码转换是肯定可行的。

# 3. 解决
既然解决的大致方案有了，具体又怎么做呢？Lua这语言其实就是轻量，快速。换句话说，复杂的东西，现成的很少。想想要自己手动转码其实还是很繁琐的。最好能够有现成的库能够帮助做是最好的。一般转码的话，首先想到的库应该就是**libiconv**了。Cocos2dx的转码其实用的就是它。如果是在C/C++的工程中使用这个库，其实很简单。但是，想要在Lua中使用就不是那么简单了。

Lua是能够直接使用动态链接库的，不过，这个库需要按照Lua规定的格式来写。这样，我们只要按照Lua的要求编写一个动态库，动态库中使用libiconv库来完成真正的转码，那么，问题就可以很好解决了。

幸运的是，有一个开源的项目已经将这个功能包装好了，叫做[lua-iconv](https://github.com/ittner/lua-iconv)，因此，只要下载编译好就可以（说起来简单，其实windows下编译还是很麻烦的，因为他依赖了iconv和lua库，这个有时间单独开一篇来记录）。

将编译好的动态库，拷贝到编辑器的安装目录下（和exe文件同一个目录）。这样，修改**container.SetLabelText**函数为如下所示：
```
function container.SetLabelText(root, value)
    -- 在父控件中查找名字为 'labelName' 的子控件。
    local child = root:getChildByName('labelName')

	-- gbk 转utf-8
	local file, err = io.open("luaiconv.dll");
	if not file then
		child:setString(value);
		return;
	end

	local iconv = require("luaiconv")
	local cd = iconv.new( "utf-8", "gbk")
	local value, err = cd:iconv(value)

	local f = assert(io.open("D:\\log.log", "a"));
	f:write(value .. "\r\n");
	f:close();

    child:setString(value)
end
```

再次打开编辑器，修改控件的文本为**中文测试**，结果如图5所示：
![图5](/images/cocos_studio_str_code/disorder_code1.png)

看到**Label Text**又乱码了。因为，在引擎里面使用的是UTF-8的编码，编辑器在显示**Label Text**的时候，这些字符是需要从引擎中**Text**控件中获取的。那么，在C#端需要的是GBK的编码，而获取的是UTF-8的编码，显然是有问题的。其实，到了这一步没有必要使用代码进行转码了，在C#的控件代码中直接声明一个变量来保存这个String即可。修改**Label Text**控件代码如下所示：
```
private string mLabelText = "";
[UndoPropertyAttribute]
[DefaultValue("abc")]
[DisplayName("Label Text")]
[Category("Group_Feature")]
[Browsable(true)]
[PropertyOrder(0)]
public string LabelText
{
	get
    {
		return mLabelText;
		// return luaValueConverter.GetStringValue("GetLabelText");
	}
	set
	{
		mLabelText = value;
		luaValueConverter.SetStringValue("SetLabelText", value);
		this.RaisePropertyChanged(() => this.LabelText);
	}
}
```

现在在重新编译，替换插件之后，显示如下图6所示：
![图5](/images/cocos_studio_str_code/code_normal.png)

现在可以看到，所有地方都显示正常了。

结束。









