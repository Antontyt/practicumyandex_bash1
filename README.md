\# sysinfo.sh



Учебный Bash-скрипт, который выводит сведения о хосте и пользователях Linux-системы. Аргументы разбираются через GNU `getopt`.



A teaching Bash script that prints host and user information on a Linux system. Options are parsed with GNU `getopt`.



\---



\## Русский



\### Требования



\- Bash 4+

\- GNU `getopt` (пакет util-linux)

\- Утилиты `awk`, `df`, `ip`, `ss`, `who`, `uptime`, `hostname`, `uname`

\- `dmesg` необязателен: без доступа к нему счётчик ошибок дисков выводится как `unavailable`



Проверено на WSL2 (Ubuntu). В WSL некоторые значения (uptime, load average) могут отличаться от обычного сервера.



\### Запуск



```bash

bash bash\_scripts/sysinfo.sh \[опции]

```



\### Опции



| Опция | Что выводит |

|---|---|

| `--host` | Информацию о хосте |

| `--user` | Информацию о пользователях |

| `--help` | Справку по опциям |



Без опций скрипт выводит справку, так же как `--help`. Опции можно комбинировать: `--host --user`. Неизвестная опция выдаёт ошибку и справку, код выхода 2.



\### Примеры



Справка:



```bash

bash bash\_scripts/sysinfo.sh

bash bash\_scripts/sysinfo.sh --help

```



Сведения о хосте:



```bash

bash bash\_scripts/sysinfo.sh --host

```



Фрагмент вывода (значения примерные):



```

=== Host information ===

Hostname: my-host

Kernel: 6.x.x-microsoft-standard-WSL2

Current time: 2026-10-24 13:22:33

Uptime: up 3 hours, 12 minutes

Load average: 0.10 0.05 0.01

CPU cores: 24

Memory total: 31623 MB

Memory available: 30655 MB

Memory used: 967 MB

Disks:

&#x20; /dev/sdd on /: size 1031018 MB, free 99%

Disk I/O errors (kernel log): 0

Network interfaces:

&#x20; eth0: state=up ip=172.30.78.190/20 rx\_packets=24 tx\_packets=38 errors(rx/tx)=0/0

Listening ports:

&#x20; tcp 127.0.0.53%lo:53

&#x20; udp 127.0.0.1:323

```



Сведения о пользователях:



```bash

bash bash\_scripts/sysinfo.sh --user

```



```

=== User information ===

All users:

&#x20; root

&#x20; daemon

&#x20; ...

Root users (UID 0):

&#x20; root

Logged-in users:

```



Оба раздела сразу:



```bash

bash bash\_scripts/sysinfo.sh --host --user

```



Ошибка при неверной опции:



```bash

bash bash\_scripts/sysinfo.sh --bogus; echo $?

\# выводит ошибку getopt и справку, затем: 2

```



\### Структура



\- функции `get\_\*` собирают данные

\- `print\_host\_info` и `print\_user\_info` форматируют вывод

\- `main` разбирает опции через `getopt`



\### Ограничения



\- Счётчик ошибок дисков берётся из строк `I/O error` в логе ядра. Это не SMART; для SMART нужны `smartctl` и root-права.

\- В WSL `Uptime` и `Load average` могут быть неточными.

\- Список залогиненных пользователей пуст, если нет активных сессий.



\---



\## English



\### Requirements



\- Bash 4+

\- GNU `getopt` (util-linux package)

\- `awk`, `df`, `ip`, `ss`, `who`, `uptime`, `hostname`, `uname`

\- `dmesg` is optional: without access to it, the disk error count is printed as `unavailable`



Tested on WSL2 (Ubuntu). In WSL some values (uptime, load average) may differ from a regular server.



\### Usage



```bash

bash bash\_scripts/sysinfo.sh \[options]

```



\### Options



| Option | Output |

|---|---|

| `--host` | Host information |

| `--user` | User information |

| `--help` | Option help |



With no options, the script prints the same help as `--help`. Options can be combined: `--host --user`. An unknown option prints an error and the help, exit code 2.



\### Examples



Help:



```bash

bash bash\_scripts/sysinfo.sh

bash bash\_scripts/sysinfo.sh --help

```



Host information:



```bash

bash bash\_scripts/sysinfo.sh --host

```



Sample output (values are illustrative):



```

=== Host information ===

Hostname: my-host

Kernel: 6.x.x-microsoft-standard-WSL2

Current time: 2026-10-24 13:22:33

Uptime: up 3 hours, 12 minutes

Load average: 0.10 0.05 0.01

CPU cores: 24

Memory total: 31623 MB

Memory available: 30655 MB

Memory used: 967 MB

Disks:

&#x20; /dev/sdd on /: size 1031018 MB, free 99%

Disk I/O errors (kernel log): 0

Network interfaces:

&#x20; eth0: state=up ip=172.30.78.190/20 rx\_packets=24 tx\_packets=38 errors(rx/tx)=0/0

Listening ports:

&#x20; tcp 127.0.0.53%lo:53

&#x20; udp 127.0.0.1:323

```



User information:



```bash

bash bash\_scripts/sysinfo.sh --user

```



```

=== User information ===

All users:

&#x20; root

&#x20; daemon

&#x20; ...

Root users (UID 0):

&#x20; root

Logged-in users:

```



Both sections at once:



```bash

bash bash\_scripts/sysinfo.sh --host --user

```



Invalid option:



```bash

bash bash\_scripts/sysinfo.sh --bogus; echo $?

\# prints a getopt error and the help, then: 2

```



\### Structure



\- `get\_\*` functions collect data

\- `print\_host\_info` and `print\_user\_info` format the output

\- `main` parses options with `getopt`



\### Limitations



\- The disk error count comes from `I/O error` lines in the kernel log. It is not SMART; SMART needs `smartctl` and root.

\- In WSL, `Uptime` and `Load average` may be inaccurate.

\- The logged-in user list is empty when there are no active sessions.



