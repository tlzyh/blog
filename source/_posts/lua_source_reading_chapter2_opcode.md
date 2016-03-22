title: 操作码
date: 2016-03-21
layout: post
comments: true
categories: Lua源码分析
toc: false 
tags: [Lua]
keywords: Lua, 源码阅读

---


# 0. 介绍
操作码可以说是一个指令的最为关键的部分了。它决定了这个指令的功能，其他的只是为了实现这个功能而附加的参数而已。下面来看看lua中有哪些操作码。

# 1. 指令表示
在Lua的源代码中有三种参数的表示，如下所示：

* R(x) 表示的是寄存器
* Kst(x) 表示常量（在常量表中） 
* RK(x) 该值可能是寄存器也可能是常量，if ISK(x) then Kst(INDEXK(x)) else R(x)

<!--more-->

具体参数如下表所示：

标记            | 意义 
---------------|--------------------------------
R(A)           | 寄存器A
R(B)           | 寄存器B                    
R(C)           | 寄存器C                    
PC             | 程序计数器                 
Kst(n)         | 见上                       
UpValue[index] | 索引为index的UpValue的名称 
Gbl[sym]       | 标记为sym的全局变量        
RK(B)          | 见上                       
RK(C)          | 见上                       
sBx            | 带符号的偏移，用于跳转 

# 2. 操作码
在x8086中，操作码有200多个。在Lua5.2中，操作码增加到了40个。详细信息如下表所示：

Opcode| 名字        | 参数   | 描述                                                          
------|-------------|--------|----------
0x00  | OP_MOVE     | A B    | R(A) := R(B)                                                  
0x01  | OP_LOADK    | A Bx   | R(A) := Kst(Bx)                                               
0x02  | OP_LOADKX   | A      | R(A) := Kst(extra arg)                                        
0x03  | OP_LOADBOOL | A B C  | R(A) := (Bool)B; if (C) pc++                                  
0x04  | OP_LOADNIL  | A B    | R(A), R(A+1), ..., R(A+B) := nil                              |
0x05  | OP_GETUPVAL | A B    | R(A) := UpValue[B]                                            
0x06  | OP_GETTABUP | A B C  | R(A) := UpValue[B][RK(C)]                                     
0x07  | OP_GETTABLE | A B C  | R(A) := R(B)[RK(C)]                                           
0x08  | OP_SETTABUP | A B C  | UpValue[A][RK(B)] := RK(C)                                    
0x09  | OP_SETUPVAL | A B    | UpValue[B] := R(A)                                            
0x0A  | OP_SETTABLE | A B C  | R(A)[RK(B)] := RK(C)                                          
0x0B  | OP_NEWTABLE | A B C  | R(A) := {} (size = B,C)                                       
0x0C  | OP_SELF     | A B C  | R(A+1) := R(B); R(A) := R(B)[RK(C)]                           
0x0D  | OP_ADD      | A B C  | R(A) := RK(B) + RK(C)                                         
0x0E  | OP_SUB      | A B C  | R(A) := RK(B) - RK(C)                                         
0x0F  | OP_MUL      | A B C  | R(A) := RK(B) * RK(C)                                         
0x10  | OP_DIV      | A B C  | R(A) := RK(B) / RK(C)                                         
0x11  | OP_MOD      | A B C  | R(A) := RK(B) % RK(C)                                         
0x12  | OP_POW      | A B C  | R(A) := RK(B) ^ RK(C)                                         
0x13  | OP_UNM      | A B    | R(A) := -R(B)                                                 
0x14  | OP_NOT      | A B    | R(A) := not R(B)                                              
0x15  | OP_LEN      | A B    | R(A) := length of R(B)                                        
0x16  | OP_CONCAT   | A B C  | R(A) := R(B).. ... ..R(C)                                     
0x17  | OP_JMP      | A sBx  | pc+=sBx; if (A) close all upvalues >= R(A) + 1                
0x18  | OP_EQ       | A B C  | if ((RK(B) == RK(C)) ~= A) then pc++                          
0x19  | OP_LT       | A B C  | if ((RK(B) <  RK(C)) ~= A) then pc++                          
0x1A  | OP_LE       | A B C  | if ((RK(B) <= RK(C)) ~= A) then pc++                          
0x1B  | OP_TEST     | A C    | if not (R(A) <=> C) then pc++                                 
0x1C  | OP_TESTSET  | A B C  | if (R(B) <=> C) then R(A) := R(B) else pc++                   
0x1D  | OP_CALL     | A B C  | R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))            
0x1E  | OP_TAILCALL | A B C  | return R(A)(R(A+1), ... ,R(A+B-1))                            
0x1F  | OP_RETURN   | A B    | A B	return R(A), ... ,R(A+B-2)                               
0x21  | OP_FORLOOP  | A sBx  | R(A)+=R(A+2);if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) } 
0x22  | OP_FORPREP  | A sBx  | R(A)-=R(A+2); pc+=sBx                                         
0x23  | OP_TFORCALL | A C    | R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));                
0x24  | OP_TFORLOOP | A sBx  | if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }              
0x25  | OP_SETLIST  | A B C  | R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B                      
0x26  | OP_CLOSURE  | A Bx   | R(A) := closure(KPROTO[Bx])                                   
0x27  | OP_VARARG   | A B    | R(A), R(A+1), ..., R(A+B-2) = vararg                          
0x28  | OP_EXTRAARG | Ax     | extra (larger) argument for previous opcode

