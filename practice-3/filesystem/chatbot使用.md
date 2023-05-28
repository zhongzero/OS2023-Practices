具体实现为 ` ./fuse-3.14.1/example/my_bot.c` 

使用方法：

命令行进入 `./fuse-3.14.1/example` 

编译指令

```
gcc -Wall my_bot.c `pkg-config fuse3 --cflags --libs` -o my_bot
```

挂载我的filesystem到 `~/test/` 目录下

```
./my_bot ~/test/
(./my_bot ~/test/ -f) 使用-f编译选项，使得程序运行在前端，方便调试，而且这样之后就不需要关闭后端挂载
```

此时就可以进入 `~/test/` 使用chatbot了，具体使用方式在挂载目录的根目录下的 `README.txt` 中有详细介绍

关闭后端挂载

```
fusermount -u ~/test/
```







权限设置 形如 `drwxr-xr-x` 

第一个表示为文件夹/文件，后面三组 `rwx` 分别表示 文件所有者( `file.vstat.st_uid = getuid()` )，文件所有者同组用户( `file.vstat.st_gid = getgid()` )，其它用户 的权限

read：对文件而言，具有读取文件内容的权限( `cat` )；对文件夹而言，具有浏览文件夹信息的权限( `ls` )

write：对文件而言，具有修改文件内容的权限( `echo "xxx" > xxx` )；对文件夹而言，具有创建删除移动目录内文件/文件夹的权限(其子目录内的文件/文件夹的创建删除移动不依靠当前目录) ( `touch,rm,mkdir,rmdir` )

execute：对文件而言，具有执行文件的权限；对文件夹而言，具有进入文件夹的权限( `cd` )