# rootless_go_manager

一个面向软件的无需 root 的 golang 安装 + 更新脚本

## 脚本用法

从网络执行本脚本
```
bash <(curl https://raw.githubusercontent.com/AsenHu/rootless_go_manager/main/install.sh) @ install
```
下一次执行使用 ~/GO/install.sh 即可

```
用法：install.sh 操作 [选项]...

操作：
install                   使用 --path=$HOME/GO 安装 golang
version                   获取脚本版本
help                      显示帮助（别名：-h|--help）
如果没有指定操作，则将选择帮助。

选项：
  install（安装）：
    --force                       如果指定了此选项，脚本将强制安装最新版本的 Golang。
    --path=                       如果指定了此选项，脚本将安装最新版本的 Golang 到您指定的路径。
                                    例如，如果指定了 `--path=/root/GO`，脚本将安装 Golang 到 `/root/GO/go` 中，并将脚本和缓存文件放置在 `/root/GO`。
```

如果要卸载，请直接删除脚本所在的文件夹。

## 脚本输出

```
SCRIPT:<GO 路径>:<GO 版本>
BOTH:<脚本 GO 路径>:<脚本 GO 版本>:<系统 GO 版本>
SYSTEM:<GO 版本>
ERROR:<错误原因>
```

## 关于 CGO

开了 CGO 爱出问题，所以默认不开。有需要的自己 go env -w 来开

# 示例 dll.sh

里面是一个方便其他脚本使用这个脚本的一段代码，它可以分辨这个脚本的四种输出并作出不同的处理。例如输出错误信息 / 将 go 添加到环境变量等等...
