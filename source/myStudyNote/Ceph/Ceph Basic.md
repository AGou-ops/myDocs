# Ceph Basic    

> 转载自：https://www.cnblogs.com/flytor/p/11386590.html

## Ceph 概述和理论

1.1 Ceph概述

官网地址:https://docs.ceph.com/docs/master/

1.Ceph简介

概述：Ceph是可靠的、可扩展的、统一的、分布式的存储系统。同时提供对象存储RADOSGW(Reliable、Autonomic、Distributed、Object Storage Gateway)、块存储RBD(Rados Block Device)、文件系统存储CephFS(Ceph Filesystem)3种功能，以此来满足不同的应用需求。

2.Ceph发展：略

3.Ceph应用场景

| 对象存储 | 网盘应用业务（owncloud） |
| -------- | ------------------------ |
| 块存储   | Iaas、云平台、KVM等      |
| 文件系统 | hadoop后端高性能存储     |

 

4.Ceph版本（LTS代表长期稳定版）

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105030921-1595738457.png)

 

1.2 Ceph功能组件

   Ceph提供了RADOS、OSD、MON、Librados、RBD、RGW和Ceph FS等功能组件，但其底层仍然使用RADOS存储来支撑上层的那些组件。整体结构如图：

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105041310-2001861585.png)

 

 

 

（1）核心组件介绍：

Ceph存储中，包含的三个重要的核心组件，分别是Ceph OSD、Ceph Monitor和Ceph MDS。一个Ceph存储集群至少需要一个Ceph Monitor和至少两个Ceph的OSD,运行Ceph文件系统的客户端时，Ceph的元数据服务器（MDS）是必不可少的。

 

三大核心组件介绍如下：

| Ceph OSD     | 存储设备，主要功能是存储数据，处理数据的复制、恢复、回补、平衡数据分布，上报相关数据给Ceph Monitor,例如：Ceph OSD心跳等。eg:每一个Disk、分区都可以成为一个OSD |
| ------------ | ------------------------------------------------------------ |
| Ceph Monitor | 监视器，主要功能是维护整个集群健康状态，提供一致性的决策。包含了Monitor map、OSD map、PG（Placement Group）map和Crush map |
| Ceph MDS     | 元数据服务器，主要功能是保存Ceph文件系统的元数据。eg:块存储和对象存储都不需要MDS, MDS为基于POSIX文件系统的用户提供了一些基础命令，比如ls、find等命令 |

 

（2）Ceph功能特性

Ceph可以同时提供对象存储RADOSGW（Reliable、Autonomic、Distributed、Object

Storage Gateway ）、块存储RBD（Rados Block Device）、文件系统存储Ceph FS（Ceph FileSystem）3种功能，由此产生了对应的实际场景，本节简单介绍如下。

| RADOSGW                      | 功能特性基于LIBRADOS之上，提供当前流行的RESTful协议的网关，并且兼容S3和Swift接口，作为对象存储，可以对接网盘类应用以及HLS流媒体应用等。 |
| ---------------------------- | ------------------------------------------------------------ |
| RBD（Rados Block Device）    | 功能特性也是基于LIBRADOS之上，通过LIBRBD创建一个块设备，通过QEMU/KVM附加到VM上，作为传统的块设备来用。目前OpenStack、CloudStack等都是采用这种方式来为VM提供块设备，同时也支持快照、COW（Copy On Write）等功能。 |
| Ceph FS（Ceph File Sy stem） | 功能特性是基于RADOS来实现分布式的文件系统，引入MDS（Metadata Server），主要为兼容POSIX文件系统提供元数据。一般都是当做文件系统来挂载。 |

 

 

 

1.3　Ceph架构和设计思想

1.Ceph架构

Ceph底层核心是RADOS。Ceph架构图如下图:

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105101092-2051519821.png)

 

 

| RADOS    | RADOS具备自我修复等特性，提供了一个可靠、自动、智能的分布式存储 |
| -------- | ------------------------------------------------------------ |
| LIBRADOS | LIBRADOS库允许应用程序直接访问，支持C/C++、Java和Py thon等语言 |
| RADOSGW  | RADOSGW是一套基于当前流行的RESTful协议的网关，并且兼容S3和Swift |
| RBD      | RBD通过Linux内核（Kernel）客户端和QEMU/KVM驱动，来提供一个完全分布式的块设备 |
| Ceph FS  | Ceph FS通过Linux内核（Kernel）客户端结合FUSE，来提供一个兼容POSIX的文件系统 |

 

2.Ceph设计思想（从应用场景以及技术特性来分析）

 

Ceph最初针对的应用场景，就是大规模的、分布式的存储系统。所谓“大规

模”和“分布式”，至少是能够承载PB级别的数据和成千上万的存储节点组成的存储集群。

 

Ceph的技术特性，总体表现在集群可靠性、集群扩展性、数据安全性、接口统一性4个方面：

| 集群可靠性   | 用户数据的不会丢失，数据写入过程中的可靠性，降低不可控物理因素的可靠性 |
| ------------ | ------------------------------------------------------------ |
| 集群可扩展性 | 系统规模和存储容量的可扩展，也包括随着系统节点数增加的聚合数据访问带宽的线性扩展。 |
| 数据安全性   | 要保证由于服务器死机或者是偶然停电等自然因素的产生，数据不会丢失，并且支持数据自动恢复，自动重平衡等。总体而言，这一特性既保证了系统的高度可靠和数据绝对安全，又保证了在系统规模扩大之后，其运维难度仍能保持在一个相对较低的水平。 |
| 接口统一性   | Ceph可以同时支持3种存储，即块存储、对象存储和文件存储。Ceph支持市面上所有流行的存储类型。 |

 

Ceph的设计思想：充分发挥存储本身计算能力和去除所有的中心点

| 充分发挥存储设备自身的计算能力 | 采用廉价的设备和具有计算能力的设备作为存储系统的存储点。Sage认为当前阶段只是将这些服务器当做功能简单的存储节点，从而产生资源过度浪费。而如果充分发挥节点上的计算能力，则可以实现前面提出的技术特性。 |
| ------------------------------ | ------------------------------------------------------------ |
| 去除所有的中心点               | 解决单点故障点和性能瓶颈的问题，虽然单点故障点和性能瓶颈的问题可以通过为中心点增加HA或备份加以缓解，但Ceph系统最终采用Crush、Hash环等方法更彻底地解决了这个问题。 |

 

========================================================================================================================================================

RADIOS简介：

分布式对象存储系统RADOS是Ceph最为关键的技术，它是一个支持海量存储对象的分布式

对象存储系统。RADOS层本身就是一个完整的对象存储系统，事实上，所有存储在Ceph系统中的用户数据最终都是由这一层来存储的。而Ceph的高可靠、高可扩展、高性能、高自动化等特性，本质上也是由这一层所提供的。因此，理解RADOS是理解Ceph的基础与关键。

 

Ceph的设计哲学：

（1）每个组件必须可扩展

（2）不存在单点故障

（3）解决方案必须是基于软件的

（4）可摆脱专属硬件的束缚即可运行在常规硬件上

（5）推崇自我管理

 

Ceph包含的组件：

（1）分布式对象存储系统RADOS库，即LIBRADOS

（2）基于LIBRADOS实现的兼容Swift和S3的存储网关系统RADOSGW

（3）基于LIBRADOS实现的块设备驱动RBD

（4）兼容POSIX的分布式文件Ceph FS

（5）最底层的分布式对象存储系统RADOS

 

2.1 Ceph功能模块与RADOS

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105223534-1712884148.png)

 

 

 

Ceph存储系统的逻辑层次结构大致划分为4部分：基础存储系统RADOS、基于RADOS实现

的Ceph FS，基于RADOS的LIBRADOS层应用接口、基于LIBRADOS的应用接口RBD、RADOSGW。

 

各模块的功能介绍：

| 基础存储系统RADOS | RADOS这一层本身就是一个完整的对象存储系统，事实上，所有存储在Ceph系统中的用户数据最终都是由这一层来存储的。Ceph的很多优秀特性本质上也是借由这一层设计提供。理解RADOS是理解Ceph的基础与关键。物理上，RADOS由大量的存储设备节点组成，每个节点拥有自己的硬件资源（CPU、内存、硬盘、网络），并运行着操作系统和文件系统 |
| ----------------- | ------------------------------------------------------------ |
| 基础库LIBRADOS    | LIBRADOS层的功能是对RADOS进行抽象和封装，并向上层提供API，以便直接基于RADOS进行应用开发。需要指明的是，RADOS是一个对象存储系统，因此，LIBRADOS实现的API是针对对象存储功能的。RADOS采用C++开发，所提供的原生LIBRADOS API包括C和C++两种。物理上，LIBRADOS和基于其上开发的应用位于同一台机器，因而也被称为本地API。应用调用本机上的LIBRADOS API，再由后者通过socket与RADOS集群中的节点通信并完成各种操作。 |
| 上层应用接口      | Ceph上层应用接口涵盖了RADOSGW（RADOS Gateway ）、RBD（Reliable BlockDevice）和Ceph FS（Ceph File System），其中，RADOSGW和RBD是在LIBRADOS库的基础上提供抽象层次更高、更便于应用或客户端使用的上层接口 |
| 应用层            | 应用层就是不同场景下对于Ceph各个应用接口的各种应用方式，例如基于LIBRADOS直接开发的对象存储应用，基于RADOSGW开发的对象存储应用，基于RBD实现的云主机硬盘等 |

 

2.2 RADOS架构

RADOS系统主要由OSD和Monitor两部分组成。

| OSD     | 由数目可变的大规模OSD（Object Storage Devices）组成的集群，负责存储所有的Objects数据。 |
| ------- | ------------------------------------------------------------ |
| Monitor | 由少量Monitors组成的强耦合、小规模集群，负责管理Cluster Map。其中，Cluster Map是整个RADOS系统的关键数据结构，管理集群中的所有成员、关系和属性等信息以及数据的分发。 |



 

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105235684-1782848233.png)

 

对于RADOS系统，节点组织管理和数据分发策略均由内部的Mon全权负责，因此，从Client

角度设计相对比较简单，它给应用提供存储接口。

 

2.2.1 Monitor介绍

Ceph Monitor是负责监视整个群集的运行状况的，这些信息都是由维护集群成员

的守护程序来提供的，如各个节点之间的状态、集群配置信息。Ceph monitor map包括OSDMap、PG Map、MDS Map和CRUSH等，这些Map被统称为集群Map。

 

| Monitor Map | Monitor Map包括有关monitor节点端到端的信息，其中包括Ceph集群ID，监控主机名和IP地址和端口号，它还存储了当前版本信息以及最新更改信息。查看monitor map命令：ceph mon dump |
| ----------- | ------------------------------------------------------------ |
| OSD Map     | OSD Map包括一些常用的信息，如集群ID，创建OSD Map的版本信息和最后修改信息，以及pool相关信息，pool的名字、pool的ID、类型，副本数目以及PGP，还包括OSD信息，如数量、状态、权重、最新的清洁间隔和OSD主机信息。查看osd map命令：ceph osd dump |
| PG Map      | PG Map包括当前PG版本、时间戳、最新的OSD Map的版本信息、空间使用比例，以及接近占满比例信息，同时，也包括每个PG ID、对象数目、状态、OSD的状态以及深度清理的详细信息。查看pg map命令：ceph pg dump |
| CRUSH Map   | CRUSH Map包括集群存储设备信息，故障域层次结构和存储数据时定义失败域规则信息，查看crush map命令：ceph crush dump |
| MDS Map     | MDS Map包括存储当前MDS Map的版本信息、创建当前Map的信息、修改时间、数据和元数据POOL ID、集群MDS数目和MDS状态，查看crush map命令：ceph mds dump |

 

Ceph的MON服务利用Paxos的实例，把每个映射图存储为一个文件。Ceph Monitor并未为客户提供数据存储服务，而是为Ceph集群维护着各类Map，并服务更新群集映射到客户机以及其他集群节点。客户端和其他群集节点定期检查并更新于Monitor的集群Map最新的副本。

 

Ceph Monitor是个轻量级的守护进程，通常情况下并不需要大量的系统资源，低成本、入门级的CPU，以及千兆网卡即可满足大多数的场景；与此同时，Monitor节点需要有足够的磁盘空间来存储集群日志，健康集群产生几MB到GB的日志；然而，如果存储的需求增加时，打开低等级的日志信息的话，可能需要几个GB的磁盘空间来存储日志。

 

一个典型的Ceph集群包含多个Monitor节点。一个多Monitor的Ceph的架构通过法定人数来选择leader，并在提供一致分布式决策时使用Paxos算法集群。在Ceph集群中有多个Monitor时，集群的Monitor应该是奇数；最起码的要求是一台监视器节点，这里推荐Monitor个数是3。由于Monitor工作在法定人数，一半以上的总监视器节点应该总是可用的，以应对死机等极端情况，这是Monitor节点为N（N>0）个且N为奇数的原因。所有集群Monitor节点，其中一个节点为Leader。如果Leader Monitor节点处于不可用状态，其他显示器节点有资格成为Leader。生产群集必须至少有N/2个监控节点提供高可用性。

 

2.2.2 Ceph OSD简介

Ceph OSD是Ceph存储集群最重要的组件，Ceph OSD将数据以对象的形式存储到集群中每个节点的物理磁盘上，完成存储用户数据的工作绝大多数都是由OSD deamon进程来实现的。

 

Ceph集群一般情况都包含多个OSD，对于任何读写操作请求，Client端从Ceph Monitor获取Cluster Map之后，Client将直接与OSD进行I/O操作的交互，而不再需要Ceph Monitor干预。这使得数据读写过程更为迅速，因为这些操作过程不像其他存储系统，它没有其他额外的层级数据处理。

 

Ceph的核心功能特性包括高可靠、自动平衡、自动恢复和一致性。对于Ceph OSD而言，基于配置的副本数，Ceph提供通过分布在多节点上的副本来实现，使得Ceph具有高可用性以及容错性。在OSD中的每个对象都有一个主副本，若干个从副本，这些副本默认情况下是分布在不同节点上的，这就是Ceph作为分布式存储系统的集中体现。每个OSD都可能作为某些对象的主OSD，与此同时，它也可能作为某些对象的从OSD，从OSD受到主OSD的控制，然而，从OSD在某些情况也可能成为主OSD。在磁盘故障时，Ceph OSD Deamon的智能对等机制将协同其他OSD执行恢复操作。在此期间，存储对象副本的从OSD将被提升为主OSD，与此同时，新的从副本将重新生成，这样就保证了Ceph的可靠和一致。

 

Ceph OSD架构实现由物理磁盘驱动器、在其之上的Linux文件系统以及Ceph OSD服务组成。对Ceph OSD Deamon而言，Linux文件系统显性地支持了其扩展属性；这些文件系统的扩展属性提供了关于对象状态、快照、元数据内部信息；而访问Ceph OSD Deamon的ACL则有助于数据管理。

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105257507-1635159828.png)

 

 

Ceph OSD操作必须在一个有效的Linux分区的物理磁盘驱动器上，Linux分区可以是

BTRFS、XFS或者EXT4分区，文件系统是对性能基准测试的主要标准之一，下面来逐一了解。

1）BTRFS：在BTRFS文件系统的OSD相比于XFS和EXT4提供了最好的性能。BTRFS的主要优点有以下4点。

 

扩展性（scalability ）：BTRFS最重要的设计目标是应对大型机器对文件系统的扩展性要求。Extent、B-Tree和动态inode创建等特性保证了BTRFS在大型机器上仍有卓越的表现，其整体性能不会随着系统容量的增加而降低。

 

·数据一致性（data integrity ）：当系统面临不可预料的硬件故障时，BTRFS采用COW事务技术来保证文件系统的一致性。BTRFS还支持校验和，避免了silent corrupt（未知错误）的出现。而传统文件系统无法做到这一点。

 

·多设备管理相关的特性：BTRFS支持创建快照（snapshot）和克隆（clone）。BTRFS还能够方便地管理多个物理设备，使得传统的卷管理软件变得多余。

 

·结合Ceph，BTRFS中的诸多优点中的快照，Journal of Parallel（并行日志）等优势在Ceph中表现得尤为突出，不幸的是，BTRFS还未能到达生产环境要求的健壮要求。暂不推荐用于Ceph集群的生产使用。

 

2）XFS：一种高性能的日志文件系统，XFS特别擅长处理大文件，同时提供平滑的数据传输。目前CentOS 7也将XFS+LVM作为默认的文件系统。XFS的主要优点如下。

 

·分配组：XFS文件系统内部被分为多个“分配组”，它们是文件系统中的等长线性存储区。每个分配组各自管理自己的inode和剩余空间。文件和文件夹可以跨越分配组。这一机制为XFS提供了可伸缩性和并行特性——多个线程和进程可以同时在同一个文件系统上执行I/O操作。这种由分配组带来的内部分区机制在一个文件系统跨越多个物理设备时特别有用，使得优化对下级存储部件的吞吐量利用率成为可能。

 

·条带化分配：在条带化RAID阵列上创建XFS文件系统时，可以指定一个“条带化数据单元”。这可以保证数据分配、inode分配，以及内部日志被对齐到该条带单元上，以此最大化吞吐量。

 

·基于Extent的分配方式：XFS文件系统中的文件用到的块由变长Extent管理，每一个Extent描述了一个或多个连续的块。对那些把文件所有块都单独列出来的文件系统来说，Extent大幅缩短了列表。有些文件系统用一个或多个面向块的位图管理空间分配——在XFS中，这种结构被由一对B+树组成的、面向Extent的结构替代了；每个文件系统分配组（AG）包含这样的一个结构。其中，一个B+树用于索引未被使用的Extent的长度，另一个索引这些Extent的起始块。这种双索引策略使得文件系统在定位剩余空间中的Extent时十分高效。

 

·扩展属性：XFS通过实现扩展文件属性给文件提供了多个数据流，使文件可以被附加多个名/值对。文件名是一个最大长度为256字节的、以NULL字符结尾的可打印字符串，其他的关联值则可包含多达64KB的二进制数据。这些数据被进一步分入两个名字空间中，分别为root和user。保存在root名字空间中的扩展属性只能被超级用户修改，保存在user名字空间中的可以被任何对该文件拥有写权限的用户修改。扩展属性可以被添加到任意一种XFS inode上，包括符号链接、设备节点和目录等。可以使用attr命令行程序操作这些扩展属性。xfsdump和xfsrestore工具在进行备份和恢复时会一同操作扩展属性，而其他的大多数备份系统则会忽略扩展属性。

 

·XFS作为一款可靠、成熟的，并且非常稳定的文件系统，基于分配组、条带化分配、基于Extent的分配方式、扩展属性等优势非常契合Ceph OSD服务的需求。美中不足的是，XFS不能很好地处理Ceph写入过程的journal问题。

 

3）Ext4：第四代扩展文件系统，是Linux系统下的日志文件系统，是Ext3文件系统的后继版本。其主要特征如下。

 

·大型文件系统：Ext4文件系统可支持最高1 Exbiby te的分区与最大16 Tebiby te的文件。

 

·Extents：Ext4引进了Extent文件存储方式，以替换Ext2/3使用的块映射（block mapping）方式。Extent指的是一连串的连续实体块，这种方式可以增加大型文件的效率并减少分裂文件。

 

·日志校验和：Ext4使用校验和特性来提高文件系统可靠性，因为日志是磁盘上被读取最频繁的部分之一。

 

·快速文件系统检查：Ext4将未使用的区块标记在inode当中，这样可以使诸如e2fsck之类的工具在磁盘检查时将这些区块完全跳过，而节约大量的文件系统检查的时间。这个特性已经在2.6.24版本的Linux内核中实现。

 

Ceph OSD把底层文件系统的扩展属性用于表示各种形式的内部对象状态和元数据。XATTR是以key /value形式来存储xattr_name和xattr_value，并因此提供更多的标记对象元数据信息的方法。Ext4文件系统提供不足以满足XATTR，由于XATTR上存储的字节数的限制能力，从而使Ext4文件系统不那么受欢迎。然而，BTRFS和XFS有一个比较大的限制XATTR。

 

Ceph使用日志文件系统，如增加了BTRFS和XFS的OSD。在提交数据到后备存储器之前，Ceph首先将数据写入称为一个单独的存储区，该区域被称为journal，这是缓冲器分区在相同或单独磁盘作为OSD，一个单独的SSD磁盘或分区，甚至一个文件文件系统。在这种机制下，Ceph任何写入首先是日志，然后是后备存储

 

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105317471-1303516705.png)

 

 

 

journal持续到后备存储同步，每隔5s。默认情况下。10GB是该jouranl的常用的大小，但journal空间越大越好。Ceph使用journal综合考虑了存储速度和数据的一致性。journal允许CephOSD功能很快做小的写操作；一个随机写入首先写入在上一个连续类型的journal，然后刷新到文件系统。这给了文件系统足够的时间来合并写入磁盘。使用SSD盘作为journal盘能获得相对较好的性能。在这种情况下，所有的客户端写操作都写入到超高速SSD日志，然后刷新到磁盘。所以，一般情况下，使用SSD作为OSD的journal可以有效缓冲突发负载。与传统的分布式数据存储不同，RADOS最大的特点如下。

 

①将文件映射到Object后，利用Cluster Map通过CRUSH计算而不是查找表方式定位文件数据到存储设备中的位置。优化了传统的文件到块的映射和BlockMap管理。

②RADOS充分利用了OSD的智能特点，将部分任务授权给OSD，最大程度地实现可扩展。

 

2.3 RADIOS与LIBRADOS

LIBRADOS模块是客户端用来访问RADOS对象存储设备的。Ceph存储集群提供了消息传递层协议，用于客户端与Ceph Monitor与OSD交互，LIBRADOS以库形式为Ceph Client提供了这个功能，LIBRADOS就是操作RADOS对象存储的接口。所有Ceph客户端可以用LIBRADOS或LIBRADOS里封装的相同功能和对象存储交互，LIBRBD和LIBCEPHFS就利用了此功能。你可以用LIBRADOS直接和Ceph交互（如与Ceph兼容的应用程序、Ceph接口等）。下面是简单描述的步骤。

第1步：获取LIBRADOS。

第2步：配置集群句柄。

第3步：创建IO上下文。

第4步：关闭连接。

LIBRADOS架构图如下：

 ![img](https://img2018.cnblogs.com/blog/1754711/201908/1754711-20190824105326699-107107818.png)

 

 

先根据配置文件调用librados创建一个rados，接下来为这个rados创建一个radosclient，radosclient包含3个主要模块（finisher、Messager、Objector）。再根据pool创建对应的ioctx，在ioctx中能够找到radosclient。再调用osdc对生成对应osd请求，与OSD进行通信响应请求。

 

下面分别介绍LIBRADOS的C语言、Java语言和Py thon语言示例。

略

 =====================================================================================================================================================

3.1 引言 （还不完整，有点完善）

数据分布是分布式存储系统的一个重要部分，数据分布算法至少要考虑以下3个因素。

1）故障域隔离。同份数据的不同副本分布在不同的故障域，降低数据损坏的风险。

2）负载均衡。数据能够均匀地分布在磁盘容量不等的存储节点，避免部分节点空闲，部分节点超载，从而影响系统性能。

3）控制节点加入离开时引起的数据迁移量。当节点离开时，最优的数据迁移是只有离线节点上的数据被迁移到其他节点，而正常工作的节点的数据不会发生迁移。

 

对象存储中一致性Hash和Ceph的CRUSH算法是使用比较多的数据分布算法。在Aamzon的Dy anmo键值存储系统中采用一致性Hash算法，并且对它做了很多优化。OpenStack的Swift对象存储系统也使用了一致性Hash算法。

 

CRUSH（Controlled Replication Under Scalable Hashing）是一种基于伪随机控制数据分布、复制的算法。Ceph是为大规模分布式存储系统（PB级的数据和成百上千台存储设备）而设计的，在大规模的存储系统里，必须考虑数据的平衡分布和负载（提高资源利用率）、最大化系统的性能，以及系统的扩展和硬件容错等。CRUSH就是为解决以上问题而设计的。在Ceph集群里，CRUSH只需要一个简洁而层次清晰的设备描述，包括存储集群和副本放置策略，就可以有效地把数据对象映射到存储设备上，且这个过程是完全分布式的，在集群系统中的任何一方都可以独立计算任何对象的位置；另外，大型系统存储结构是动态变化的（存储节点的扩展或者缩容、硬件故障等），CRUSH能够处理存储设备的变更（添加或删除），并最小化由于存储设

备的变更而导致的数据迁移。

 

3.2 CRUSH基本原理

存储设备具有吞吐量限制，它影响读写性能和可扩展性能。所以，存储系统通

常都支持条带化以增加存储系统的吞吐量并提升性能，数据条带化最常见的方式是做RAID。

 

在磁盘阵列中，数据是以条带（stripe）的方式贯穿在磁盘阵列所有硬盘中的。这种数据的分配方式可以弥补OS读取数据量跟不上的不足。

1）将条带单元（stripe unit）从阵列的第一个硬盘到最后一个硬盘收集起来，就可以称为条带（stripe）。有的时候，条带单元也被称为交错深度。在光纤技术中，一个条带单元被叫作段。

 

2）数据在阵列中的硬盘上是以条带的形式分布的，条带化是指数据在阵列中所有硬盘中的存储过程。文件中的数据被分割成小块的数据段在阵列中的硬盘上顺序的存储，这个最小数据块就叫作条带单元。

 

决定Ceph条带化数据的3个因素。

·对象大小：处于分布式集群中的对象拥有一个最大可配置的尺寸（例如，2MB、4MB等），对象大小应该足够大以适应大量的条带单元。

 

·条带宽度：条带有一个可以配置的单元大小，Ceph Client端将数据写入对象分成相同大小的条带单元，除了最后一个条带之外；每个条带宽度，应该是对象大小的一小部分，这样使得一个对象可以包含多个条带单元。

 

·条带总量：Ceph客户端写入一系列的条带单元到一系列的对象，这就决定了条带的总量，这些对象被称为对象集，当Ceph客户端端写入的对象集合中的最后一个对象之后，它将会返回到对象集合中的第一个对象处。

 

​    总结：对象存储系统是把文件/数据作为对象来存储的，而条带是数据的载体，也就是说数据以条带的形式存储在磁盘阵列的所有磁盘中的。

 

 3.2.1 Object与PG

 

Ceph条带化之后，将获得N个带有唯一oid（即object的id）。Object id是进行线性映射生成

的，即由file的元数据、Ceph条带化产生的Object的序号连缀而成。此时Object需要映射到PG中，该映射包括两部分。

1）由Ceph集群指定的静态Hash函数计算Object的oid，获取到其Hash值。

2）将该Hash值与mask进行与操作，从而获得PG ID。

 

计算PG的ID示例如下。

1）Client输入pool ID和对象ID（如pool=‘liverpool’，object-id=‘john’）。

2）CRUSH获得对象ID并对其Hash运算。

3）CRUSH计算OSD个数，Hash取模获得PG的ID（如0x58）。

4）CRUSH获得已命名pool的ID（如liverpool=4）。

5）CRUSH预先考虑到pool ID相同的PG ID（如4.0x58）。