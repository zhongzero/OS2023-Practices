	.file	"coroutine.c"
	.text
	.comm	mutex,40,32
	.local	pthread
	.comm	pthread,70840,32
	.section	.rodata
.LC0:
	.string	"%ld\n"
	.text
	.type	co_initial, @function
co_initial:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	call	pthread_self@PLT
	movq	%rax, %rsi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, -24(%rbp)
	jmp	.L2
.L3:
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	pthread(%rip), %rdx
	movb	$0, (%rax,%rdx)
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rdx
	movl	$-1, (%rax,%rdx)
	addl	$1, -24(%rbp)
.L2:
	cmpl	$54, -24(%rbp)
	jle	.L3
	movb	$1, pthread(%rip)
	call	pthread_self@PLT
	movq	%rax, 8+pthread(%rip)
	movl	$2000, %edi
	call	malloc@PLT
	movq	%rax, 16+pthread(%rip)
	movl	$0, -20(%rbp)
	jmp	.L4
.L5:
	movl	-20(%rbp), %eax
	cltq
	leaq	24+pthread(%rip), %rdx
	movb	$0, (%rax,%rdx)
	addl	$1, -20(%rbp)
.L4:
	cmpl	$249, -20(%rbp)
	jle	.L5
	movl	$249, 276+pthread(%rip)
	movl	276+pthread(%rip), %eax
	cltq
	leaq	24+pthread(%rip), %rdx
	movb	$1, (%rax,%rdx)
	movq	16+pthread(%rip), %rax
	movl	276+pthread(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	leaq	(%rax,%rdx), %rbx
	movl	$8408, %edi
	call	malloc@PLT
	movq	%rax, (%rbx)
	movq	16+pthread(%rip), %rax
	movl	276+pthread(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	$0, (%rax)
	movq	16+pthread(%rip), %rax
	movl	276+pthread(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$1, 12(%rax)
	movq	16+pthread(%rip), %rax
	movl	276+pthread(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$-1, 8(%rax)
	nop
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	co_initial, .-co_initial
	.section	.init_array,"aw"
	.align 8
	.quad	co_initial
	.text
	.type	co_finish, @function
co_finish:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$0, -8(%rbp)
	jmp	.L7
.L13:
	movl	-8(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	pthread(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	xorl	$1, %eax
	testb	%al, %al
	jne	.L14
	movl	$0, -4(%rbp)
	jmp	.L10
.L12:
	movl	-4(%rbp), %eax
	cltq
	movl	-8(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	je	.L11
	movl	-8(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	free@PLT
.L11:
	addl	$1, -4(%rbp)
.L10:
	cmpl	$249, -4(%rbp)
	jle	.L12
	movl	-8(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movq	%rax, %rdi
	call	free@PLT
	jmp	.L9
.L14:
	nop
.L9:
	addl	$1, -8(%rbp)
.L7:
	cmpl	$54, -8(%rbp)
	jle	.L13
	nop
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	co_finish, .-co_finish
	.section	.fini_array,"aw"
	.align 8
	.quad	co_finish
	.comm	g_pid,4,4
	.comm	g_i,4,4
	.comm	g_pid_self,4,4
	.section	.rodata
.LC1:
	.string	"coroutine.c"
.LC2:
	.string	"0"
	.text
	.type	getPid, @function
getPid:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	call	pthread_self@PLT
	movq	%rax, -8(%rbp)
	movl	$0, -12(%rbp)
	jmp	.L16
.L19:
	movl	-12(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	8+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	cmpq	%rax, -8(%rbp)
	jne	.L17
	movl	-12(%rbp), %eax
	jmp	.L20
.L17:
	addl	$1, -12(%rbp)
.L16:
	cmpl	$54, -12(%rbp)
	jle	.L19
	leaq	__PRETTY_FUNCTION__.3458(%rip), %rcx
	movl	$79, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC2(%rip), %rdi
	call	__assert_fail@PLT
.L20:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	getPid, .-getPid
	.type	Find_spare_cid, @function
Find_spare_cid:
.LFB9:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L22
.L25:
	movl	-4(%rbp), %eax
	cltq
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L23
	movl	-4(%rbp), %eax
	jmp	.L24
.L23:
	addl	$1, -4(%rbp)
.L22:
	cmpl	$249, -4(%rbp)
	jle	.L25
	movl	$-1, %eax
.L24:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	Find_spare_cid, .-Find_spare_cid
	.type	Find_other_co, @function
Find_other_co:
.LFB10:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L27
.L32:
	movl	-20(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rdx
	movl	(%rax,%rdx), %eax
	cmpl	%eax, -4(%rbp)
	je	.L33
	movl	-4(%rbp), %eax
	cltq
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	je	.L29
	movl	-20(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	testl	%eax, %eax
	je	.L30
	movl	-20(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$1, %eax
	jne	.L29
.L30:
	movl	-4(%rbp), %eax
	jmp	.L31
.L33:
	nop
.L29:
	addl	$1, -4(%rbp)
.L27:
	cmpl	$249, -4(%rbp)
	jle	.L32
	movl	$-1, %eax
.L31:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	Find_other_co, .-Find_other_co
	.type	IsAncestor, @function
IsAncestor:
.LFB11:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	movl	%edx, -12(%rbp)
	jmp	.L35
.L38:
	movl	-12(%rbp), %eax
	cmpl	-8(%rbp), %eax
	jne	.L36
	movl	$1, %eax
	jmp	.L37
.L36:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-12(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	8(%rax), %eax
	movl	%eax, -12(%rbp)
.L35:
	cmpl	$-1, -12(%rbp)
	jne	.L38
	movl	$0, %eax
.L37:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	IsAncestor, .-IsAncestor
	.section	.rodata
.LC3:
	.string	"!!! pid=%d\n"
.LC4:
	.string	"co number is full!"
	.text
	.globl	co_start
	.type	co_start, @function
co_start:
.LFB12:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -40(%rbp)
	movl	$0, %eax
	call	getPid
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC3(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-24(%rbp), %eax
	movl	%eax, %edi
	call	Find_spare_cid
	movl	%eax, -20(%rbp)
	cmpl	$-1, -20(%rbp)
	jne	.L40
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	leaq	__PRETTY_FUNCTION__.3488(%rip), %rcx
	movl	$113, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC2(%rip), %rdi
	call	__assert_fail@PLT
.L40:
	movl	-20(%rbp), %eax
	cltq
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movb	$1, (%rax)
	leaq	mutex(%rip), %rdi
	call	pthread_mutex_lock@PLT
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	leaq	(%rax,%rdx), %rbx
	movl	$8408, %edi
	call	malloc@PLT
	movq	%rax, (%rbx)
	leaq	mutex(%rip), %rdi
	call	pthread_mutex_unlock@PLT
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	-40(%rbp), %rdx
	movq	%rdx, (%rax)
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$0, 12(%rax)
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	leaq	276+pthread(%rip), %rcx
	movl	(%rdx,%rcx), %edx
	movl	%edx, 8(%rax)
	movl	-24(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rcx
	movl	-20(%rbp), %edx
	movl	%edx, (%rax,%rcx)
	movl	$0, %eax
	call	co_yield
	movl	-20(%rbp), %eax
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	co_start, .-co_start
	.globl	co_getid
	.type	co_getid, @function
co_getid:
.LFB13:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$0, %eax
	call	getPid
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rdx
	movl	(%rax,%rdx), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	co_getid, .-co_getid
	.section	.rodata
.LC5:
	.string	"pthread[pid].use[cid]==1"
	.text
	.globl	co_getret
	.type	co_getret, @function
co_getret:
.LFB14:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movl	$0, %eax
	call	getPid
	movl	%eax, -4(%rbp)
	movl	-20(%rbp), %eax
	cltq
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.L46
	leaq	__PRETTY_FUNCTION__.3496(%rip), %rcx
	movl	$133, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC5(%rip), %rdi
	call	__assert_fail@PLT
.L47:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rcx
	movl	-20(%rbp), %edx
	movl	%edx, (%rax,%rcx)
	movl	$0, %eax
	call	co_yield
.L46:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	jne	.L47
	movl	-20(%rbp), %eax
	cltq
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$322, %rdx, %rdx
	addq	%rdx, %rax
	addq	$68, %rax
	leaq	0(,%rax,4), %rdx
	leaq	8+pthread(%rip), %rax
	movl	(%rdx,%rax), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	co_getret, .-co_getret
	.section	.rodata
.LC6:
	.string	"sp=%lx,bp=%lx\n"
.LC7:
	.string	"@@@ pid=%d,retans=%d\n"
	.text
	.globl	co_yield
	.type	co_yield, @function
co_yield:
.LFB15:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, %eax
	call	getPid
	movl	%eax, -36(%rbp)
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rdx
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rcx
	movl	(%rax,%rcx), %eax
	cltq
	salq	$3, %rax
	addq	%rdx, %rax
	movq	(%rax), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	_setjmp@PLT
	endbr64
	movl	%eax, -32(%rbp)
	cmpl	$0, -32(%rbp)
	jne	.L51
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rdx
	movl	(%rax,%rdx), %eax
	cmpl	$-1, %eax
	jne	.L52
	movl	-36(%rbp), %eax
	movl	%eax, %edi
	call	Find_other_co
	jmp	.L53
.L52:
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rdx
	movl	(%rax,%rdx), %eax
.L53:
	movl	%eax, -28(%rbp)
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rdx
	movl	(%rax,%rdx), %eax
	cmpl	$-1, %eax
	je	.L54
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rdx
	movl	$-1, (%rax,%rdx)
.L54:
	cmpl	$-1, -28(%rbp)
	jne	.L55
	movl	$0, %eax
	jmp	.L56
.L55:
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-28(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	testl	%eax, %eax
	jne	.L57
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rcx
	movl	-28(%rbp), %edx
	movl	%edx, (%rax,%rcx)
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rdx
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rcx
	movl	(%rax,%rcx), %eax
	cltq
	salq	$3, %rax
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$1, 12(%rax)
	movl	$0, -40(%rbp)
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-28(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	addq	$216, %rax
	leaq	8192(%rax), %rdx
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rcx
	movq	(%rax,%rcx), %rax
	movl	-28(%rbp), %ecx
	movslq	%ecx, %rcx
	salq	$3, %rcx
	addq	%rcx, %rax
	movq	(%rax), %rax
	movq	(%rax), %rax
	movq	%rax, %rcx
#APP
# 188 "coroutine.c" 1
	leaq -0x10(%rdx), %rsp;movq %rsp,%rbp; call *%rcx; movl %eax,-40(%rbp);
# 0 "" 2
# 199 "coroutine.c" 1
	movq %rsp, -24(%rbp); movq %rbp, -16(%rbp);
# 0 "" 2
#NO_APP
	movq	-16(%rbp), %rdx
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC6(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-40(%rbp), %edx
	movl	-36(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	call	getPid
	movl	-40(%rbp), %edx
	movl	-36(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rdx
	movl	(%rax,%rdx), %edx
	movl	-40(%rbp), %eax
	movslq	%edx, %rdx
	movl	-36(%rbp), %ecx
	movslq	%ecx, %rcx
	imulq	$322, %rcx, %rcx
	addq	%rcx, %rdx
	addq	$68, %rdx
	leaq	0(,%rdx,4), %rcx
	leaq	8+pthread(%rip), %rdx
	movl	%eax, (%rcx,%rdx)
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rdx
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rcx
	movl	(%rax,%rcx), %eax
	cltq
	salq	$3, %rax
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$2, 12(%rax)
	movl	$0, %eax
	call	co_yield
	jmp	.L51
.L57:
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rcx
	movl	-28(%rbp), %edx
	movl	%edx, (%rax,%rcx)
	movl	-36(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-28(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	addq	$16, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	longjmp@PLT
.L51:
	movl	$0, %eax
.L56:
	movq	-8(%rbp), %rsi
	xorq	%fs:40, %rsi
	je	.L58
	call	__stack_chk_fail@PLT
.L58:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	co_yield, .-co_yield
	.globl	co_waitall
	.type	co_waitall, @function
co_waitall:
.LFB16:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$0, %eax
	call	getPid
	movl	%eax, -4(%rbp)
.L66:
	movb	$0, -9(%rbp)
	movl	$0, -8(%rbp)
	jmp	.L60
.L63:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rdx
	movl	(%rax,%rdx), %eax
	cmpl	%eax, -8(%rbp)
	je	.L61
	movl	-8(%rbp), %eax
	cltq
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	je	.L61
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-8(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	je	.L61
	movb	$1, -9(%rbp)
	jmp	.L62
.L61:
	addl	$1, -8(%rbp)
.L60:
	cmpl	$249, -8(%rbp)
	jle	.L63
.L62:
	movzbl	-9(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	jne	.L69
	movl	$0, %eax
	call	co_yield
	jmp	.L66
.L69:
	nop
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	co_waitall, .-co_waitall
	.globl	co_wait
	.type	co_wait, @function
co_wait:
.LFB17:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movl	$0, %eax
	call	getPid
	movl	%eax, -4(%rbp)
	movl	-20(%rbp), %eax
	cltq
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.L72
	leaq	__PRETTY_FUNCTION__.3522(%rip), %rcx
	movl	$259, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC5(%rip), %rdi
	call	__assert_fail@PLT
.L73:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	1280+pthread(%rip), %rcx
	movl	-20(%rbp), %edx
	movl	%edx, (%rax,%rcx)
	movl	$0, %eax
	call	co_yield
.L72:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	jne	.L73
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	co_wait, .-co_wait
	.section	.rodata
.LC8:
	.string	"%d %d\n"
	.text
	.globl	co_status
	.type	co_status, @function
co_status:
.LFB18:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movl	$0, %eax
	call	getPid
	movl	%eax, -4(%rbp)
	movl	-20(%rbp), %eax
	cltq
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$1288, %rdx, %rdx
	addq	%rax, %rdx
	leaq	24+pthread(%rip), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.L76
	leaq	__PRETTY_FUNCTION__.3530(%rip), %rcx
	movl	$269, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC5(%rip), %rdi
	call	__assert_fail@PLT
.L76:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	276+pthread(%rip), %rdx
	movl	(%rax,%rdx), %ecx
	movl	-20(%rbp), %edx
	movl	-4(%rbp), %eax
	movl	%ecx, %esi
	movl	%eax, %edi
	call	IsAncestor
	testb	%al, %al
	je	.L77
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	jne	.L78
	movl	$2, %eax
	jmp	.L79
.L78:
	movl	-4(%rbp), %eax
	cltq
	imulq	$1288, %rax, %rax
	leaq	16+pthread(%rip), %rdx
	movq	(%rax,%rdx), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %edx
	movl	-20(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC8(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1, %eax
	jmp	.L79
.L77:
	movl	$-1, %eax
.L79:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	co_status, .-co_status
	.section	.rodata
	.type	__PRETTY_FUNCTION__.3458, @object
	.size	__PRETTY_FUNCTION__.3458, 7
__PRETTY_FUNCTION__.3458:
	.string	"getPid"
	.align 8
	.type	__PRETTY_FUNCTION__.3488, @object
	.size	__PRETTY_FUNCTION__.3488, 9
__PRETTY_FUNCTION__.3488:
	.string	"co_start"
	.align 8
	.type	__PRETTY_FUNCTION__.3496, @object
	.size	__PRETTY_FUNCTION__.3496, 10
__PRETTY_FUNCTION__.3496:
	.string	"co_getret"
	.align 8
	.type	__PRETTY_FUNCTION__.3522, @object
	.size	__PRETTY_FUNCTION__.3522, 8
__PRETTY_FUNCTION__.3522:
	.string	"co_wait"
	.align 8
	.type	__PRETTY_FUNCTION__.3530, @object
	.size	__PRETTY_FUNCTION__.3530, 10
__PRETTY_FUNCTION__.3530:
	.string	"co_status"
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
