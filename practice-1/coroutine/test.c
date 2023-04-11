#include<stdio.h>
#include<setjmp.h>
// #include<cstdlib>
// jmp_buf Main,PointPing,PointPong;
// int iter,max_iter=9;
// void Ping(){
// 	if(setjmp(PointPing)==0)longjmp(Main,1);
// 	while(1){
// 		printf("%3d : Ping-",iter);
// 		if(setjmp(PointPing)==0)longjmp(PointPong,1);
// 	}
// }
// void Pong(){
// 	if(setjmp(PointPong)==0)longjmp(Main,1);
// 	while(1){
// 		printf("Pong\n");
// 		iter++;
// 		if(iter>max_iter)exit(0);
// 		if(setjmp(PointPong)==0)longjmp(PointPing,1);
// 	}
// }

int input=1,result=0;
static inline void test(void)
{
	input=1;
    __asm__ __volatile__ ("movl %1,%0" :
             "=r" (result) : "m" (input));
    return ;
}


int FFF(){
	return 233;
}
int main(){
	FFF();
	int ans=0;
	__asm__ __volatile__ ("movl %%eax,%0" :"=m" (ans) ::"eax","memory");
	printf("%d\n",ans);
	test();
	printf("%d %d\n",input,result);
	// int a=0,b=10;
	// __set_bit(a,&b);
	// printf("%d %d\n",a,b);
	// printf("main\n");
	// iter=1;
	// if(setjmp(Main)==0)Ping();
	// if(setjmp(Main)==0)Pong();
	// longjmp(PointPing,1);
	return 0;
}

// int main(void){
// 	int input=3, output=2,temp=2;	
// __asm__ __volatile__("movl $0, %%eax;	\
//                       movl  %%eax, %1;	\
//                       movl  %2, %%eax;	\
//                       movl  %%eax, %0; "
//                       :"=m"(output),"=m"(temp)    /* output */
//                       :"r"(input)     /* input */
//                       :"eax");  /* 描述符 */
// 	printf("%d %d %d\n",input,output,temp);

// return 0;
// }

__attribute__((constructor(102))) void GGG(){
	printf("GGG\n");
}
__attribute__((constructor(102))) void GGG2(){
	printf("GGG2\n");
}

__attribute__((destructor)) void GGGG(){
	printf("end\n");
}
__attribute__((destructor)) void GGGG2(){
	printf("end2\n");
}
