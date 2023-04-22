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

### test 1

由于add的指令比起一堆lw lb什么的好读一些，所以就先从test1开始。

发现了rd_mem存在的问题（在不应该变化时进行了变化），原来是一开始的设计中instr没经过reg直接去id了，，，



现在是14ns的时候rs2_data的选择出错，在ex阶段
