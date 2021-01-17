见解
CoturnConfig
MészárosMihály编辑了此页面 on 9 Dec 2020 · 5个修订
该维基百科已经过时，将很快被删除！请检查源以获取更多最新文档：https : //github.com/coturn/coturn
介绍
Coturn有多个选项，配置可能很复杂。好消息是大多数人都需要使用这些选项的大多数默认值。尽管如此，此页面仍提供了简单的入门设置指南。

（本文档的某些部分摘自Dialogic TURN服务器配置指南http://www.dialogic.com/den/developer_forums/f/71/t/10238.aspx）

细节
操作系统
一个简单的面向服务器的操作系统配置就足够了。

我们假定用于TURN的系统位于公共IP地址，不涉及防火墙。可以使用诸如AWS的云服务来设置TURN服务器，但这超出了这些说明的范围。coturn项目下载页面提供了为云服务设置的Amazon AWS EC2映像的示例。

第三方图书馆
如果要在Debian，Ubuntu或Mint中安装coturn软件包，或者在FreeBSD中安装“ turnserver”端口，或者要在项目的“下载”部分中安装提供的二进制文件之一，则操作系统和第三方软件包会自动安装。以下说明适用于从头开始设置TURN服务器的人员。

在安装和配置TURN服务器之前，应下载，构建和安装最新的稳定libevent库：

$ wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
以root用户身份，使用通常的方式构建和安装该库：

$ tar xvfz libevent-2.0.21-stable.tar.gz
$ cd libevent-2.0.21-stable
$ ./configure
$ make
$ make install
默认设置假定您使用sqlite作为数据库引擎，这对于大多数用途而言已足够。如果您的项目需要其他数据库（mysql，postgresql，mongodb，redis），请检查INSTALL文件以获取说明。

您还将需要一个相对较新的OpenSSL版本。

Coturn安装
我们假定您从源头安装Coturn。

从https://github.com/coturn/coturn/wiki/Downloads下载TURN服务器。构建并安装：

$ tar xvfz turnserver-<...>.tar.gz
$ ./configure
$ make
$ make install
用服务器检查INSTALL和README文件。它们包含许多有用的信息。

默认情况下，coturn将SQLite数据库用于用户和设置。当流程Turnserver第一次启动时，将自动创建（空）该数据库。

使用turnadmin实用程序添加长期TURN用户。例如，此命令将用户密码“ youhavetoberealistic”，领域“ north.gov”的ninefinger添加到默认的sqlite数据库：

$ sudo turnadmin -a -u ninefingers -r north.gov -p youhavetoberealistic
使用turnadmin实用程序将admin用户添加到数据库。如果您添加了这些用户，则将能够从浏览器通过HTTPS连接到TURN服务器端口，并通过Web界面执行管理任务。

例如，以下命令添加密码为magi的管理员用户bayaz：

$ sudo bin/turnadmin -A -u bayaz -p magi
在创建RTCPeerConnection的Javascript代码中，如下引用TURN服务器：

        var pc_config = {"iceServers": [{"url": "stun:stun.l.google.com:19302"},
                        {"url":"turn:my_username@<turn_server_ip_address>", 
                                          "credential":"my_password"}]};
        pc_new = new webkitRTCPeerConnection(pc_config);
在您的Javascript代码中嵌入可见的密码可能会允许其他人使用您的TURN服务器。可以通过TURN REST API的使用进行修复（请参阅项目Wiki页面）。

由于服务器是可公开访问的，因此应尽可能限制对其的访问。至少应为TCP和UDP打开端口3478（STUN）。假设我们使用的是CentOS，在CentOS上最方便的方法是使用“设置”的防火墙配置选项。选择“自定义并转发”，直到找到“其他端口”屏幕。在那里添加3478：tcp和3478：upd。关闭并保存，然后使用以下命令重新启动防火墙：

$ service iptables restart
使用以下方法检查防火墙：

> service iptables status
Table: filter
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
2    REJECT     icmp --  0.0.0.0/0            0.0.0.0/0           icmp type 8 reject-with icmp-host-prohibited
3    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
5    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22
6    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:3478
7    ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0           state NEW udp dpt:3478
8    REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination
1    REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination

请注意，此配置已禁用ICMP ping，以使系统更难找到，并且端口22保持打开状态以进行SSH访问。

最后，对于这种相对简单的情况，即该系统使用具有单个以太网NIC和IP地址且没有NAT防火墙的系统，请启动TURN服务器：

$ turnserver -L <public_ip_address> -a -f -r <realm-name>
或者，使用以下命令作为守护程序启动它：

$ turnserver -L <public_ip_address> -o -a -f -r <realm-name>
现在，当ICE决定需要WebRTC连接时，TURN服务器应该已准备就绪，可以用于媒体中继。