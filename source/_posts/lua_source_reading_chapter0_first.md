title: 第0篇 - 在C/C++语言中嵌入Lua
date: 2016-03-30
layout: post
comments: true
categories: Lua源码分析
toc: false 
tags: [Lua]
keywords: Lua, 源码阅读

---

# 0. 介绍
一直打算把Lua的源代码从头到尾的读一遍。一直都是有时间就看一点，并没有看得很彻底。到现在Lua的版本已经更新到了5.3.x。因此，选择5.3.0这一个大版本作为现在的阅读对象。所以，后面所有的内容都是基于Lua5.3.0版本的。

# 1. 从哪里开始
在网上可以Google到Lua的源代码的阅读顺序。如果你只是对于Lua的使用比较熟悉，对于Lua如果在其他宿主语言中如何使用并不是很熟悉的话。其实，安装那个顺序阅读是比较困难的，其中涉及到的内容比较多，当你阅读到有关数据结构，如Lua_State的时候，感觉过于复杂而无从下手。所以，你除了要熟悉Lua语言本身之外，应该要先了解Lua和宿主语言之前是怎么配合调用的。所以，开始的内容并没有直接涉及到Lua的源代码。

<!--more-->

# 2. Lua Shell程序
在使用Python的时候，总是有一个命令行的shell可以直接输入Python语句并且执行。那么，如何在自己编写一个类似的可以执行Lua程序的命令行程序呢（当然在Lua的源代码中有一个完整的程序）？可能会觉得会比较复杂，其实，非常简单。新建一个命令行程序的工程，把除了_lua.c_和_luac.c_文件之外的所有文件添加到工程之中。
在程序的*main*的函数中添加如下代码（非完整，后面附上完整代码）：
```
lua_State *L = luaL_newstate(); /* 创建Lua虚拟机 */
luaL_openlibs(L); 				/* 打开标准库 */
int error = 0;
char buff[256];
while (fgets(buff, sizeof(buff), stdin) != NULL)
{
	error = luaL_loadstring(L, buff) || lua_pcall(L, 0, 0, 0);
	if (error)
	{
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_pop(L, 1); /* 从栈中弹出错误消息 */
	}
}
lua_close(L);
```
代码首先创建了一个Lua虚拟机（lua_State），接着打开标准库（不打开也不会有问题，只是所有的库函数都是无法使用的，包括像*print*这种常用函数）。循环就是不听的接受用户的输入。之后调用*luaL_loadstring*和*lua_pcall*函数来执行输入的Lua代码。

# 3. 从文件中执行Lua程序
程序绝大多数都是写在文件中的，如果要在程序中调用Lua文件中的代码，又该如何来做。其实也是非常简单的。代码如下
```
lua_State *L = luaL_newstate(); /* 创建Lua虚拟机 */
luaL_openlibs(L); 				/* 打开标准库 */
int error = 0;
error = luaL_loadfile(L, file) || lua_pcall(L, 0, 0, 0);
if (error)
{
	fprintf(stderr, "%s\n", lua_tostring(L, -1));
	lua_pop(L, 1); /* 从栈中弹出错误消息 */
}
lua_close(L);
```
*luaL_loadfile*函数中的file参数就是文件名称。可以看到，和前面相比，只是把*luaL_loadstring*变成*luaL_loadfile*而已。而且*luaL_loadfile(L, file) || lua_pcall(L, 0, 0, 0);*这一句可以更为简化为一句*luaL_dofile(L, file)*。

# 4. 完整代码
为了便于之后的分析，把两种执行方式全部编写在一个程序里面，使用命令行中是否有参数来做区分。代码如下：
```
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#ifdef __cplusplus
}
#endif


int main(int argc, char** argv)
{
	lua_State *L = luaL_newstate(); /* 创建Lua虚拟机 */
	luaL_openlibs(L); /* 打开标准库 */
	int error = 0;
	if (argc == 1)
	{
		char buff[256];
		while (fgets(buff, sizeof(buff), stdin) != NULL)
		{
			error = luaL_loadstring(L, buff) || lua_pcall(L, 0, 0, 0);
			if (error) 
			{
				fprintf(stderr, "%s\n", lua_tostring(L, -1));
				lua_pop(L, 1); /* 从栈中弹出错误消息 */
			}
		}
	}
	else
	{
		// 第二个为文件
		error = luaL_loadfile(L, argv[1]) || lua_pcall(L, 0, 0, 0);
		if (error)
		{
			fprintf(stderr, "%s\n", lua_tostring(L, -1));
			lua_pop(L, 1); /* 从栈中弹出错误消息 */
		}
	}

	lua_close(L);
	return 0;
}
```

# 5. 可能遇到的问题
在VS下，原来一些字符串操作的函数都被认为是不安全的，这个时候会出现如下的错误：
```
 This function or variable may be unsafe. Consider using fopen_s instead. 
	 To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
```
按照提示在预编译选项中加上**_CRT_SECURE_NO_WARNINGS_** 就可以了，再一次编译就OK了。