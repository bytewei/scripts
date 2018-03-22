这个脚本主要用于自动安装saltstack，也可以将其修改为自动同步ansible密钥，进而实现服务器初始化前，可以用salt或ansible统一批处理。

生产环境涉及到salt双主，改脚本亦有所体现，详情请参考expect/readme.txt文档。

执行改脚本后，剩下的操作可以交由salt批处理。
