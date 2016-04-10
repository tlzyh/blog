title: 第2篇 - Lua栈操作
date: 2016-04-02
layout: post
comments: true
categories: Lua源码分析
toc: false
tags: [Lua]
keywords: Lua, 源码阅读

---

# 0. 介绍
在开始学习Lua的时候，接触最多的概念就是Lua中的栈，但是，在编写Lua脚本的时候其实不需要知道Lua的栈的操作，但是，如果你想在你自己的程序中集成Lua，那么，对Lua的栈操作是必须一清二楚的。

Lua中的栈是一个严格的LIFO(后进先出)的结构，元素的添加只能通过Push的方式添加到栈顶。对指定的元素的操作，需要通过指定索引。在Lua中，元素的索引从1开始，因此，最先被压栈的元素的索引为1。同时，索引可以为负数，表示的是相对于栈顶的操作，-1表示的就是栈顶元素的索引，这样，简化了获取栈顶的过程。

<!--more-->

## 1. 压栈
在宿主语言中，通常要将数据传递给Lua脚本程序，那么，数据如何传递呢？Lua提供了对应类型的压栈函数。代码如下：
```
LUA_API void        (lua_pushnil) (lua_State *L);
LUA_API void        (lua_pushnumber) (lua_State *L, lua_Number n);
LUA_API void        (lua_pushinteger) (lua_State *L, lua_Integer n);
LUA_API const char *(lua_pushlstring) (lua_State *L, const char *s, size_t len);
LUA_API const char *(lua_pushstring) (lua_State *L, const char *s);
LUA_API const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
LUA_API const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
LUA_API void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
LUA_API void  (lua_pushboolean) (lua_State *L, int b);
LUA_API void  (lua_pushlightuserdata) (lua_State *L, void *p);
LUA_API int   (lua_pushthread) (lua_State *L);
```
| 函数 | 功能 |
|--------|--------|
|    lua_pushnil    |    压栈nil    |
|    lua_pushnumber    |    压栈一个数字    |
|    lua_pushinteger    |    压栈整数    |
|    lua_pushlstring    |    压栈字符串，需要制定长度（可能是非零结尾的字符串）    |
|    lua_pushstring    |    压栈零结尾的字符串    |
|    lua_pushvfstring    |    压栈变长字符串    |
|    lua_pushfstring    |    类似lua_pushvfstring，多了一步处理va_list    |
|    lua_pushcclosure    |    压栈C闭包    |
|    lua_pushboolean    |    压栈布尔值    |
|    lua_pushlightuserdata    |    压栈UserData    |
|    lua_pushthread    |    压栈Thread    |



















