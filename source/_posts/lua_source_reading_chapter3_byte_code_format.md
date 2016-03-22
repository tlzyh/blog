title: 字节码文件结构
date: 2016-03-21
layout: post
comments: true
categories: Lua源码分析
toc: false 
tags: [Lua]
keywords: Lua, 源码阅读

---


# 0. 介绍
前面提到了指令的结构和操作码的内容，那么，下面就要看看这些操作码在编译之后，指令
是如何表现的。lua编译之后的内容不是像纯粹的bin文件一样，完全等同代码和数据的集
合。如果只是一个简单的用于学习的语言的话，这些内容已经足够了，但是，它是需要
应用在实际应用中的。它有它独特的结构，就像pe文件一样，由很多个部分，在程序载入
的时候是需要获取其中保存的信息的，这样才能够运行。下面就来看看lua的字节码文件的
结构。

# 1. 编译
luac.exe是lua脚本的编译程序，你可以使用 -o 来生成对应的字节码文件，而且还可以使
用-l来列举出一些信息。同时，使用 -l -l 参数可以获得更详细的信息。以下面的lua代码
作为分析Lua字节码文件结构的实例代码。

<!--more-->

```
local a = 1;
a1 = 2;
 
local str = "local string"
str1 = "string"
 
local tbl = {};
tbl1 = {};
 
local boolean = false;
boolean1 = true;
 
local nnn = nil;
nnn1 = nil;

function add(p1)
    a = p1 + 2;
	return a + a1;
end
```

编译并且列举出信息，如下图所示：

![图片](/images/lua_src/code_list_info.png)

# 2. 头结构
在Lua5.2 中，字节码文件包括两个大的部分：

* 头部。
* 程序代码（暂且这么说）。

头部的大小为18个字节，各个字段的大小和说明如下表所示：

| 偏移 | 大小(字节) | 说明                          |
|------|----------|------------------------------|
| 0x00 | 4          | lua字节码文件标识             |
| 0x04 | 1          | lua版本                       |
| 0x05 | 1          | lua的格式，官方格式为0        |
| 0x06 | 1          | 字节序类型（1为小端,0为大端） |
| 0x07 | 1          | Int类型的字节大小             |
| 0x08 | 1          | size_t类型的字节大小          |
| 0x09 | 1          | 一条指令的字节大小            |
| 0x0A | 1          | Lua中Number的字节大小         |
| 0x0B | 1          | Lua中Number的定义是否是整形数 |
| 0x0C | 6          | 结尾的标志                    |

下面是一个Lua5.2在x386平台下头部的信息：

![图片](/images/lua_src/bc_header_format.png)

Lua的文件标志都是 "\033Lua"(在C语言中0开头的数字是8进制的，这里也就是对应图中
第一个字节的0x1B)，这个字符串可以在lua.h文件中找到，名字为： *LUA_SIGNATURE* 。

这里使用的5.2的Lua，所以，版本为：0x52。

官方格式，所以，格式为：0x00。

x386平台，字节序为小端，所以表示字节序的标志为：0x01

int的大小为4个字节。

size_t 的大小为4个字节。

一条指令的大小为32bit，也就是4字节。

Lua5.2中默认的Number类型为double，所以Number的大小为8字节(0x08)。

上面说到Number为double，那么它就不是int类型的了（0x00）

结尾标记也是一个固定的字符串，定义在lundump.h文件中，为："\x19\x93\r\n\x1a\n"。


# 3. 函数原型
一个二进制的函数块定义了一个函数的原型。lua在执行的时候通过这个函数原型来创建一
个闭包(closure)。一个函数原型通常由函数头部，指令，和数据组成。详细部分如下表所
示：

| 名称         | 说明    |
|--------------|-------|
| 函数头部     | 包含了函数原型中的一些基本信息，如开始，结束的行号|
| 指令集合     | 函数中的所有的指令，开始的4个字节表示指令的条数|
| 常量集合     | 函数中使用到的所有的常量，开始的4个字节表示常量的个数 |
| 函数原型     | 所包含的函数的原型，所以lua中可以在函数里面声明函数，整个文件就是一个函数原型 |
| 本地变量集合 | 函数中使用到的本地变量|
| UpValue集合  | 函数中使用到的所有的UpValue  |


# 3. 函数头
在lua字节码中，每一个函数都有一个固定长度为11字节的头部，用于描述函数的信息。
每个字段的偏移，大小和注释如下表所示：

| 偏移(相对一个函数) | 大小(字节) | 说明|
|------------------|----------|-----|
| 0x00               | 4          | 执行语句块(chunk)在源文件中对应的开始的行号， main chunk为0 |
| 0x04               | 4          | 执行语句块(chunk)在源文件中对应的结束的行号， main chunk为0 |
| 0x08               | 1          | 参数个数                                                    |
| 0x09               | 1          | 可变参数的标志                                              |
| 0x0A               | 1          | 函数中使用的寄存器的个数                                    |

下面分别看看主chunk和一个普通chunk 的函数头部信息。主chunk函数头部字节信息如下
图所示：

![图片](/images/lua_src/main_chunk_func_head.png)

在main chunk中开始的行号和结束的行号都是0，所以前面的8个字节都是0。一个单独的
模块，没有参数。可变参数的标志为1（这个参数的意义后面再讲）。可以看到函数中寄存
器的索引号到了5，那么，函数中使用了6个寄存器。所以，最后一个字节的大小为0x06。

# 3. 指令部分
函数头部分后面紧接着的是指令部分，这个部分已4个字节的指令个数开始的。假如，开始
的4个字节的值为 0x00000002，那么表示总共只有两条指令在后面。Lua中指令的大小为4
个字节，所以指令部分的大小为：(指令个数 + 1) * 4。实例中总共有0x0E条指令。而且，
主chunk的指令开始位置为固定的0x1D。所以，指令结束位置在 （0x0E + 1） * 4 + 0x1D - 1
= 0x58。指令部分如下图所示：

![图片](/images/lua_src/bc_instruction_part.png)

# 4. 常量部分
指令的后面就是常量存储区域。和指令部分有点类似，它的开头的4个字节表示的是常量的
个数。该部分的长度不能通过常量的个数来确定总长度，因为类型有很多种，而且长度还
不是固定的，所以只能够遍历完成之后才能够知道总的长度，单个的常量的表示方式基本
两个部分组成：

* 类型。
* 大小（像Boolean和Number的大小都是知道的，那么该字段省略）。

![图片](/images/lua_src/bc_const_part.png)

上图中，红色方框表示的是常量的个数，在main chunk中0x0C个常量。黑色框表示的是常
量的类型，也是一个常量的开始。lua中数据类型定义如下:

```
#define LUA_TNONE		(-1)

#define LUA_TNIL		0
#define LUA_TBOOLEAN		1
#define LUA_TLIGHTUSERDATA	2
#define LUA_TNUMBER		3
#define LUA_TSTRING		4
#define LUA_TTABLE		5
#define LUA_TFUNCTION		6
#define LUA_TUSERDATA		7
#define LUA_TTHREAD		8

#define LUA_NUMTAGS		9
```

对应上面的黑色框中的数字，就可以看到各个数据的类型。

## 4.0 字符串
在字符串中，首选是0x04，表明它是一个字符串的常量，紧接着的是4个字节的长度表示，表
示字符串的总长度的字节数，拿第一个字符串来说（第二个黑色框）。类型后面的一个4字
节的数字为0x03，那么，表示字符串的长度为3。接着就是字符串的具体的内容，以00结尾。
## 4.1 Number
Lua中的Number类型，可以参见文件头中的定义。这里的Number类型使用的C语言中的双精
度浮点数(double)来表示的。所以，大小为8字节。以第一个Number为例（第一个黑框），
类型为3，表示为Number，后面的值为：0x0000 0000 0000 3FF0(double中1的表示)，双
精度的格式参见[维基百科](http://en.wikipedia.org/wiki/Double-precision_floating-point_format)

## 4.2 Boolean值
Boolean值得类型为1，在上面的字节码文件中，只有一个boolean值，它的值为0x01，表示
它的值为true。当值为0x00的时候表示为false。

## 4.3 nil值
Lua中nil变量也是占用空间的，它的类型为0x00。对应上面偏移位置为0xC3的地方，它只有
一个类型的表示，没有实际的值。

# 5. 函数原型
函数数原型部分也就是该主模块包含的函数。显然，该main chunk中包含了一个add的函数


# 6. UpValue部分
UpValue部分在最后

# 7. 实例分析
上面介绍了字节码文件的基本结构，那么，下面使用一个实例来加深一下对字节码文件的
认识，Lua代码如下所示：

使用luac编译并且添加 -l 参数列举出具体的代码信息，列举出的信息如下所示：











