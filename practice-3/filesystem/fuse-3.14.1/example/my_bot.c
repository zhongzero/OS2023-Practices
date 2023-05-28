/*
  FUSE: Filesystem in Userspace
  Copyright (C) 2001-2007  Miklos Szeredi <miklos@szeredi.hu>

  This program can be distributed under the terms of the GNU GPLv2.
  See the file COPYING.
*/

/** @file
 *
 * minimal example filesystem using high-level API
 *
 * Compile with:
 *
 *	 gcc -Wall my_bot.c `pkg-config fuse3 --cflags --libs` -o my_bot
 *
 * ## Source code ##
 * \include hello.c
 */


#define FUSE_USE_VERSION 31

#include <fuse.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

#define BLOCKSIZE 512

FILE *fp;

struct File {
	struct File *father,*next,*firstchild;	// next和firstchild都是对folder才有意义
	bool isfolder;							// file or folder
	char *path;							 	// path
	char *data;					 			// file content，对file才有意义
	struct stat vstat;					  	// stat
}*rootfile;

static bool IsPrefix(const char *a,const char *b){ // 判断a是否是b的前缀文件夹(a==b也算是前缀)
	int n=strlen(a),m=strlen(b);
	if(n>m)return 0;
	for(int i=0;i<n;i++)if(a[i]!=b[i])return 0;
	if(n==m || b[n]=='/')return 1;
	return 0;
}

static struct File *FindFile(const char *path){ // 根据path找到对应的文件或文件夹
	fprintf(fp,"FindFile, path: %s\n",path);
	struct File *now=rootfile;
	// fprintf(fp,"now->path: %s\n",now->path);
	int n=strlen(path);
	for(int i=1;i<n;i++){ // 从第二个字符开始,第一个字符是'/'
		if(i==n-1||path[i]=='/'){
			if(now->isfolder){
				now=now->firstchild;
				while(now!=NULL&& !IsPrefix(now->path,path))now=now->next;
				if(now==NULL){
					fprintf(fp,"not find file\n");
					return NULL;
				}
			}
			else {
				fprintf(fp,"not find file\n");
				return NULL;
			}
		}
	}
	fprintf(fp,"find file OK\n");
	return now;
}

static struct File *FindpreFolder(const char *path){ // 找到path的前缀文件夹
	fprintf(fp,"FindpreFolder, path: %s\n",path);
	int n=strlen(path);
	int las=0;
	for(int i=0;i<n-1;i++)if(path[i]=='/')las=i; // 找到最后一个'/'的位置(不算最后一个字符)
	char *newpath=(char*)malloc(sizeof(char)*(las+2));
	for(int i=0;i<=las;i++)newpath[i]=path[i];
	newpath[las+1]='\0';
	struct File *file=FindFile(newpath);
	free(newpath);
	return file;
}

static const char *GetLasName(const char *path){// 获取path中最后的文件名
	fprintf(fp,"GetLasName, path: %s\n",path);
	int n=strlen(path);
	int las=0;
	for(int i=0;i<n-1;i++)if(path[i]=='/')las=i; // 找到最后一个'/'的位置(不算最后一个字符)
	char *newpath=(char*)malloc(sizeof(char)*(n-las));
	for(int i=las+1;i<n;i++)newpath[i-las-1]=path[i];
	if(newpath[n-las-2]=='/')newpath[n-las-2]='\0'; // 如果最后一个字符是'/'，则去掉
	else newpath[n-las-1]='\0';
	return newpath;
}

static bool ModeCheck(const char *path,int read_or_write_or_exec){ // 检查当前用户对path对应的文件/文件夹是否有read/write/execute权限
	//read_or_write_or_exec: 0-read, 1-write, 2-execute
	fprintf(fp,"ModeCheck, path: %s\n",path);
	struct File *file=FindFile(path);
	assert(file!=NULL); // 文件/文件夹必须存在
	fprintf(fp,"file mode: %o\n",file->vstat.st_mode);
	if(getuid()==file->vstat.st_uid){ // 如果是文件/文件夹的所有者
		if(read_or_write_or_exec==0)return file->vstat.st_mode & S_IRUSR;
		else if(read_or_write_or_exec==1)return file->vstat.st_mode & S_IWUSR;
		else return file->vstat.st_mode & S_IXUSR;
	}
	else if(getgid()==file->vstat.st_gid){ // 如果是文件/文件夹的所属组
		if(read_or_write_or_exec==0)return file->vstat.st_mode & S_IRGRP;
		else if(read_or_write_or_exec==1)return file->vstat.st_mode & S_IWGRP;
		else return file->vstat.st_mode & S_IXGRP;
	}
	else{ // 如果是其他用户
		if(read_or_write_or_exec==0)return file->vstat.st_mode & S_IROTH;
		else if(read_or_write_or_exec==1)return file->vstat.st_mode & S_IWOTH;
		else return file->vstat.st_mode & S_IXOTH;
	}
	return 0;
}

static int Create_File(const char *path, mode_t mode,bool isfolder){ // 创建文件/文件夹
	fprintf(fp,"Create_File, path: %s\n",path);
	struct File *folder=FindpreFolder(path);
	if(folder==NULL)return -ENOENT; // 父文件夹不存在
	if(!folder->isfolder)return -ENOTDIR; // 父文件夹不是文件夹
	if(!ModeCheck(folder->path,1))return -EACCES; // 父文件夹没有写入权限不能创建文件/文件夹(注意不是文件/文件夹本身的权限，而是检查它的父文件夹的权限)
	struct File *newfile=(struct File*)malloc(sizeof(struct File));
	memset(newfile,0,sizeof(struct File));
	
	newfile->isfolder=isfolder;
	
	newfile->path=(char*)malloc(sizeof(char)*(strlen(path)+1));
	strcpy(newfile->path,path);

	newfile->data=NULL;
	
	newfile->vstat.st_mode = isfolder?(S_IFDIR | mode) : (S_IFREG | mode); // 文件/文件夹的权限
	newfile->vstat.st_nlink = isfolder?2:1;	// 文件夹的硬链接数,为 子文件夹数+2(+2是因为.和..),一开始为2;文件的硬链接数为1
	newfile->vstat.st_size = 0;		// 文件/文件夹的大小,设为0即可
	newfile->vstat.st_blocks=0;	// 令文件夹占用的block数为0
	newfile->vstat.st_blksize = BLOCKSIZE; // 文件/文件夹的块大小
	newfile->vstat.st_uid = getuid(); // 文件所有者的用户ID
	newfile->vstat.st_gid = getgid(); // 文件所有者的组ID
	// printf("uid: %d, gid: %d\n",rootfile->vstat.st_uid,rootfile->vstat.st_gid);
	newfile->vstat.st_atime = time(NULL); // 上次访问时间
	newfile->vstat.st_mtime = time(NULL); // 上次修改时间
	newfile->vstat.st_ctime = time(NULL); // 上次文件状态修改时间


	if(isfolder)folder->vstat.st_nlink++;
	newfile->father=folder;
	newfile->next=folder->firstchild;
	folder->firstchild=newfile;
	return 0;
}

static int Remove_File(const char *path,bool isfolder){ // 删除文件/文件夹
	fprintf(fp,"Remove_File, path: %s\n",path);
	struct File *file=FindFile(path);
	if(file==NULL)return -ENOENT; // 文件不存在
	if(isfolder&&file->firstchild!=NULL)return -ENOTEMPTY; // 文件夹非空不能删除
	struct File *folder=file->father;
	if(folder==NULL)return -EACCES; // 根目录不能删除
	if(!ModeCheck(folder->path,1))return -EACCES; // 父文件夹没有写入权限不能创建文件/文件夹(注意不是文件/文件夹本身的权限，而是检查它的父文件夹的权限)
	if(folder->firstchild==file)folder->firstchild=file->next;
	else {
		struct File *now=folder->firstchild;
		while(now->next!=file)now=now->next;
		now->next=file->next;
	}
	folder->vstat.st_nlink--;
	free(file->path);
	free(file);
	return 0;
}

static int WriteFile(const char *path,const char *buf, size_t size, off_t offset,struct fuse_file_info *fi){ // 文件写入
	fprintf(fp,"WriteFile, path: %s\n",path);
	struct File *file=FindFile(path);
	if(file==NULL)return -ENOENT; // 文件不存在
	if(file->isfolder)return -ENOENT; // 文件夹不能写入
	if(!ModeCheck(path,1))return -EACCES; // 检查是否有写入权限
	size_t reqsize=offset+size;
	blkcnt_t reqblock=(reqsize+BLOCKSIZE-1)/BLOCKSIZE;
	if( reqblock > file->vstat.st_blocks ){ // 如果写入的数据超过了文件大小,则需要重新分配空间
		file->data=(char*)realloc(file->data,reqblock*BLOCKSIZE);
		file->vstat.st_blocks=reqblock;
	}
	if(reqsize>file->vstat.st_size)file->vstat.st_size=reqsize;
	memcpy(file->data+offset,buf,size); // 将buf中的数据写入文件
	fprintf(fp,"write data: %s\n",file->data+offset);
	file->vstat.st_atime = time(NULL);	// 修改上次访问时间
	file->vstat.st_mtime = time(NULL);	// 修改上次修改时间
	return size;
}
static bool FindCounterPath(const char *path,char *counterpath){ // 找到path对应的counterpart的路径(交换path中第2个和第3个目录名称的位置)
	// 如 /chatbot/bot1/bot2/xxx/xxx.txt <-> /chatbot/bot2/bot1/xxx/xxx.txt
	fprintf(fp,"FindCounterPath, path: %s\n",path);
	strcpy(counterpath,path);
	int n=strlen(path);
	int begin2=-1,begin3=-1,begin4=-1;
	for(int i=1;i<n;i++){ // 找到第2个'/'的位置
		if(path[i]=='/'){
			if(begin2==-1)begin2=i;
			else if(begin3==-1)begin3=i;
			else {begin4=i;break;}
		}
	}
	if(begin2==-1||begin3==-1||begin4==-1)return 0;
	int now=begin2+1;
	for(int i=begin3+1;i<begin4;i++)counterpath[now++]=path[i];
	counterpath[now++]='/';
	for(int i=begin2+1;i<begin3;i++)counterpath[now++]=path[i];
	return 1;
}


// 进行初始化
static void *my_init(struct fuse_conn_info *conn,
			struct fuse_config *cfg)
{
	fprintf(fp,"!!! my_init\n");
	cfg->kernel_cache = 1;
	rootfile=(struct File*)malloc(sizeof(struct File));
	memset(rootfile,0,sizeof(struct File));
	rootfile->isfolder=1;
	rootfile->path=(char*)malloc(sizeof(char)*2);
	rootfile->path[0]='/';
	rootfile->path[1]='\0';
	rootfile->data=NULL;
	rootfile->vstat.st_mode=S_IFDIR | 0755; // 文件夹的默认权限
	rootfile->vstat.st_nlink=2;
	rootfile->vstat.st_size=0;		// 令文件夹的大小为0
	rootfile->vstat.st_blocks=0;	// 令文件夹占用的block数为0
	rootfile->vstat.st_blksize = BLOCKSIZE; // 文件/文件夹的块大小
	rootfile->vstat.st_uid=getuid();
	rootfile->vstat.st_gid=getgid();
	// printf("uid: %d, gid: %d\n",rootfile->vstat.st_uid,rootfile->vstat.st_gid);
	rootfile->vstat.st_atime=time(NULL); // 上次访问时间
	rootfile->vstat.st_mtime=time(NULL); // 上次修改时间
	rootfile->vstat.st_ctime=time(NULL); // 上次文件状态修改时间
	rootfile->father=NULL;
	rootfile->next=NULL;
	rootfile->firstchild=NULL;

	Create_File("/README.txt",S_IFREG | 0644,0);
	struct File *file=FindFile("/README.txt");
	file->vstat.st_blocks=2;
	file->data=(char*)malloc(file->vstat.st_blocks*BLOCKSIZE);
	strcpy(file->data,"\
This is a virtual file system created by zhongero.\n\
And now I will tell you how to use the chatbot.\n\
You will find a folder named chatbot in the root directory.\n\
Enter it and create two folders.(let they be named bot1 and bot2 for example)\n\
Then we create one folder bot2 in /bot1 and one folder bot1 in /bot2.\n\
By writing some files in /bot1/bot2 or /bot2/bot1, we can find the same files in the other folder.\n\
(Attention: You need to assure that there is a same file in the counter folder before you want to write into a file.)\n\
By this way, we achieve the function of chatting with each other.\n\
");
	file->vstat.st_size=strlen(file->data);

	Create_File("/chatbot",S_IFDIR | 0755,1);
	Create_File("/chatbot/bot1",S_IFDIR | 0755,1);
	Create_File("/chatbot/bot2",S_IFDIR | 0755,1);
	Create_File("/chatbot/bot1/bot2",S_IFDIR | 0755,1);
	Create_File("/chatbot/bot2/bot1",S_IFDIR | 0755,1);
	Create_File("/chatbot/bot1/bot2/a.out", S_IFREG | 0644,0);
	Create_File("/chatbot/bot2/bot1/a.out", S_IFREG | 0644,0);
	return NULL;
}

// 通过文件名filename获取文件信息，并保存在buf所指的结构体stat中
static int my_getattr(const char *path, struct stat *stbuf,
			 struct fuse_file_info *fi)
{
	fprintf(fp,"!!! my_getattr, path: %s\n",path);
	struct File *file=FindFile(path);
	if(file==NULL)return -ENOENT;
	*stbuf=file->vstat;
	fprintf(fp,"my_getattr, stbuf->st_mode: %o\n",stbuf->st_mode);
	return 0;
}

// 创建文件夹
static int my_mkdir(const char *path, mode_t mode){
	fprintf(fp,"!!! my_mkdir, path: %s\n",path);
	return Create_File(path,mode,1);
}

// 删除文件夹(注意:只能删除空文件夹)
static int my_rmdir(const char *path){
	fprintf(fp,"!!! my_rmdir, path: %s\n",path);
	return Remove_File(path,1);
}

// 该函数用于读取目录中的内容，填充到buf中
static int my_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
			 off_t offset, struct fuse_file_info *fi,
			 enum fuse_readdir_flags flags)
{
	fprintf(fp,"!!! my_readdir, path: %s\n",path);
	filler(buf, ".", NULL, 0, 0); // 当前目录
	if (strcmp(path, "/") != 0)filler(buf, "..", NULL, 0, 0); // 父目录
	struct File *file=FindFile(path);
	if(file==NULL)return -ENOENT; // 如果文件不存在，返回错误
	if(!file->isfolder)return -ENOENT; // 如果不是文件夹，返回错误
	if(!ModeCheck(path,0))return -EACCES; // 检查是否有读取权限
	// 开始遍历所有子文件
	file=file->firstchild; 
	while(file!=NULL){
		// fprintf(fp,"my_readdir, all sub-file/folder: %s\n",file->path);
		filler(buf, GetLasName(file->path), &(file->vstat), 0, 0);
		file=file->next;
	}
	return 0;
}

// 创建文件节点
static int my_mknod(const char *path, mode_t mode, dev_t rdev){
	fprintf(fp,"!!! my_mknod, path: %s\n",path);
	return Create_File(path,mode,0);
}

// 修改文件的访问时间和修改时间
static int my_utimens(const char *path, const struct timespec tv[2],
			 struct fuse_file_info *fi)
{
	fprintf(fp,"!!! my_utimens, path: %s\n",path);
	struct File *file=FindFile(path);
	file->vstat.st_atime = time(NULL);	// 上次访问时间
	file->vstat.st_mtime = time(NULL);	// 上次修改时间
	return 0;
}

// 文件写入
static int my_write(const char *path,const char *buf, size_t size, off_t offset,struct fuse_file_info *fi)
{
	fprintf(fp,"!!! my_write, path: %s\n",path);
	printf("!!! my_write, path: %s\n",path);
	if(strncmp(path,"/chatbot",8)==0){ //判断path的前缀是否是"/chatbot",如果是，则实现chatbot功能
		//具体为，交换path中第2个和第3个目录名称的位置
		char * path2=(char*)malloc(strlen(path)+1);
		FindCounterPath(path,path2);
		fprintf(fp,"!!! path and counter path: %s, %s\n",path,path2);
		int res=WriteFile(path,buf,size,offset,fi);
		if(res<0)return res;
		res=WriteFile(path2,buf,size,offset,fi);
		free(path2);
		return res;
	}
	else return WriteFile(path,buf,size,offset,fi);
}

// 文件读取
static int my_read(const char *path, char *buf, size_t size, off_t offset,
			  struct fuse_file_info *fi)
{
	fprintf(fp,"!!! my_read, path: %s\n",path);
	struct File *file=FindFile(path);
	fprintf(fp,"mode= %o\n",file->vstat.st_mode);
	if(file==NULL)return -ENOENT;
	if(file->isfolder)return -ENOENT;
	if(!ModeCheck(path,0))return -EACCES; // 检查是否有读取权限
	if(offset+size>file->vstat.st_size)size=file->vstat.st_size-offset; // 如果读取的数据超过了文件大小,则只读取文件大小的数据
	memcpy(buf,file->data+offset,size); // 将文件中的数据读入buf
	fprintf(fp,"read data: %s\n",buf);
	file->vstat.st_atime = time(NULL);	// 修改上次访问时间
	return size;
}

// 删除文件
static int my_unlink(const char *path){
	fprintf(fp,"!!! my_unlink, path: %s\n",path);
	return Remove_File(path,0);
}

static int my_chmod(const char *path, mode_t mode, struct fuse_file_info *fi){
	fprintf(fp,"!!! my_chmod, path: %s\n",path);
	struct File *file=FindFile(path);
	if(file==NULL)return -ENOENT;
	file->vstat.st_mode=mode;
	return 0;
}

// 检查cd访问权限
static int my_access(const char *path, int mask){
	fprintf(fp,"!!! my_access, path: %s\n",path);
	if(!ModeCheck(path,2))return -EACCES; // 没有执行权限
	return 0;
}

// 检查文件是否有权限打开,可以是write操作(cat)，也可以是read操作(echo "xxx" > xxx)
// 注意：每次打开文件都会调用这个函数，所以在这里检查权限，而不能选择只在my_read和my_write中检查权限(执行cat的时候不一定每次都会调用my_read)
static int my_open(const char *path, struct fuse_file_info *fi){
	fprintf(fp,"!!! my_open, path: %s\n",path);
	printf("flags=%o\n",fi->flags);
	//如果是cat操作，需要检查是否有读取权限
	if(fi->flags==0100000){
		if(!ModeCheck(path,0))return -EACCES; // 没有读取权限
	}
	//如果是echo "xxx" > xxx操作，需要检查是否有写入权限
	if(fi->flags==0101001){
		if(!ModeCheck(path,1))return -EACCES; // 没有写入权限
	}
	return 0;
}

static const struct fuse_operations my_ops = {
	.init		= my_init,		// 初始化
	.getattr	= my_getattr,	// 查看file's attribution，用于很多命令
	.mkdir	  	= my_mkdir,		// mkdir
	.rmdir	  	= my_rmdir,		// rmdir
	.readdir	= my_readdir,	// ls
	.mknod		= my_mknod,		// touch
	.utimens	= my_utimens,	// touch
	.read		= my_read,		// cat
	.write		= my_write,		// echo "xxx" > xxx
	.unlink		= my_unlink,	// rm
	.chmod		= my_chmod,		// chmod
	.access		= my_access,	// cd
	.open		= my_open,		// cat, echo "xxx" > xxx
};


int main(int argc, char* argv[]) {
	fp=fopen("1.out","w");
	// fp=stdout;
	int ret=fuse_main(argc, argv, &my_ops, NULL);
	fclose(fp);
    return ret;
}

// struct stat {
//     dev_t         st_dev;       //文件的设备编号
//     ino_t         st_ino;       //节点
//     mode_t        st_mode;      //文件的类型和存取的权限
//     nlink_t       st_nlink;     //连到该文件的硬连接数目，刚建立的文件值为1
//     uid_t         st_uid;       //用户ID
//     gid_t         st_gid;       //组ID
//     dev_t         st_rdev;      //(设备类型)若此文件为设备文件，则为其设备编号
//     off_t         st_size;      //文件字节数(文件大小)
//     unsigned long st_blksize;   //块大小(文件系统的I/O 缓冲区大小)
//     unsigned long st_blocks;    //块数
//     time_t        st_atime;     //最后一次访问时间
//     time_t        st_mtime;     //最后一次修改时间
//     time_t        st_ctime;     //最后一次改变时间(指属性)
// };

// getattr() 类似于stat()
// readlink() 读取链接文件的真实文件路径
// getdir() 已经过时，使用readdir()替代
// mknod() 创建一个文件节点
// mkdir() 创建一个目录
// unlink() 删除一个文件
// rmdir() 删除一个目录
// syslink() 创建一个软链接
// rename() 重命名文件
// link() 创建一个硬链接
// chmod() 修改文件权限
// chown() 修改文件的所有者和所属组
// truncate() 改变文件的大小
// utime() 修改访问和修改文件的时间，已经过时，使用utimens()替代
// open() 打开文件
// read() 读取文件
// write() 写文件
// statfs() 获取文件系统状态
// flush() 刷缓存数据
// release() 释放打开的文件
// fsync() 同步数据
// setxattr() 扩展属性接口， 下同
// getxattr()
// listxattr()
// removexattr()
// opendir() 打开一个目录
// readdir() 读取目录
// releasedir() 释放打开的目录
// fsyncdir() 同步目录
// init() 初始化文件系统
// destroy() 清理文件系统
// access() 检查访问权限
// create() 创建并打开文件
// ftruncate() 修改文件的大小