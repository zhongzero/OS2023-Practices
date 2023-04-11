#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

// 1 Loc here: declare mutex
pthread_mutex_t mutex;
void *thread1(void* dummy){
	int i;
	// 1 Loc: mutex operation
	pthread_mutex_lock(&mutex);
	printf("This is thread 1!\n");
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
	// 1 Loc: mutex operation
	pthread_mutex_unlock(&mutex);
	return NULL;
}

void *thread2(void* dummy){
	int i;
	// 1 Loc: mutex operation
	pthread_mutex_lock(&mutex);
	printf("This is thread 2!\n");
	for(i = 0; i < 20; ++i){
		printf("A");
		printf("p");
		printf("p");
		printf("l");
		printf("e");
		printf("?");
	}
	// 1 Loc: mutex operation
	pthread_mutex_unlock(&mutex);
	return NULL;
}
int main(){
	pthread_t pid[2];
	int i;
	// 3 Locs here: create 2 thread using thread1 and thread2 as function.
	// mutex initialization
	pthread_mutex_init(&mutex,NULL);
	pthread_create(&pid[0],NULL,thread1,NULL);
	pthread_create(&pid[1],NULL,thread2,NULL);
	for(i = 0; i < 2; ++i){
		// 1 Loc code here: join thread
		pthread_join(pid[i],NULL);
	}
	return 0;
}

/*
1.pthread_mutex_init
int pthread_mutex_init(pthread_mutex_t *mutex,const pthread_mutexattr_t *attr);
以动态方式创建mutex(互斥锁)
args:
	*mutex: mutex对象
	*attr: 互斥锁属性。设为NULL表示默认互斥锁

注: 静态方式为: pthread_mutex_t mutex=PTHREAD_MUTEX_INITIALIZER (使用了宏定义)

2.pthread_mutex_destroy
int pthread_mutex_destroy(pthread_mutex_t *mutex);
销毁一个mutex互斥锁
arg:
	*mutex: 要销毁的mutex对象

3.pthread_mutex_lock
int pthread_mutex_lock(pthread_mutex_t *mutex);
给mutex上锁。如果mutex正在被其他进程占用(被上锁了)，则进入到这个锁的排队队列中，并会进入阻塞状态，直到拿到锁之后才会返回。
(阻塞调用)
arg:
	*mutex: 要lock的mutex对象

4.pthread_mutex_trylock
int pthread_mutex_trylock(pthread_mutex_t *mutex);
尝试给mutex上锁(上锁成功返回0)。如果mutex正在被其他进程占用(被上锁了)，则直接返回EBUSY，表示该mutex正在被占用
(非阻塞调用)
arg:
	*mutex: 要尝试lock的mutex对象

5.pthread_mutex_unlock
int pthread_mutex_unlock(pthread_mutex_t *mutex);
arg:
	*mutex: 要unlock的mutex对象
给mutex解锁

*/