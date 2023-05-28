#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>


int main(int argc, char *argv[]) {

	int fd = -1;
	struct stat sb;
	char *mmaped = NULL;

	fd = open(argv[1], O_RDWR);
	if (fd == -1) {
		fprintf(stderr, "fail on open %s\n", argv[1]);
		return -1;
	}

	if (stat(argv[1], &sb) == -1) {
		fprintf(stderr, "fail on stat %s\n", argv[1]);
		close(fd);
		return -1;
	}

	//这里使用MAP_SHARED，会将映射区所做的操作反映到物理设备（磁盘）上，即实现了共享映射空间
	mmaped = (char *)mmap(NULL, sb.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (mmaped == (char *)-1) {
		fprintf(stderr, "fail on mmap %s\n", argv[1]);
		close(fd);
		return -1;
	}

	close(fd);

	int repeat_time = 10;
	while (repeat_time--) {
		printf("%s\n", mmaped);
		sleep(1);
	}

	munmap(mmaped, sb.st_size);

	return 0;
}