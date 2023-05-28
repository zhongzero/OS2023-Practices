#include <net/if.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <sys/socket.h>
#include <arpa/inet.h>
 
 
using namespace std;
 
int main()
{	
	//得到套接字描述符
	int sockfd;		

    /* code */
	// 创建套接字，用于数据传输
	sockfd=socket(AF_INET, SOCK_DGRAM, 0); //AF_INET:IPV4;SOCK_DGRAM:UDP(数据报协议)

	// ifc为接口信息结构体
	// ifc_buf为存放接口信息结构体的缓冲区,ifc_len为缓冲区长度,ifc_req为接口信息数组
	struct ifconf ifc;
	caddr_t buf;
	int len = 100;
	
	//初始化ifconf结构
	ifc.ifc_len = 1024;
	if ((buf = (caddr_t)malloc(1024)) == NULL)
	{
		cout << "malloc error" << endl;
		exit(-1);
	}
	ifc.ifc_buf = buf; 
	
	//获取所有接口信息
	
    /* code */
	ioctl(sockfd, SIOCGIFCONF, &ifc); // SIOCGIFCONF获取所有接口信息
	
	//遍历每一个ifreq结构
	struct ifreq *ifr;
	struct ifreq ifrcopy;
	ifr = (struct ifreq*)buf;
	for(int i = (ifc.ifc_len/sizeof(struct ifreq)); i>0; i--)
	{
		//接口名
		cout << "interface name: "<< ifr->ifr_name << endl;
		//ipv4地址
		cout << "inet addr: " 
			 << inet_ntoa(((struct sockaddr_in*)&(ifr->ifr_addr))->sin_addr)
			 << endl;// sin_addr为ipv4地址结构体
		
		//获取广播地址
		ifrcopy = *ifr;

		/* code */
		ioctl(sockfd, SIOCGIFBRDADDR, &ifrcopy); // SIOCGIFBRDADDR获取广播地址
		cout << "broad addr: "
			 << inet_ntoa(((struct sockaddr_in*)&(ifrcopy.ifr_addr))->sin_addr)
			 << endl; // sin_addr为ipv4地址结构体
		//获取mtu
		ifrcopy = *ifr;
		
        /* code */
		ioctl(sockfd, SIOCGIFMTU, &ifrcopy); // SIOCGIFMTU获取mtu(最大传输单元)，即一次能发送的最大数据包大小

		cout << "mtu: " << ifrcopy.ifr_mtu << endl;
		cout << endl;
		ifr++;
	}
	
	return 0;
}


/*
广播地址是一个特殊的地址，它被用来向一个网络中的所有主机发送数据包。广播地址的形式是网络地址的最大值
例如，对于10.1.1.0 （255.0.0.0 ）网段，其直播广播地址为10.255.255.255 ，当发出一个目的地址为10.255.255.255 的分组（封包）时，它将被分发给该网段上的所有计算机。
*/