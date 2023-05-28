#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include <string.h>
int main(){
    
    pid_t pid;
    // OPEN FILES
    int fd;
    fd = open("test.txt" , O_RDWR | O_CREAT | O_TRUNC);
    if (fd == -1)
    {
        /* code */
        printf("error in open");
		return -1;
    }
    //write 'hello fcntl!' to file

    /* code */

	const char* str = "hello fcntl!";
    write(fd, str, strlen(str));

    // DUPLICATE FD

    /* code */
    
    //你需要使用`fcntl`复制当前的文件标识符，并且通过`fork`生成另外一个进程
    int new_fd=fcntl(fd,F_DUPFD,0);
    // FORK
    pid = fork();


    if(pid < 0){
        // FAILS
        printf("error in fork");
        return 1;
    }
    
    struct flock fl;

    if(pid > 0){
        // PARENT PROCESS
        //set the lock
        fl.l_type = F_WRLCK;
        fl.l_whence = SEEK_SET;
        fl.l_start = 0;
        fl.l_len = 0;
        // 这里设置了开始位置为0(l_where和l_start)，长度为0(l_start)(即为加锁到结尾，如果文件长度自动变化，也会自动调整加锁的末尾位置)，即锁定整个文件
        // fl.l_pid在设置文件锁时不需要设置，因为内核会自动设置
        // 使用fcntl(new_fd,F_SETLK,&fl)会立即返回，不管是否获得锁
        // 使用fcntl(new_fd,F_SETLKW,&fl)会阻塞直到获得锁
        // 使用fcntl(new_fd,F_GETLK,&fl)会返回当前锁的状态
        fcntl(new_fd,F_SETLKW,&fl);

        //在文件最后append 'b'
        lseek(new_fd,0,SEEK_END);
        const char* str_b = "b";
        write(new_fd,str_b,strlen(str_b));
        
        //unlock
        fl.l_type = F_UNLCK;
        fcntl(new_fd,F_SETLK,&fl);
        
        sleep(3);

        //read
        char str[30];
        lseek(new_fd,0,SEEK_SET);
        read(new_fd,str,sizeof(str));

        printf("%s", str); // the feedback should be 'hello fcntl!ba'
        
        exit(0);

    } else {
        // CHILD PROCESS
        sleep(2);
        //get the lock
        fl.l_type = F_WRLCK;
        fl.l_whence = SEEK_SET;
        fl.l_start = 0;
        fl.l_len = 0;
        fcntl(new_fd,F_SETLKW,&fl);
        
        //在最后append 'a'
        lseek(new_fd,0,SEEK_END);
        const char* str_a = "a";
        write(new_fd,str_a,strlen(str_a));

        exit(0);
    }
    close(fd);
    return 0;
}


/*
int fcntl(int fd, int cmd);
int fcntl(int fd, int cmd, long arg);
int fcntl(int fd, int cmd, struct flock *lock);
通过fcntl()可以改变已打开的文件性质。
fcntl()可以完成的工作包括：复制一个现有的描述符(cmd=F_DUPFD)、获得/设置文件描述符标记(cmd=F_GETFD或F_SETFD)、获得/设置文件状态标记(cmd=F_GETFL或F_SETFL)、获得/设置异步I/O所有权(cmd=F_GETOWN或F_SETOWN)、获得/设置文件锁(cmd=F_GETLK或F_SETLK)。

参数:
    fd代表欲设置的文件描述符
    cmd代表打算操作的指令,其中
        F_DUPFD用来查找大于或等于参数arg的最小且仍未使用的文件描述符，并且复制参数fd的文件描述符。执行成功则返回新复制的文件描述符。新描述符与fd共享同一文件表项，但是新描述符有它自己的一套文件描述符标志，其中FD_CLOEXEC文件描述符标志被清除。请参考dup2()。
        F_GETFD取得close-on-exec旗标。若此旗标的FD_CLOEXEC位为0，代表在调用exec()相关函数时文件将不会关闭。
        F_SETFD 设置close-on-exec旗标。该旗标以参数arg 的FD_CLOEXEC位决定。
        F_GETFL 取得文件描述符状态旗标，此旗标为open（）的参数flags。
        F_SETFL 设置文件描述符状态旗标，参数arg为新旗标，但只允许O_APPEND、O_NONBLOCK和O_ASYNC位的改变，其他位的改变将不受影响。
        F_GETLK 取得文件锁定的状态。
        F_SETLK 设置文件锁定的状态。此时flcok 结构的l_type 值必须是F_RDLCK、F_WRLCK或F_UNLCK。如果无法建立锁定，则返回-1，错误代码为EACCES 或EAGAIN。
        F_SETLKW 和F_SETLK 作用相同，但是无法建立锁定时，此调用会一直等到锁定动作成功为止。若在等待锁定的过程中被信号中断时，会立即返回-1，错误代码为EINTR。
	参数lock指针为flock 结构指针，定义如下
	struct flock{
		short int l_type;
		short int l_whence;
		off_t l_start;
		off_t l_len;
		pid_t l_pid;
	};
		l_type 有三种状态:
			F_RDLCK 建立一个供读取用的锁定
			F_WRLCK 建立一个供写入用的锁定
			F_UNLCK 删除之前建立的锁定
		l_whence 也有三种方式:
			SEEK_SET 以文件开头为锁定的起始位置。
			SEEK_CUR 以目前文件读写位置为锁定的起始位置
			SEEK_END 以文件结尾为锁定的起始位置。
		l_start 表示相对l_whence位置的偏移量，两者一起确定锁定区域的开始位置。
		l_len 表示锁定区域的长度，如果为0表示从起点(由l_whence和 l_start决定的开始位置)开始直到最大可能偏移量为止。即不管在后面增加多少数据都在锁的范围内。
返回值：
	成功返回依赖于cmd的值，若有错误则返回-1，错误原因存于errno.
*/