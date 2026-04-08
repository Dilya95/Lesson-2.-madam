# Домашнее задание 2: работа с mdadm

## Задание
1. Добавить в виртуальную машину несколько дисков
2. Собрать RAID-0/1/5/10 на выбор
3. Сломать и починить RAID
4. Создать GPT таблицу, пять разделов и смонтировать их в системе.


## Выполнение

### 1. Добавила 4 диска в систему
```
root@otus-homework:~# lshw -short | grep disk
/0/100/4/0/0.0.0    /dev/sda   disk           17GB QEMU HARDDISK
/0/100/4/0/0.0.1    /dev/sdb   disk           21GB QEMU HARDDISK
/0/100/4/0/0.0.2    /dev/sdc   disk           21GB QEMU HARDDISK
/0/100/4/0/0.0.3    /dev/sdd   disk           21GB QEMU HARDDISK
/0/100/4/0/0.0.4    /dev/sde   disk           21GB QEMU HARDDISK
root@otus-homework:~# fdisk -l
Disk /dev/sda: 16 GiB, 17179869184 bytes, 33554432 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 6E24F2AC-01D7-453D-ADCE-24FAD12E6A74

Device      Start      End  Sectors  Size Type
/dev/sda1    2048     4095     2048    1M BIOS boot
/dev/sda2    4096   208895   204800  100M Linux filesystem
/dev/sda3  208896 33554398 33345503 15.9G Linux filesystem


Disk /dev/sdb: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

```

### 2 Создание RAID
#### 2.1 Занулила суперблоки
```
root@otus-homework:~# mdadm --zero-superblock --force /dev/sd{b,c,d,e}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
```

#### 2.2 Создала RAID-10
```
root@otus-homework:~# mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 20954112K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```


#### 2.3 Проверила, что RAID создался
```
root@otus-homework:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid4] [raid5] [raid6] [raid10] [linear] 
md0 : active raid10 sde[3] sdd[2] sdc[1] sdb[0]
      41908224 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      
unused devices: <none>
root@otus-homework:~# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Apr  8 13:49:09 2026
        Raid Level : raid10
        Array Size : 41908224 (39.97 GiB 42.91 GB)
     Used Dev Size : 20954112 (19.98 GiB 21.46 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Wed Apr  8 13:52:39 2026
             State : clean 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : otus-homework:0  (local to host otus-homework)
              UUID : 00f4380e:41192956:b40ece57:8186918d
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
```

### 3.1 Сломала RAID
```
root@otus-homework:~# mdadm /dev/md0 --remove /dev/sdc
mdadm: hot removed /dev/sdc from /dev/md0

root@otus-homework:~# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Apr  8 13:49:09 2026
        Raid Level : raid10
        Array Size : 41908224 (39.97 GiB 42.91 GB)
     Used Dev Size : 20954112 (19.98 GiB 21.46 GB)
      Raid Devices : 4
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Wed Apr  8 13:55:23 2026
             State : clean, degraded 
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : otus-homework:0  (local to host otus-homework)
              UUID : 00f4380e:41192956:b40ece57:8186918d
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       -       0        0        1      removed
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

```

### 3.2 Починила RAID
```
root@otus-homework:~# mdadm /dev/md0 --add /dev/sdc
mdadm: added /dev/sdc

root@otus-homework:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid4] [raid5] [raid6] [raid10] [linear] 
md0 : active raid10 sdc[4] sde[3] sdd[2] sdb[0]
      41908224 blocks super 1.2 512K chunks 2 near-copies [4/3] [U_UU]
      [=>...................]  recovery =  5.2% (1090816/20954112) finish=1.5min speed=218163K/sec
      
unused devices: <none>

root@otus-homework:~# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Apr  8 13:49:09 2026
        Raid Level : raid10
        Array Size : 41908224 (39.97 GiB 42.91 GB)
     Used Dev Size : 20954112 (19.98 GiB 21.46 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Wed Apr  8 13:56:10 2026
             State : clean, degraded, recovering 
    Active Devices : 3
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 1

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 9% complete

              Name : otus-homework:0  (local to host otus-homework)
              UUID : 00f4380e:41192956:b40ece57:8186918d
            Events : 23

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       4       8       32        1      spare rebuilding   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

```

### 3.3 Подождала пока завершится синхронизация
```
root@otus-homework:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid4] [raid5] [raid6] [raid10] [linear] 
md0 : active raid10 sdc[4] sde[3] sdd[2] sdb[0]
      41908224 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      
unused devices: <none>

```
