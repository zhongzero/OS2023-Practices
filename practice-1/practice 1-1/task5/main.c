// ? Loc here: header modification to adapt pthread_setaffinity_np
#define _GNU_SOURCE

#include <assert.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <utmpx.h>
#include <stdio.h>

#include <sched.h>

pthread_barrier_t barrier;
void *thread1(void* dummy){
	pthread_barrier_wait(&barrier);
	assert(sched_getcpu() == 0);
	return NULL;
}

void *thread2(void* dummy){
	pthread_barrier_wait(&barrier);
	assert(sched_getcpu() == 1);
	return NULL;
}
int main(){
	pthread_t pid[2];
	int i;
	// ? LoC: Bind core here
	pthread_barrier_init(&barrier,NULL,3);//主线程和两个子线程，共三个线程
	for(i = 0; i < 2; ++i){
		// 1 Loc code here: create thread and save in pid[2]
		pthread_create(&pid[i],NULL,i==0?thread1:thread2,NULL);
	}
	cpu_set_t cpuset0,cpuset1;
	CPU_ZERO(&cpuset0);
	CPU_SET(0,&cpuset0);
	pthread_setaffinity_np(pid[0],sizeof(cpu_set_t),&cpuset0);
	CPU_ZERO(&cpuset1);
	CPU_SET(1,&cpuset1);
	pthread_setaffinity_np(pid[1],sizeof(cpu_set_t), &cpuset1);
	
	pthread_barrier_wait(&barrier);
	
	for(i = 0; i < 2; ++i){
		// 1 Loc code here: join thread
		pthread_join(pid[i],NULL);
	}
	return 0;
}


/*
1.
sched_getcpu(): 返回CPU当前正使用的核心编号
get_nprocs_conf(): 返回CPU当前可用的核心数量

2.
CPU亲和性就是绑定某一进程（或线程）到特定的CPU（或CPU集合），从而使得该进程（或线程）只能运行在绑定的CPU（或CPU集合）上
CPU亲和性利用了这样一个事实：进程上一次运行后的残余信息会保留在CPU的状态中（也就是指CPU的缓存）。
如果下一次仍然将该进程调度到同一个CPU上，就能避免缓存未命中等对CPU处理性能不利的情况，从而使得进程的运行更加高效
CPU亲和性只是一种倾向性，当绑定的CPU不存在或者存在但是被禁用了，任务会在其他的CPU上执行
CPU亲和性分为两种：软亲和性和硬亲和性
软亲和性主要由操作系统来实现，Linux操作系统的调度器会倾向于保持一个进程不会频繁的在多个CPU之间迁移
Linux系统还提供了硬亲和性功能，即用户可以通过调用系统API实现自定义进程运行在哪个CPU上，从而满足特定进程的特殊性能需求

3.
cpu_set_t数据结构: 是一个位图，每一位用来表示服务器上的一个CPU逻辑核，一般为1024位
sizeof(cpu_set_t): 返回逻辑核大小，一般为128字节
CPU_ZERO(&cpuset): 将cpu_set_t类的cpuset全部位设成0,表示一个核也没选中
CPU_SET(i,&cpuset1): 将cpu_set_t类的cpuset的第i位设成1,表示选中第i个核

4.
int pthread_setaffinity_np(pthread_t thread, size_t cpusetsize, const cpu_set_t *cpuset);
设置线程亲和性，将线程绑定到指定CPU核
args:
	thread: 要查看的pthread
	cpusetsize: 集合内存大小，一般默认设置为sizeof(cpu_set_t)
	cpuset: CPU核的集合

5.
int pthread_getaffinity_np(pthread_t thread, size_t cpusetsize, cpu_set_t *cpuset);
获取指定线程的CPU集合，存储到cpuset中
args:
	thread: 要查看的pthread
	cpusetsize: 集合内存大小，一般默认设置为sizeof(cpu_set_t)
	cpuset: CPU核的集合

*/