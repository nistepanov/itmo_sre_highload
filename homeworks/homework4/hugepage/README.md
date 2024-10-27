# Setup
1) Смотрим текущее кол-во huge pages 
```cat /proc/sys/vm/nr_hugepages```

2) Если свободных huge pages нет, зададим некоторое количество, например 5:
```echo 5 | sudo tee /proc/sys/vm/nr_hugepages```

3) Создаем директорию для монтирования huge pages:
```sudo mkdir /mnt/huge```

4) Монтируем huge pages
```sudo mount -t hugetlbfs nodev /mnt/huge```

# Создание программы
5) Теперь создадим C-программу, которая создаст файл, 
замаппит его на hugepage и запишет данные в этот файл.

6) Комплируем и запускаем программу 

# Проверка 
7) Проверяем размер файла, он должен занимать 2 мб
```ls -lh /mnt/huge/mymappedfile```

```-rwxrwxrwx 1 root root 2,0M Oct 26 19:08 mymappedfile```
8) Чтобы убедиться, что hugepages используются, можно проверить статистику в ```/proc```:
```cat /proc/meminfo | grep HugePages```
```
AnonHugePages:         0 kB
ShmemHugePages:   385024 kB
FileHugePages:         0 kB
HugePages_Total:       5
HugePages_Free:        4
HugePages_Rsvd:        0
HugePages_Surp:        0
```
9) Читаем содержимое файла
```cat /mnt/huge/myfile```
Ожидаем увидеть записанное ```HelloHugePages```
