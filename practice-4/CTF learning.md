## x86部分汇编指令拆分

![68631468509](picture\1686314685097.png)

注意，我们x86是32位，每个寄存器都是32位，x64(我们一般的电脑)是64位，每个寄存器都是64位。x86/x64指令都是变长编码，指令长度从1~15bytes不等。

如果我们在x64中执行push指令，rsp减的值应该和push的寄存器位数有关



如果我们在代码中调用 `return` ，x86-64中实际上执行的是

```
leaveq
retq
```

其中

```
leaveq
<===>
movq %rbp, %rsp
popq %rbp
表示的是把rsp改到rbp的位置上，并把rbp
```

要注意的是，如果当前函数中没有调用过任何其他函数，它会优化掉，即从头到尾都不会修改rsp，最后return的时候也变成

```
popq %rbp
retq
```





## 动态链接

动态链接是在程序开始运行是才开始运行，程序运行时先调用加载器(loader)，把代码与数据读入内存，并执行动态链接，最终开始执行代码。

动态链接的总过程：当我们要运行P1这个程序的时候，系统会首先加载P1.o，当系统发现P1.o要用到Lib.o的时候，系统接着会加载Lib.o，如果P1.o或Lib.o还依赖与其他目标文件，系统会按照这种方式将它们全部加载至内存。所有需要的目标文件加载完成之后，如果依赖关系得到满足即所有依赖的目标文件都存在于磁盘，系统开始进行链接工作。这个链接工作的原理与静态链接非常相似，包括符号解析、地址重定位等。完成这些步骤之后，系统开始把控制权交给P1.o的程序入口处，程序开始运行。这时候时候如果我们需要运行P2，那么系统只需要加载P2.o，而不需要重新加载Lib.o，因为内存中已经存在了一份Lib.o的副本，系统要做的只是将P2.o和Lib.o链接起来。



## ROP（Return-Oriented Programming, 返回导向编程）

ROP就是使用返回指令ret连接代码的一种技术（同理还可以使用jmp系列指令和call指令，有时候也会对应地成为JOP/COP）。一个程序中必然会存在函数，而有函数就会有ret指令。我们知道，ret指令的本质是pop eip，即把当前栈顶的内容作为内存地址进行跳转。

而ROP就是利用栈溢出在栈上布置一系列内存地址，每个内存地址对应一个gadget，即以ret/jmp/call等指令结尾的一小段汇编指令，通过一个接一个的跳转执行某个功能。由于这些汇编指令本来就存在于指令区，肯定可以执行，而我们在栈上写入的只是内存地址，属于数据，所以这种方式可以有效绕过NX保护。



### gadget

**gadget** 就是以 ret 结尾的指令序列，通过这些指令序列，我们可以修改某些地址的内容，方便控制程序的执行流程。

x64 程序的前六个参数依次通过寄存器 rdi、rsi、rdx、rcx、r8、r9 进行传递，我们所找的 gadget 自然也是针对这些寄存器进行操作的。



## hack脆弱程序打开sh

一些ctf题目中(如我们这道题中)，我们要做的是 **调用system函数执行system(“/bin/sh”)** ，由此我们需要找到 libc中的 **system()** 和 **“/bin/sh”(字符串)** 的地址位置。

注意libc.so是动态链接的，我们不能直接得到一个绝对地址，而是要想办法通过分析给定的vulnerable的程序想办法得到任何一个libc中的一个地址并知道它对应的汇编代码在哪里，这样就可以通过间接方式找到任何我们需要的libc.so中的地址，包括 **system(),“/bin/sh”(字符串)** 和任何我们需要的libc中的 **gadget** 的地址





## IDA使用

IDA反汇编程序和调试器是一个交互式、可编程、可扩展的多处理器反汇编程序。

官网下载：https://hex-rays.com/  (IDA free免费)

只需要在IDA中打开相应二进制文件即可反汇编，使用View->Open subviews->Generate pseudocode(F5) 即可生成伪代码



## ROPgadget使用

This tool lets you search your gadgets on your binaries to facilitate your ROP exploitation. ROPgadget supports ELF/PE/Mach-O/Raw formats on x86, x64, ARM, ARM64, PowerPC, SPARC, MIPS, RISC-V 64, and RISC-V Compressed architectures.

github网址：https://github.com/JonathanSalwan/ROPgadget

根据上面的提示安装和使用即可

(实际上我安装的时候好像有点问题，使得并没有把 `ROPgadget` 改成命令行指令，而是必须进入下载的文件夹中的 `ROPgadget-master/scripts` 手动 `./ROPgadget` )

使用方式在github repo下面都有详细介绍 或者 `./ROPgadget --help` 查看

几个常用的

```
./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --only "ret"
./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 | grep "pop rdi ; ret"
./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --string "/bin/sh"
```



具体下载到的位置在 `~/Desktop/ROPgadget-master` 