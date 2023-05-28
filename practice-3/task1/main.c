#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char *argv[]) {

	int fd = -1;
	struct stat sb;
	char *mmaped = NULL;
	fd = open(argv[1], O_RDWR);//O_RDWR:打开读写
	if (fd == -1) {
		fprintf(stderr, "fail on open %s\n", argv[1]);
		return -1;
	}

	if (stat(argv[1], &sb) == -1) {
		fprintf(stderr, "fail on stat %s\n", argv[1]);
		close(fd);
		return -1;
	}
	// stat类型中记录着文件相关的心信息，如sb.st_size为file容量
	mmaped = (char *)mmap(NULL, sb.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0); //令file和内存产生映射
	if (mmaped == (char *)-1) {
		fprintf(stderr, "fail on mmap %s\n", argv[1]);
		close(fd);
		return -1;
	}

	close(fd);

	printf("--- The file before modification:\n\n");
	printf("%s\n\n", mmaped);

	// write anything you like to the mmaped file

	mmaped[0] = 'l';

	if (msync(mmaped, sb.st_size, MS_SYNC) == -1) {
		fprintf(stderr, "fail on msync %s\n", argv[1]);
		munmap(mmaped, sb.st_size);
		return -1;
	}

	printf("--- The file after modification:\n\n");
	printf("%s\n", mmaped);

	munmap(mmaped, sb.st_size);

	return 0;
}

/*
mmap函数：void *mmap(void *addr, size_t length, int prot, int flags,int fd, off_t offset);
令file和内存产生映射
头文件：#include <sys/mman.h>
返回值：
	成功返回创建的映射区的首地址；失败返回宏 MAP_FAILED。

参数介绍：
	addr: 建立映射区的首地址，由 Linux 内核指定。使用时，直接传递 NULL。
	length： 欲创建映射区的大小。
	prot： 映射区权限 PROT_READ、PROT_WRITE、PROT_READ|PROT_WRITE。
	flags： 标志位参数(常用于设定更新物理区域、设置共享、创建匿名映射区)；
	MAP_SHARED: 会将映射区所做的操作反映到物理设备（磁盘）上。
	MAP_PRIVATE: 映射区所做的修改不会反映到物理设备。
	fd： 用来建立映射区的文件描述符。
	offset： 映射文件的偏移(4k 的整数倍)。


munmap 函数：int munmap( void * addr, size_t len);
取消对应的映射区
返回值：
	成功：0； 失败：-1
*/