// ? Loc here: header modification to adapt pthread_cond_t
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#define MAXTHREAD 10
// declare cond_variable: you may define MAXTHREAD variables
pthread_cond_t cond[MAXTHREAD];
pthread_mutex_t mutex;
int ok[MAXTHREAD];
// ? Loc in thread1: you can do any modification here, but it should be less than 20 Locs
void *thread1(void* dummy){
	int id=*((int*) dummy);
	pthread_mutex_lock(&mutex);
	if(id!=MAXTHREAD-1 && !ok[id+1])pthread_cond_wait(&cond[id+1],&mutex);
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
	ok[id]=1;
	pthread_mutex_unlock(&mutex);
	pthread_cond_signal(&cond[id]);
	return NULL;
}

int main(){
	pthread_t pid[MAXTHREAD];
	int i;
	// ? Locs: initialize the cond_variables
	for(int i=0;i<MAXTHREAD;i++){
		pthread_cond_init(&cond[i],NULL);
		ok[i]=0;
	}
	pthread_mutex_init(&mutex,NULL);
	for(i = 0; i < MAXTHREAD; ++i){
		int* thr = (int*) malloc(sizeof(int)); 
		*thr = i;
		// 1 Loc here: create thread and pass thr as parameter
		pthread_create(&pid[i],NULL,thread1,thr);
	}
	for(i = 0; i < MAXTHREAD; ++i)
		// 1 Loc here: join thread
		pthread_join(pid[i],NULL);
	return 0;
}

/*
1.pthread_cond_init
int pthread_cond_init(pthread_cond_t *cond, const pthread_condattr_t *attr);
动态创建condition条件变量
args:
	cond: condition对象
	attr: condition属性

注: 静态方式为: pthread_cond_t cond = PTHREAD_COND_INITIALIZER (使用了宏定义)

2.pthread_cond_destroy
int pthread_cond_destroy(pthread_cond_t *cond);
摧毁一个condition条件变量
arg:
	cond: 要摧毁的condition对象

3.pthread_cond_wait
int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
在该条件变量上阻塞等待，同时释放自己占用的mutex( 即pthread_mutex_unlock(&mutex) )
在被唤醒(signal/broadcast)后，解除阻塞并重新申请lock mutex(即pthread_mutex_lock(&mutex))

args:
	cond: condition对象
	mutex: mutex对象

4.pthread_cond_signal
int pthread_cond_signal(pthread_cond_t *cond);
唤醒一个阻塞在该条件变量上的线程(如有多个，通过优先级/随机等方式选择一个唤醒；如一个没有，直接返回)

arg:
	cond: condition对象

5.pthread_cond_broadcast
int pthread_cond_broadcast(pthread_cond_t *cond);
唤醒所有阻塞在该条件变量上的线程

arg:
	cond: condition对象
*/