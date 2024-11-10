# Решение 

Написан скрипт ```my_docker.py```

Проверим работоспособность 

Запустим cpu-bound задачу, например очень быстрый ping 
```sudo python3.12 my_docker.py "ping 0.0.0.0 -i 0.02 -s 65507" --cpu 0.5 --mem 10M```

Посмотрим потребление процесса: ```top -p 18125```

```
    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                         
  18125 root      20   0    4552   1936   1760 R  50,3   0,0   0:14.16 ping       
```

Попробуем увеличить выделенный объем CPU:
```sudo python3.12 my_docker.py "ping 0.0.0.0 -i 0.02 -s 65507" --cpu 0.7 --mem 10M```

Посмотрим потребление процесса: ```top -p 18357```

```
    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                         
  18357 root      20   0    4552   1936   1760 R  69,3   0,0   0:14.16 ping       
```

Видим, что данный процесс действительно потребляет все выделенные ресурсы процесса
и эти ресурсы находятся в ожидаемых границах: 50% и 70% 

Проверить ограничение по CPU можно, выделив экстремально мало памяти, например 1Kb:
```
sudo python3.12 my_docker.py "echo 1" --cpu 0.7 --mem 1K
```
В таком случае вывод будет такой:
```
Using default tag: latest
latest: Pulling from library/almalinux
Digest: sha256:1c718a4cd7bab3bdb069ddbbd1eb593a390e6932d51d0048a2f6556303bafba7
Status: Image is up to date for almalinux:latest
docker.io/library/almalinux:latest
ee9edae5087166c8ddf02d325f072ee2c9618ea6cff610e3648f618e87b0012e
Killed
```

Видим, что программа была убита OOM киллером при попытке создания нейсмейсов из-за нехватки памяти