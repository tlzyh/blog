--layout: post

--title: 指令格式

--date: 2016/02/05

--comments: false

---


# 0. 介绍
这是lua源码分析的第一篇正式的日志。刚开始学习lua语言的时候，看到它的实现只有一
万多行代码。心里一直想看看它的实现。刚过完年的时候，就有这个打算。但是，乱七八
糟的事情，加上自己的懒惰，尽管很久之前就开了个头，但是，没有坚持看把代码看下去。
想想现在都快12月份了，再不看，今年都过去了。

在知乎上有很多的网友推荐看看Lua的源代码，我也尝试了两次。但是，Lua的代码太干净
了，连变量的命令都干净到让人发指。一直也没有找到好的入口点。后来，想了想，自己
的毕业设计就是做的一个Dos的模拟器，所以，指令的解析这一块自己也有一点经验，于是，
这件事情就再一次开始了。自己也会一直看下去，直到看完最后一行代码。

# 1. 基本指令格式
在Lua中，指令有4种类型，结构如下图所示：

{{../../images/lua_src/instruction_format.png}}

指令各个字段的大小在图中已经给出。指令字段中的所有的值，除了sBx之外其他的都是
无符号整数。这里需要特别注意sBx的值，它的0值不是0而是它的无符号所能表示的最大
的值（262143）得中间值：131071。所以，它的1表示为 131071 + 1，反之-1表示为
131071 - 1。

指令格式定义在lopcodes.h文件中，代码定义如下所示：

```
	enum OpMode {iABC, iABx, iAsBx, iAx};  /* basic instruction format */
```
对应上图中的各个类型。

# 2. 指令相关常量定义和宏函数
为了便于对指令的操作，lua定义了一系列的宏常量和宏函数。代码注释如下：

```
// 位置相关的常量

// C域的大小
#define SIZE_C		9
// B域的大小
#define SIZE_B		9
// Bx的大小 = C + B = 18
#define SIZE_Bx		(SIZE_C + SIZE_B)
// A大小
#define SIZE_A		8
// Ax大小 = A + B + C = 26
#define SIZE_Ax		(SIZE_C + SIZE_B + SIZE_A)

// 操作码的大小
#define SIZE_OP		6

// 操作码开始于 0 bit
#define POS_OP		0
#define POS_A		(POS_OP + SIZE_OP)
#define POS_C		(POS_A + SIZE_A)
#define POS_B		(POS_C + SIZE_C)
#define POS_Bx		POS_C
#define POS_Ax		POS_A


// 下面给出了Bx和sBx可以表示的最大的值
// MAXARG_Bx = 262143
// MAXARG_sBx = 131071（见上）
#if SIZE_Bx < LUAI_BITSINT-1
#define MAXARG_Bx        ((1<<SIZE_Bx)-1)
#define MAXARG_sBx        (MAXARG_Bx>>1)
#else
#define MAXARG_Bx        MAX_INT
#define MAXARG_sBx        MAX_INT
#endif

#if SIZE_Ax < LUAI_BITSINT-1
// 计算Ax可以表示的最大值
#define MAXARG_Ax	((1<<SIZE_Ax)-1)
#else
#define MAXARG_Ax	MAX_INT
#endif

// 计算A，B，C的最大值
#define MAXARG_A        ((1<<SIZE_A)-1)
#define MAXARG_B        ((1<<SIZE_B)-1)
#define MAXARG_C        ((1<<SIZE_C)-1)


// 创建一个前面n个bit为1，后面p个bit为0的数
#define MASK1(n,p)	((~((~(Instruction)0)<<(n)))<<(p))

// 上面的值取反
#define MASK0(n,p)	(~MASK1(n,p))

// 从指令中提取出操作码
#define GET_OPCODE(i)	(cast(OpCode, ((i)>>POS_OP) & MASK1(SIZE_OP,0)))
// 设置指令操作码
#define SET_OPCODE(i,o)	((i) = (((i)&MASK0(SIZE_OP,POS_OP)) | \
		((cast(Instruction, o)<<POS_OP)&MASK1(SIZE_OP,POS_OP))))

// 获得指令中pos开始后面的size个bit的数
#define getarg(i,pos,size)	(cast(int, ((i)>>pos) & MASK1(size,0)))
// 设置pos开始后面的size个bit的值
#define setarg(i,v,pos,size)	((i) = (((i)&MASK0(size,pos)) | \
                ((cast(Instruction, v)<<pos)&MASK1(size,pos))))

// A 的获得和设置
#define GETARG_A(i)	getarg(i, POS_A, SIZE_A)
#define SETARG_A(i,v)	setarg(i, v, POS_A, SIZE_A)

// B 的获得和设置
#define GETARG_B(i)	getarg(i, POS_B, SIZE_B)
#define SETARG_B(i,v)	setarg(i, v, POS_B, SIZE_B)

// C 的获得和设置
#define GETARG_C(i)	getarg(i, POS_C, SIZE_C)
#define SETARG_C(i,v)	setarg(i, v, POS_C, SIZE_C)

// Bx 的获得和设置
#define GETARG_Bx(i)	getarg(i, POS_Bx, SIZE_Bx)
#define SETARG_Bx(i,v)	setarg(i, v, POS_Bx, SIZE_Bx)

// Ax 的获得和设置
#define GETARG_Ax(i)	getarg(i, POS_Ax, SIZE_Ax)
#define SETARG_Ax(i,v)	setarg(i, v, POS_Ax, SIZE_Ax)

// sBx 的获得和设置
#define GETARG_sBx(i)	(GETARG_Bx(i)-MAXARG_sBx)
#define SETARG_sBx(i,b)	SETARG_Bx((i),cast(unsigned int, (b)+MAXARG_sBx))

// 创建 iABC指令
#define CREATE_ABC(o,a,b,c)	((cast(Instruction, o)<<POS_OP) \
			| (cast(Instruction, a)<<POS_A) \
			| (cast(Instruction, b)<<POS_B) \
			| (cast(Instruction, c)<<POS_C))

// 创建iABx指令
#define CREATE_ABx(o,a,bc)	((cast(Instruction, o)<<POS_OP) \
			| (cast(Instruction, a)<<POS_A) \
			| (cast(Instruction, bc)<<POS_Bx))

// 创建iAx指令
#define CREATE_Ax(o,a)		((cast(Instruction, o)<<POS_OP) \
			| (cast(Instruction, a)<<POS_Ax))

// 第9个bit如果为1表示常量，反之为寄存器
#define BITRK		(1 << (SIZE_B - 1))

// 检查是否是一个常量
#define ISK(x)		((x) & BITRK)

// 获得常量的索引
#define INDEXK(r)	((int)(r) & ~BITRK)

// 最大的索引，最高位表示的是一个标志，所以最大的个数为 BITRK - 1
#define MAXINDEXRK	(BITRK - 1)

// TODO
#define RKASK(x)	((x) | BITRK)

// 无效的寄存器（255）
// 那么是否表明，有效的寄存器个数为 254个呢？
#define NO_REG		MAXARG_A
```

# 3. 总结
Lua的指令结构的种类看上去比x8086的格式总图上来看还要多3种。在x8086中，指令的格式
就只有一张图，看上去好像要比这个简单。但是事实上并非如此。在那个硬件比较昂贵的
年代，每一个bit都是极其珍贵，但是，要用看上去简单的指令去实现复杂的功能，所以，
最后的结果就是，变得更为复杂。在Lua的指令中只要注意一个有符号的数sBx的表示方法，
其他的遇到了，直接对号入座即可。

