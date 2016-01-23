title: Ref 类
date: 2016-01-03 12:06:00
layout: post
comments: true
categories: Blog
toc: true 
tags: [Ref]
keywords: Cocos2dx, Ref, 引用计数

---
# 0. 介绍
cocos2dx 的内存管理采用的是引用计数的方式来进行处理的，那么，它的引用计数是怎么样实现的呢？其实要想使用cocos2d的内存管理方式来管理内存的分配和释放，那么，必须是Ref类的派生类才可以。那么，下面就来看看Ref这个类做了哪些工作。

<!--more-->

# 1. Ref类声明
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
#endif
};
```

从上面的代码中可以看到，这个类非常简单。就是一个简单的统计引用计数的类。


# 2. Ref类的实现
```
// 构造函数
Ref::Ref()
	: _referenceCount(1) // 当对象被创建的时候，一定是存在引用的，这个时候，初始化计数器为1
{
#if CC_ENABLE_SCRIPT_BINDING
	// 脚本相关的ID初始化为0 
	static unsigned int uObjectCount = 0;
	_luaID = 0;
	_ID = ++uObjectCount;
#endif
	}

	// 析构函数
	Ref::~Ref()
	{
#if CC_ENABLE_SCRIPT_BINDING
	if (_luaID)
	{
		ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptObjectByObject(this);
	}
	else
	{
		ScriptEngineProtocol* pEngine = ScriptEngineManager::getInstance()->getScriptEngine();
		if (pEngine != NULL && pEngine->getScriptType() == kScriptTypeJavascript)
		{
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
#if defined(COCOS2D_DEBUG) && (COCOS2D_DEBUG > 0)
		auto poolManager = PoolManager::getInstance();
		if (!poolManager->getCurrentPool()->isClearing() && poolManager->isObjectInPools(this))
		{
			// Trigger an assert if the reference count is 0 but the Ref is still in autorelease pool.
			// This happens when 'autorelease/release' were not used in pairs with 'new/retain'.
			//
			// Wrong usage (1):
			//
			// auto obj = Node::create();   // Ref = 1, but it's an autorelease Ref which means it was in the autorelease pool.
			// obj->autorelease();   // Wrong: If you wish to invoke autorelease several times, you should retain `obj` first.
			//
			// Wrong usage (2):
			//
			// auto obj = Node::create();
			// obj->release();   // Wrong: obj is an autorelease Ref, it will be released when clearing current pool.
			//
			// Correct usage (1):
			//
			// auto obj = Node::create();
			//                     |-   new Node();     // `new` is the pair of the `autorelease` of next line
			//                     |-   autorelease();  // The pair of `new Node`.
			//
			// obj->retain();
			// obj->autorelease();  // This `autorelease` is the pair of `retain` of previous line.
			//
			// Correct usage (2):
			//
			// auto obj = Node::create();
			// obj->retain();
			// obj->release();   // This `release` is the pair of `retain` of previous line.
			CCASSERT(false, "The reference shouldn't be 0 because it is still in autorelease pool.");
		}
#endif
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

