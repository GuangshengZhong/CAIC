# CAIC Lab4 Report

## 1 设计思路

这次lab的难度比之前大了不少，而且提示也少了一些，所以在此记录一些设计思路：

### 关于每个Reg存什么

从lab3的图来看，

### IF模块

IF模块需要产生一些bubble

## 2 痛苦Debug

### test 0 

Data_in出错->rs2_data_new出错->rs2_data出错（橙色是idmodule的）

是忘了在regfile的端口里对reg_write_data_mem与reg_write_data_wb进行选择，仅仅接入了reg_write_data_wb

在control unit里的`reg_write_addr = instr[11:7];`一句进行提前，实时更新

写寄存器改为在negedge

尤其需要注意的是id的reg_write，有一个out是往后传，有一个in是后面送过来的。一开始弄混了，debug了好久啊啊啊！找到这个bug之后除了branch（test3）都过了

### test 1

由于add的指令比起一堆lw lb什么的好读一些，所以就先从test1开始。

发现了rd_mem存在的问题（在不应该变化时进行了变化），原来是一开始的设计中instr没经过reg直接去id了，，，



现在是14ns的时候rs2_data的选择出错，在ex阶段

### test 3

极度痛苦

无论是否跳转，只要指令是branch类型，均将reg_src置为1？

257ns处 pc+4_if本该为60但是为04

257ns出的reg_src_mem应该是11而不是00

目前的问题:zero和less than的计算的问题

zero和less than

### test 2

调通branch之后

写了

