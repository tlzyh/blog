title: Cocos2dx源码阅读 -- Ref
date: 2016-02-16 09:50:00
layout: post
comments: true
categories: Cocos2dx源码阅读
toc: true 
tags: Cocos2dx
keywords: Cocos2dx, Ref

---

# 0. 介绍
cocos2dx 的内存管理采用的是引用计数的方式来进行处理的，那么，它的引用计数是怎么样实现的呢？其实要想使用cocos2d的内存管理方式来管理内存的分配和释放，那么，必须是Ref类的派生类才可以。那么，下面就来看看Ref这个类做了哪些工作。

# 1. Clone接口
该接口是所有引擎中类的顶级基类，定义了Clone的接口。如下所示：

```
class CC_DLL Clonable
{
public:
	// 实现拷贝，返回clone之后的实例
    virtual Clonable* clone() const = 0;
    
    // 析构
    virtual ~Clonable() {};
};
```
该类是一个抽象类，只是定义了子类要实现的接口。

<!--more-->

# 2. Ref类声明
Ref类，从字面意思上就知道是引用计数用的。所有要使用引擎引用计数来管理内存的，就必须继承于该类。类声明如下所示：

```
class CC_DLL Ref
{
	public:
		// 从它的字面意思上就可以知道，它的功能就是把引用计数器加1，来
		// 保留需要保留的实例。
		void retain();
		

		// 显而易见，它是负责释放实例的。当引用计数器为0的时候，那么，
		// 实例将被释放掉。
		void release();

		
		// 这个方法，开始的时候，不太好理解。可以认为是一种延迟释放的处理。
		// 这里先不做过多的解释。后续会回过头来看这个函数。
		Ref* autorelease();

		
		// 返回引用计数的个数
		unsigned int getReferenceCount() const;

	protected:
		// 构造函数，没有公开，表示，该类不应该直接生成实例，必须由
		// 子类继承。
		Ref();

	public:
		// 析构函数
		virtual ~Ref();

	protected:
		// 引用计数变量
		unsigned int _referenceCount;

		// 自动释放池，后面详细分析
		friend class AutoreleasePool;

	// 判定是否需要使用脚本绑定
#if CC_ENABLE_SCRIPT_BINDING
	public:
		// 对象ID，脚本绑定需要
		unsigned int        _ID;
		
		// lua的绑定ID
		int                 _luaID;
        
        // 脚本对象，用于支持Swift
		void* _scriptObject;
#endif
};

```

# 3. Ref类实现

```
// 构造函数
Ref::Ref()
	: _referenceCount(1) // 当对象被创建的时候，一定是存在引用的，这个时候，初始化计数器为1
{
#if CC_ENABLE_SCRIPT_BINDING
	// 脚本相关的ID初始化为0 
	static unsigned int uObjectCount = 0; // 总对象个数
	_luaID = 0; // 初始化id为0
	_ID = ++uObjectCount; 
    _scriptObject = nullptr; // swift脚本对象
#endif
}

// 析构函数
Ref::~Ref()
{
#if CC_ENABLE_SCRIPT_BINDING
	if (_luaID)
	{
    	// 从Lua脚本引擎管理器中移除该对象
		ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptObjectByObject(this);
	}
	else
	{
		ScriptEngineProtocol* pEngine = ScriptEngineManager::getInstance()->getScriptEngine();
        // js脚本对象移除
		if (pEngine != NULL && pEngine->getScriptType() == kScriptTypeJavascript)
		{
        	// 移除该对象
			pEngine->removeScriptObjectByObject(this);
		}
	}
#endif
}

// 增加计数器
void Ref::retain()
{
	CCASSERT(_referenceCount > 0, "reference count should greater than 0");
	++_referenceCount;
}

void Ref::release()
{
	CCASSERT(_referenceCount > 0, "reference count should greater than 0");
	// 减少计数器
	--_referenceCount;

	// 如果此时计数器为0，表示没有地方引用了，可以delete掉了
	if (_referenceCount == 0)
	{
		delete this;
	}
}

// 将实例添加到释放池
Ref* Ref::autorelease()
{
	PoolManager::getInstance()->getCurrentPool()->addObject(this);
	return this;
}

// 获得引用计数的数量
unsigned int Ref::getReferenceCount() const
{
	return _referenceCount;
}

```


