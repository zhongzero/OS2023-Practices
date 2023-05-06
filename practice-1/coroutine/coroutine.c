/* YOUR CODE HERE */

/*
注：执行前输入命令script，不然会segmentation fault！！！(还不清楚)
*/
#include "coroutine.h"
#include<setjmp.h>
#include<stdint.h>
#include<stdbool.h>
#include<stdlib.h>
#include<stdio.h>
#include <assert.h>
#include <pthread.h>
#define STACK_SIZE (1<<13)
#define CO_SIZE 500
#define PTHREAD_SIZE 105

pthread_mutex_t mutex;

enum co_status {
	CO_NEW, //新创建，还未执行过
	CO_RUNNING, //已经执行过
	CO_DEAD,    //已经结束，但还未释放资源
};


struct co {
	void (*func)(void); //co_start指定的入口地址和参数

	int parent_id;

	enum co_status	status;  //协程的状态
	// struct co_list	*waiterList;  //是否有其他协程在等待当前协程
	jmp_buf			context; //寄存器现场(setjmp.h)
	unsigned char	stack[STACK_SIZE]; //协程的堆栈

};
static struct AllCoroutineInOnePthread{
	bool pthread_use;
	pthread_t pid;
	struct co **co_arr;
	bool use[CO_SIZE];
	int current_id;
	int co_retans[CO_SIZE];
	int yield_given_id;
}pthread[PTHREAD_SIZE];
static int tot_pthread_size=0;

static void create_pid(){
	pthread_mutex_lock(&mutex);//tot_pthread_size多线程共用也要加锁保证线程安全,malloc需要加锁保证线程安全(有些版本malloc内部没上锁，虽然一般是加上的)
	// printf("create: %ld\n",pthread_self());
	int pid=tot_pthread_size;
	pthread[pid].pthread_use=1,pthread[pid].pid=pthread_self();
	tot_pthread_size++;
	pthread_mutex_unlock(&mutex);
	pthread[pid].co_arr=malloc(8*CO_SIZE);
	pthread[pid].current_id=CO_SIZE-1; //main所在的coroutine
	pthread[pid].co_arr[pthread[pid].current_id]=malloc(sizeof(struct co));

	for(int i=0;i<CO_SIZE;i++)pthread[pid].use[i]=0;
	pthread[pid].use[pthread[pid].current_id]=1;
	pthread[pid].co_arr[pthread[pid].current_id]->func=NULL; //不重要，main函数会自动调用
	pthread[pid].co_arr[pthread[pid].current_id]->status=CO_RUNNING;
	pthread[pid].co_arr[pthread[pid].current_id]->parent_id=-1;
}

__attribute__((constructor)) static void co_initial(){//这里有问题，因为多线程下其他线程初始化时进不来这里，待修改！！
	// printf("%ld\n",pthread_self());
	for(int i=0;i<PTHREAD_SIZE;i++)pthread[i].pthread_use=0,pthread[i].yield_given_id=-1;
	create_pid();
}

__attribute__((destructor)) static void co_finish(){
	for(int i=0;i<tot_pthread_size;i++){
		for(int j=0;j<CO_SIZE;j++){
			if(pthread[i].use[j])free(pthread[i].co_arr[j]);
		}
		free(pthread[i].co_arr);
	}
}

int g_pid,g_i,g_pid_self;

static int getPid(){
	pthread_t pid=pthread_self();
	// printf("ask: %ld\n",pid);
	for(int i=0;i<tot_pthread_size;i++){
		if(pthread[i].pid==pid)return i;
	}
	return -1;
}

static int Find_spare_cid(int pid){
	for(int i=0;i<CO_SIZE;i++){
		if(pthread[pid].use[i]==0)return i;
	}
	return -1;
}
static int Find_other_co(int pid){//若是多线程，可能需要修改只能yield给同一线程的协程
	for(int i=0;i<CO_SIZE;i++){
	// for(int i=CO_SIZE-1;i>=0;i--){
		if(i==pthread[pid].current_id)continue;
		if(pthread[pid].use[i]==1 && (pthread[pid].co_arr[i]->status==CO_NEW||pthread[pid].co_arr[i]->status==CO_RUNNING) )return i;
	}
	return -1;
}
static bool IsAncestor(int pid,int id1,int id2){//if id1 is id2's ancestor, return 1(包括自己)
	while(id2!=-1){
		if(id2==id1)return 1;
		id2=pthread[pid].co_arr[id2]->parent_id;
	}
	return 0;
}
int co_start(int (*routine)(void)){	//返回cid
	/*
	要求一执行co_start就直接执行这个新协程
	*/
	int pid=getPid();
	if(pid==-1){//如果不存在这个线程就创建
		create_pid();
		pid=getPid();
	}
	// printf("!!! pid=%d\n",pid);
	int id=Find_spare_cid(pid);
	if(id==-1){
		printf("co number is full!\n");
		assert(0);
	}
	pthread[pid].use[id]=1;
	pthread_mutex_lock(&mutex);//malloc需要加锁保证线程安全(有些版本malloc内部没上锁，虽然一般是加上的)
	pthread[pid].co_arr[id]=malloc(sizeof(struct co));
	pthread_mutex_unlock(&mutex);
	pthread[pid].co_arr[id]->func=(void*)routine;
	pthread[pid].co_arr[id]->status=CO_NEW;
	pthread[pid].co_arr[id]->parent_id=pthread[pid].current_id;
	pthread[pid].yield_given_id=id;//指定yield给的id,在co_yield中改回-1
	co_yield();
	// printf("!!!co_start end\n");
	return id;
}
int co_getid(){
	int pid=getPid();
	return pthread[pid].current_id;
}
int co_getret(int cid){
	int pid=getPid();
	assert(pthread[pid].use[cid]==1);
	while(pthread[pid].co_arr[cid]->status!=CO_DEAD){
		pthread[pid].yield_given_id=cid;
		co_yield();
	}
	return pthread[pid].co_retans[cid];
}
int co_yield(){
	// unsigned long sp,bp;
	// asm volatile(
    //       "movq %%rsp, %0; movq %%rbp, %1;"
    //     : "=m"(sp),"=m"(bp)
    //     :
	// 	: "memory"
    // );
	// printf("in sp=%lx,bp=%lx\n",sp,bp);
	/*
	协程只有两种方式停止执行，一是全部执行完毕，二是yield让给其他协程先执行，之后什么时候再重新执行自己
	
	本来一般的代码都必须顺序执行，调用完也必须返回，
	但通过setjmp，我们可以实现从某处突然跳转到另外一处，且保持原来set时候的寄存器状态，而这也正是yield能够实现的重要原因(方式)

	当我们需要yield的时候，有两种情况：
	--- 一种是yield给一个已经运行到一半的协程，它的停止一定是在自身执行的某一个yield处
	这种情况下，我们可以通过在每次每个协程yield时都setjmp设置跳转点(记录当前pc)并记录此时的寄存器状态和栈顶位置，再在需要时longjmp跳转到对应协程yield设置的setjmp处(即修改回原来的pc)
	我们只需再确保每个协程的栈是独立的，不会互相影响的，就可以保证只改回栈顶位置也就等价于切换回原来的栈
	由此我们实现了pc,寄存器,栈的切换
	--- 另一种是yield给一个从未执行过的协程
	在这一块我们主要需要考虑的是如何给协程分配一个独一无二的栈空间
	为了实现这个目标，我们可以使用malloc动态分配得到的堆空间来当作协程的栈空间(所以每个协程的栈空间大小其实是固定分配的)
	为了把sp切换到我们要的位置上，我们必须嵌入汇编代码直接修改sp(C语言直接来肯定修改不了sp)
	注意的点是，栈是从上到下一次分配的，所以栈的起始地点需要设置成堆空间的最高处
	另一点是，考虑协程停止执行，除了所有线程一开始所在的协程是结束之后整个线程全部结束，其他协程结束后其实都会进入yield中的代码块(因为除了一开始的协程以外，只有yield之后才会开始执行那些其他协程)
	执行完毕之后，注意此时的栈大概率已经被修改的面目全非了，所以不能调用任何原来在栈上的数据，也无法把原来的协程切回来，所以只能继续yield给任意一个未完成的协程
	但注意，由于这里嵌入了汇编，防止上下文中寄存器存储数据但被修改掉了，最好(或者必须?)在
	__asm__　__volatile__("Instruction List" : Output operand: Input operand: 破坏描述部分)
	的破坏描述部分加入"memory"描述符(这是嵌入汇编的格式)
	("memory"描述符 的作用 是 告诉编译器 不要对这里汇编代码前后处的代码进行乱序优化，且不要将变量缓存到寄存器)
	*/
	int pid=getPid();
	int jmpval=setjmp(pthread[pid].co_arr[pthread[pid].current_id]->context);//设置jmp点，并且保留下此刻的寄存器状态
	//若jmpval==0，表示是顺序执行下来的，即要自己yield给别人执行
	//若jmpval==1，表示是被longjmp过来的，即退出yield函数即可
	if(!jmpval){
		// printf("set: %d\n",current_id);
		int target_id=pthread[pid].yield_given_id==-1?Find_other_co(pid):pthread[pid].yield_given_id;
		if(pthread[pid].yield_given_id!=-1)pthread[pid].yield_given_id=-1;//把yield指定的id改回-1
		// printf("yield %d ---> %d\n",current_id,target_id);
		// sleep(1);
		if(target_id==-1)return 0;//没有其他协程存在，就不yield了
		if(pthread[pid].co_arr[target_id]->status==CO_NEW){//若是新进程是一个从未执行过的协程
			// printf("co_arr[%d] -> co_arr[%d]\n",current_id,target_id);
			pthread[pid].current_id=target_id;
			pthread[pid].co_arr[pthread[pid].current_id]->status=CO_RUNNING;
			int retans=0;
			__asm__ __volatile__(
		          "leaq -0x50(%1), %%rsp;leaq -0x0(%1), %%rbp; call *%2; movl %%eax,%0;"
		        : "=m"(retans)
		        : "r"((uintptr_t)pthread[pid].co_arr[target_id]->stack+STACK_SIZE), "r"((uintptr_t)pthread[pid].co_arr[target_id]->func)
				: "eax","memory"
		    );
			/*
			首先更改%sp到堆中的地址上，%bp也要改过去(call之后%bp会自己调整)
			(注意此时要给%bp和%sp中间留足够的空间，因为接下来调用的局部变量是根据%bp进行偏移的，编译器转成汇编认为%bp和%sp都没有变化，偏移也是按原来的偏移，所以这里%bp和%sp之间的空间要大于原来之间的空间接下来才能调用局部变量)
			接着call新协程对应的函数入口，最后把返回值(%eax)记下来
			(%bp是栈底，即当前函数的基础地址)(必须把%bp也修改掉，不然可能会影响原来位置上的数据导致出现问题)
			*/
			// unsigned long sp,bp;
			// asm volatile(
		    //       "movq %%rsp, %0; movq %%rbp, %1;"
		    //     : "=m"(sp),"=m"(bp)
		    //     :
			// 	: "memory"
		    // );
			// printf("sp=%lx,bp=%lx\n",sp,bp);
			int pid=getPid();
			// printf("@@@ pid=%d,retans=%d\n",pid,retans);
			pthread[pid].co_retans[pthread[pid].current_id]=retans;
			/*
			执行到这里表示上述调用的协程已经执行完毕并把return的答案记录下来并已经把协程的sp换回来了
			注意：此时的栈可能全部被毁了，因为可能之前什么时候重新jmp到这个协程，再执行一段事件后重新yield，而这段时间栈被全部改造过了，
			而此时上述call返回后的sp还是原来的sp，它所处的栈可能全部改的面目全非了
			即这里返回后，不能在调用之前栈上的任何信息了，包括target_id
			*/
			// printf("co_arr[%d] is dead\n",current_id);
			pthread[pid].co_arr[pthread[pid].current_id]->status=CO_DEAD;
			//由于栈已经不再是原来的栈了，所以这里只能继续yield而没有办法把current_id改回去了

			co_yield();
		}
		else{//若是新进程是一个曾经执行过然后yield出来的协程
			// printf("co_arr[%d] -> co_arr[%d]\n",current_id,target_id);
			pthread[pid].current_id=target_id;
			longjmp(pthread[pid].co_arr[target_id]->context,1);
		}
	}
	else {
		// printf("jump: %d\n",current_id);
	}
	// printf("!!!co_yield end\n");
	// asm volatile(
    //       "movq %%rsp, %0; movq %%rbp, %1;"
    //     : "=m"(sp),"=m"(bp)
    //     :
	// 	: "memory"
    // );
	// printf("in sp=%lx,bp=%lx\n",sp,bp);
	return 0;
}
int co_waitall(){
	int pid=getPid();
	while(1){
		bool flag=0;
		for(int i=0;i<CO_SIZE;i++){
			if(i!=pthread[pid].current_id&&pthread[pid].use[i]&&pthread[pid].co_arr[i]->status!=CO_DEAD){
				flag=1;
				break;
			}
		}
		if(!flag)break;
		co_yield();
	}
	return 0;
}
int co_wait(int cid){
	int pid=getPid();
	assert(pthread[pid].use[cid]==1);
	//这里必须写while直到cid结束，因为yield出去可能由于cid再次yield返回该协程，但此时cid并没有结束
	while(pthread[pid].co_arr[cid]->status!=CO_DEAD){
		pthread[pid].yield_given_id=cid;
		co_yield();
	}
	return 0;
}
int co_status(int cid){
	int pid=getPid();
	assert(pthread[pid].use[cid]==1);
	if(IsAncestor(pid,pthread[pid].current_id,cid)){
		if(pthread[pid].co_arr[cid]->status==CO_DEAD)return FINISHED;
		else {
			// printf("%d %d\n",cid,pthread[pid].co_arr[cid]->status);
			return RUNNING;
		}
	}
	else return UNAUTHORIZED;
}