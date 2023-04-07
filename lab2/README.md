1) 你需要做什么
>文件命名和结构树已经为大家建立完毕，大家需要完成的内容已用#TODO标志标注。
>其中，top.v文件已经预定义了输入输出接口，**切勿改动已给出的接口！**
>具体需要完善的文件有：

```
.
├── ./src/cp_components/alu_control.v
├── ./src/cp_components/control_unit.v
├── ./src/dp_components/pc.v
├── ./src/dp_components/regfile.v
├── ./src/template/adder.v(这是一个模板文件，定义了带参数的模块)
├── ./src/defines.v
├── ./src/ram.v(应该已经在lab1中完成，如果有同学没来得及完成lab1又想继续完成lab2，我们会后续给出ram.v的参考代码)
├── ./src/top.v
```

2) 我们检查什么
>本网站只会加载上述文件及他们调用的文件（如果有）并使用服务器内置的测试文件进行测试。请注意，服务器内置的测试文件难度不低于已经给出的测试文件。

3) 你需要上传什么
>请将./src文件夹下的文件完善并**把整个./src**打包上传。
>注：在这个过程中，你可以定义自己需要的模块并引用他们。