1) Создадим тестовые диски
```
sudo fallocate -l 1G /mnt/disk1.img
sudo fallocate -l 1G /mnt/disk2.img
sudo fallocate -l 1G /mnt/disk3.img
```
2) Отформатируем 
```
sudo losetup /dev/loop0 /mnt/disk1.img
sudo losetup /dev/loop1 /mnt/disk2.img
sudo losetup /dev/loop2 /mnt/disk3.img
```
3) Создаем RAID массив
```
sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/loop0 /dev/loop1
```

4) Проверяем статус:
```сat /proc/mdstat```
```
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid1 loop1[1] loop0[0]
      1046528 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
```
5) Смотрим подробное состояние:
```sudo mdadm --detail /dev/md0```
```
/dev/md0:
           Version : 1.2
     Creation Time : Sat Oct 26 20:52:41 2024
        Raid Level : raid1
        Array Size : 1046528 (1022.00 MiB 1071.64 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Sat Oct 26 20:52:46 2024
             State : clean 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : nistepanov:0  (local to host nistepanov)
              UUID : 0c1ff588:36bde97e:4dae86d9:228dee7a
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       7        0        0      active sync   /dev/loop0
       1       7        1        1      active sync   /dev/loop1
```

6) Добавляем hot spare диск (резервный)
```
sudo mdadm --manage /dev/md0 --add-spare /dev/loop2
```

7) Ломаем один из дисков
```sudo mdadm --manage /dev/md0 --fail /dev/loop0```

8) Вновь смотрим состояние, заметно, что loop0 сломан и начат процесс восстановления
```
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid1 loop1[4] loop0[3](F) loop2[2]
      1046528 blocks super 1.2 [2/1] [U_]
      [===============>.....]  recovery = 76.5% (801920/1046528) finish=0.0min speed=267306K/sec
      
unused devices: <none>
```
9) Спустя время все в порядке и система восстановлена ```cat /proc/mdstat```:
```
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid1 loop1[4] loop0[3](F) loop2[2]
      1046528 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
```