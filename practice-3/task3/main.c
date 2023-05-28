#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

const int BUF_SIZE = 100;

int main(int argc, char *argv[]) {
	char *message;

	message = (char *) mmap(NULL, BUF_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0);

	if (fork() == 0) {
		sleep(1);
		printf("child got a message :%s\n", message);
		sprintf(message, "%s", "hi, dad, this is son");
	} else {
		sprintf(message, "%s", "hi, this is father");
		sleep(2);
		printf("parent got a message: %s\n", message);
	}

	munmap(message, BUF_SIZE);

	return 0;
}

/*
常规创建mmap映射区有一点不方便的地方，那就是每次建立映射区都需要依赖一个文件(.txt和fd或者其他)才能实现，
通常为了建立映射区需要open一个临时文件，创建mmap好了之后再unlink、close比较麻烦。
这时候可以直接使用匿名映射来代替，Linux系统提供了一个方法：借助mmap函数的标志位参数flags来制定——使用 MAP_ANONYMOUS(匿名的)
*/