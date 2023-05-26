# CAIC Lab6

## 1 Systolic Array

用generate块与for循环对PE反复进行例化；

注意高位对应着标号小行，低位对应着标号大行

<img src="/Users/zhongzuoqi/Library/Application Support/typora-user-images/image-20230526165229738.png" alt="image-20230526165229738" style="zoom:50%;" />

第一次输出时发现输出的是ref矩阵的转置，将原先的`.result(results_unpacked[i][j])`改成`result(results_unpacked[j][i])`即输出正确结果。