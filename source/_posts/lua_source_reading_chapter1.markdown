--layout: post

--title: 数据类型结构

--date: 2016/02/05

--comments: false

---

# 0. 写在前面
第一篇想了好久也不知道从什么地方下手。开始的时候想从main函数开始分析，后来发现
行不通。一下子牵扯的东西太多了，自己一下子容易陷入迷茫。这个时候想到了自己学习
一门新语言的方式。都是从最简单的数据类型开始的，这个是一个语言的基础，同时，它
也是最容易的部分。那么就从它的数据类型下手吧！


# 1. TValue
虽然学习它的数据类型很简单，但是看源代码也就没有那么轻松了。TValue是一个typedef，
而且被多次typedef。内容如下：

```
/* 1 */
typedef struct lua_TValue TValue;

/* 2 */
struct lua_TValue {
  TValuefields;
};

/* 3 */
/* little endian */
#define TValuefields  \
	union { struct { Value v__; int tt__; } i; double d__; } u
	
/* 4, 继续看Value */
/*
** Union of all Lua values
*/
typedef union Value Value;

/* 5 */
union Value {
  GCObject *gc;    /* collectable objects */
  void *p;         /* light userdata */
  int b;           /* booleans */
  lua_CFunction f; /* light C functions */
  numfield         /* numbers */
};

/* 6. 再看GCObject */
/*
** Union of all collectable objects
*/
typedef union GCObject GCObject;

/* 7 */
/*
** Union of all collectable objects
*/
union GCObject {
  GCheader gch;  /* common header */
  union TString ts;
  union Udata u;
  union Closure cl;
  struct Table h;
  struct Proto p;
  struct UpVal uv;
  struct lua_State th;  /* thread */
};

/* 8. 再看GCHeader */
/*
** Common header in struct form
*/
typedef struct GCheader {
  CommonHeader;
} GCheader;

/* 9. 看CommonHeader 头已经晕乎 */
#define CommonHeader	GCObject *next; lu_byte tt; lu_byte marked
```

把现在需要的部分展开如下所示:

```
typedef struct lua_TValue 
{	
	// TValuefields;
	union 
	{ 
		struct 
		{ 
			// Value v__; 
			union Value 
			{
				// GCObject *gc;    /* collectable objects */
				union GCObject
				{
					// GCheader gch;  /* common header */
					struct GCheader 
					{
						// CommonHeader;
						GCObject* next; 
						lu_byte tt; 
						lu_byte marked;
					} gch;

					union TString ts;
					union Udata u;
					union Closure cl;
					struct Table h;
					struct Proto p;
					struct UpVal uv;
					struct lua_State th;  /* thread */
				}* gc;	

				void *p;         /* light userdata */
				int b;           /* booleans */
				lua_CFunction f; /* light C functions */
				numfield         /* numbers */
			} v__;
			
			int tt__; 
		} i; 
		double d__; 
	} u;
 
} TValue;
```
