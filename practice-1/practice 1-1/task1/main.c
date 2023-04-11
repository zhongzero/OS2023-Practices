#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#define MAXTHREAD 10

void *thread1(void* dummy){
	int i;
	printf("This is thread %d!\n", *((int*) dummy));
	for(i = 0; i < 20; ++i){
		printf("H");
		printf("e");
		printf("l");
		printf("l");
		printf("o");
		printf("W");
		printf("o");
		printf("r");
		printf("l");
		printf("d");
		printf("!");
	}
	return NULL;
}

int main(){
	pthread_t pid[MAXTHREAD];
	int i;
	for(i = 0; i < MAXTHREAD; ++i){
		int* thr = (int*) malloc(sizeof(int)); 
		*thr = i;
		// 1 Loc here: create thread and pass thr as parameter
		pthread_create(&pid[i],NULL,thread1,thr);
		// if(pthread_create(&pid[i],NULL,thread1,thr)){
		// 	printf("Wrong in create a thread\n");
		// 	return 0;
		// }
	}
	for(i = 0; i < MAXTHREAD; ++i)
		// 1 Loc here: join thread
		pthread_join(pid[i],NULL);//让主进程等待其它进程结束，否则可能主进程已经结束了其他进程还没结束
	return 0;
}

/*
1.pthread_create
int pthread_create(pthread_t *tidp,const pthread_attr_t *attr,void* (*start_rtn)(void*),void *arg);
创建线程并指定线程入口
args:
	*tidp: 事先创建好的pthread_t类型的参数。成功时tidp指向的内存单元被设置为新创建线程的线程ID
	*attr: 用于定制各种不同的线程属性。通常直接设为NULL
	(*start_rtn)(void*): 新创建线程从此函数开始运行
	*arg: start_rtn函数的参数。无参数时设为NULL即可。有参数时输入参数的地址。当多于一个参数时应当使用结构体传入
return:
	成功返回0，否则返回错误码

2.pthread_join
int pthread_join(pthread_t thread, void **retval);
主线程等待子线程的终止。也就是在子线程调用了pthread_join()方法后面的代码，只有等到子线程结束了才能执行
args:
    thread: 被连接线程的线程号
    **retval: 指向一个 指向被连接线程的返回码的指针 的指针
return:
    成功返回0，否则返回错误码
*/