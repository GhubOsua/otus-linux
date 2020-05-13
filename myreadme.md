1. Добавил config.vm.synced_folder ".", "/vagrant", type: "virtualbox" 
2. Обновил yum update
3. Установил yum install mdadm
4. Добавил disk 5.
5. Выполнил все действия ,которые указаны в методичке.
Файл script_raid.sh это скрипт
Файл mdadm.conf это конфигурация собраного Raid
Файл Vagrantfile это виртуалка

Вывод команд для raid:
1. [vagrant@otuslinux ~]$ sudo mdadm -D /dev/md*
mdadm: /dev/md does not appear to be an md device
/dev/md0:
           Version : 1.2
     Creation Time : Tue May 12 11:16:32 2020
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Tue May 12 11:16:46 2020
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 0a121be3:015f9c2b:5778d998:65cb85d0
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf

2. [vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdd[2] sdf[5] sdb[0] sdc[1] sde[3]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>

3. sudo blkid
/dev/sda1: UUID="8ac075e3-1124-4bb6-bef7-a6811bf8b870" TYPE="xfs" 
/dev/sdb: UUID="0a121be3-015f-9c2b-5778-d99865cb85d0" UUID_SUB="8bb51983-d0b3-e0f2-74a5-09671d93e9ee" LABEL="otuslinux:0" TYPE="linux_raid_member" 
/dev/sdc: UUID="0a121be3-015f-9c2b-5778-d99865cb85d0" UUID_SUB="70e9a4a6-23e0-9a31-e6ae-2ff674e2cd6a" LABEL="otuslinux:0" TYPE="linux_raid_member" 
/dev/sde: UUID="0a121be3-015f-9c2b-5778-d99865cb85d0" UUID_SUB="73b801fe-7363-a0b8-198d-8bb55173c6d4" LABEL="otuslinux:0" TYPE="linux_raid_member" 
/dev/sdf: UUID="0a121be3-015f-9c2b-5778-d99865cb85d0" UUID_SUB="af656b2f-d574-920b-cc8b-f070b6b8af6b" LABEL="otuslinux:0" TYPE="linux_raid_member" 
/dev/sdd: UUID="0a121be3-015f-9c2b-5778-d99865cb85d0" UUID_SUB="5789203d-6803-28a2-6c21-f93404f94df2" LABEL="otuslinux:0" TYPE="linux_raid_member" 

Поломка RAID и вывод команд:
1. Указываем что у нас диск sdf сломан
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 -f /dev/sdf 
mdadm: set /dev/sdf faulty in /dev/md0
2. Смотрим статус raid
md0 : active raid5 sdd[2] sdf[5](F) sdb[0] sdc[1] sde[3]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
3. Удаляем сломанный диск из массива
vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sdf
mdadm: hot removed /dev/sdf from /dev/md0
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdd[2] sdb[0] sdc[1] sde[3]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
      
unused devices: <none>
4. Теперь, мы добавляем работающий диск в raid
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sdf
mdadm: added /dev/sdf
5. Вывод сборки raid
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sdd[2] sdb[0] sdc[1] sde[3]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
      [=================>...]  recovery = 85.7% (218112/253952) finish=0.0min speed=21811K/sec
      
unused devices: <none>
6. Вывод собранного диска
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sdd[2] sdb[0] sdc[1] sde[3]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
      [=================>...]  recovery = 85.7% (218112/253952) finish=0.0min speed=21811K/sec
      
unused devices: <none>

