/*
1. __attribute__((constructor)) / __attribute__((destructor))
__attribute__机制是C的一大特色，可以设置函数属性(Function Attribute),变量属性(Variable Attribute)和类型属性(Type Attribute)
__attribute__((constructor))表示这函数会在执行main()之前执行，如有多个先看是否有设置优先级，
例如__attribute__((constructor(103)))，数字越小表示优先级越高(1~100优先级不让用)

__attribute__((constructor))优先级高的先执行
优先级相同或没设置优先级，则从上到下依次执行

__attribute__((constructor)) void GGG(){
	printf("GGG\n");
}
__attribute__((constructor)) void GGG2(){
	printf("GGG2\n");
}

__attribute__((destructor)) 反过来，优先级高的后执行
优先级相同或没设置优先级，则从下到上反过来依次执行

2.setjmp/longjmp
static jmp_buf buf;
setjmp(buf);    //设置buf的跳转点(记录pc)，返回值为buf对应的返回值
			          //setjmp在顺序执行下来时(不是longjmp跳过来的)返回值为0(实际buf里面记录了当前栈的地址)
			          //setjmp在为longjmp跳转过来时返回值为longjmp中第二个传入的参数
                //setjmp会保存此刻的寄存器(caller reg)与栈顶位置(实际上rsp也是caller reg)，使longjmp执行跳转过来后可以让寄存器状态和栈顶位置恢复(但不会保留栈，栈太大了)
longjmp(buf,2); //把buf对应的返回值设为后面指定的非零整数(这里为2)，并跳转到最后一次设置的跳转点(即修改回原来的pc) (若是后面整数设成0，也会默认改成1的)
                //longjmp跳过去后会把寄存器状态和栈顶位置恢复到之前setjmp保留的状态和位置


3.__asm__ __volatile__
__asm__ __volatile__可以用来内嵌汇编
具体格式为：
__asm__　__volatile__("Instruction List" : Output operand: Input operand: 破坏描述部分);

__asm__:  是GCC关键字asm的宏定义(即两者等价)，用来声明一个内联汇编表达式，所以任何一个内联汇编表达式都是以它开头的，是必不可少的
__volatile__:  是GCC关键字volatile的宏定义(即两者等价)，如果用了它，则是向GCC声明不允许对该内联汇编优化

Instruction List:  是汇编指令序列，语句之间使用";"、"/n"或"/n/t"分开。
指令中的操作数可以使用占位符引用C语言变量,操作数占位符最多10个,名称如下:%0,%1,…,%9,按照出现的顺序依次对应
指令中使用占位符表示的操作数,总被视为long型(4个字节),但对其施加的操作根据指令可以是字或者字节,当把操作数当作字或者字节使用时,默认为低字或者低字节。
对字节操作可以显式的指明是低字节还是次字节。方法是在%和序号之间插入一个字母,"b"代表低字节,"h"代表高字节,例如:%

例如：(x86汇编)
int input=1,result=0;
static inline void test(void){
    __asm__ __volatile__ ("movl %1,%0" :
             "=r" (result) : "r" (input));
     return ;
}
int main(){
	test();
	printf("%d %d\n",input,result);
	return 0;
}
对应汇编代码(x86):
	movl	$1, input(%rip)
	movl	input(%rip), %eax
#APP
# 27 "test.c" 1
	movl %eax,%eax
# 0 "" 2
#NO_APP
	movl	%eax, result(%rip)

“r”表示需要将“result”与某个通用寄存器相关联，先将操作数的值读入寄存器，然后在指令中使用相应寄存器，而不是“result”本身，当然指令执行完后需要将寄存器中的值存入变量“result”，从表面上看好像是指令直接对“result”进行操作
“input”前面的“r”表示该表达式需要先放入某个寄存器，然后在指令中使用该寄存器参加运算

如input前面的"r"换成"m":
	input=1;
    __asm__ __volatile__ ("movl %1,%0" :
             "=r" (result) : "m" (input));

则对应汇编代码(x86)改为:
movl	$1, input(%rip)
#APP
# 27 "test.c" 1
	movl input(%rip),%eax
# 0 "" 2
#NO_APP
	movl	%eax, result(%rip)

变成直接用mem进行movl(不过注意，movl不支持从一个mem转移到另一个mem)

一般来说，"r"/"m"表示的是限定字符串，指定编译器如何处理其后的C语言变量与指令操作数之间的关系，例如是将变量放在寄存器中还是放在内存中等
像"Ir"则表示"I"和"r"这两者皆可
常见限定字符
  “a” 将输入变量放入eax
  “b” 将输入变量放入ebx
  “c” 将输入变量放入ecx
  “d” 将输入变量放入edx
  “s” 将输入变量放入esi
  “d” 将输入变量放入edi
  “q”将输入变量放入eax，ebx  ,ecx  ,edx中的一个
  “r”将输入变量放入通用寄存器，也就是eax ，ebx，ecx,edx，esi，edi中的一个
  "g" : Any register, memory or immediate integer operand is allowed, except for registers that are not general registers
  “A”把eax和edx，合成一个64位的寄存器(uselong longs)
  “m”内存变量
  “o”操作数为内存变量，但是其寻址方式是偏移量类型，也即是基址寻址，或者是基址加变址寻址
  “V”操作数为内存变量，但寻址方式不是偏移量类型
  “,” 操作数为内存变量，但寻址方式为自动增量
  “p”操作数是一个合法的内存地址（指针）
  “I” 0-31 之间的立即数（用于32位移位指令）
  “J” 0-63 之间的立即数（用于64 位移位指令）
  “N” 0-255 之间的立即数（用于out  指令）
  “i” 立即数
  “n” 立即数，有些系统不支持除字以外的立即数，这些系统应该使用“n”而不是“i”

在内嵌的汇编指令中可能会直接引用某些寄存器，我们已经知道AT&T格式的汇编语言中，寄存器名以“%”作为前缀，
为了在生成的汇编程序中保留这个“%”号，在asm语句中对寄存器的引用必须用“%%”作为寄存器名称的前缀。
原因是“%”在asm，内嵌汇编语句中的作用与“/”在C语言中的作用相同，因此“%%”转换后代表“%”。

Output operand:  输出部分描述输出操作数,不同的操作数描述符之间用逗号格开,每个操作数描述符由限定字符串和C语言变量组成。
每个输出操作数的限定字符串必须包含"="表示他是一个输出操作数。

Input operand:  输入部分描述输入操作数,不同的操作数描述符之间用逗号格开,每个操作数描述符由限定字符串和C语言表达式或者C语言变量组成。

破坏描述部分:  
由于我们混用了高级语言和汇编两种语言，内嵌的汇编代码可以直接使用寄存器，而编译器在转换的时候并不去检查内嵌的汇编代码使用了哪些寄存器，
因此需要一种机制通知编译器我们使用了哪些寄存器，否则对这些寄存器的使用就有可能导致错误
破坏描述符用于通知编译器我们使用了哪些寄存器或内存,由逗号格开的字符串组成,每个字符串描述一种情况。一般是寄存器名，除寄存器外还有"memory"。
例如:"%eax","%ebx","memory"等

内嵌汇编的输入输出部分指明的寄存器比如a,b,c,d等或者指定为“r”，“g”型由编译器去分配的寄存器就不需要在破坏描述部分去描述，因为编译器已经知道了

在使用内嵌汇编时请记住一点：尽量告诉GCC尽可能多的信息，以防出错。

例子：
int input=3, output=2,temp=2;
__asm__ __volatile__("movl $0, %%eax;	\
                      movl  %%eax, %1;	\
                      movl  %2, %%eax;	\
                      movl  %%eax, %0; "
                      :"=m"(output),"=m"(temp)    // output
                      :"r"(input)     // input
                      :"eax");  // 破坏描述符
若是破坏描述符中不加入"eax"，编译器可能会令input分配的寄存器正好也为%eax，而这并不是我们想要的

"memory"描述符的作用：
告知GCC
1）不要将该段内嵌汇编指令与前面的指令重新排序；也就是在执行内嵌汇编代码之前，它前面的指令都执行完毕，且它之后的指令没有预先执行
2）不要将变量缓存到寄存器，因为这段代码可能会用到内存变量，而这些内存变量会以不可预知的方式发生改变，因此GCC插入必要的代码先将缓存到寄存器的变量值写回内存，如果后面又访问这些变量，需要重新访问内存。

https://blog.csdn.net/just_lion/article/details/86503541


*/