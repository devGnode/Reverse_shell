# Reverse_shell learning

## :one: Reverse Shell x86 :fr:

Warning, this reverse shell is not portable, just for show example how does a reverse shell in x86 in assembly code, this method is really old

* reverse_bind_cpp 
* reverse_bin_cpp_v2
  - try to catch ipv4 address of ethernet card
* cpp ( reverse shell cpp )
* v1 ( reverse shell asm )
  - Replace all address offsets of called functions
* v2 ( reverse shell asm )
  - To do remote all TEB/PEB, remove all bytes null
  - Ligne 78 v2 : LoadLibraryA replace it by your own offset
  - Ligne 79 v2 : GetProcAddress replace it by your own offset
  - Ligne 193 v2: SOKADDR_IN set you own port and IP address

### Architecture

Win32 plateform

- XP 
- Win 7
- Win 10 - Windows Defender Detects it's bad for himself

### Compilation 

```
$nasm -f win32 reverse_shell.s -o reverse_shell.o
$ld -m i386 reverse_shell.o -o reverse_shell32.exe
```
### Show Hex

```
$nasm -f bin reverse_shell.s -o reverse_shell_bin.o
$cat reverse_shell_bin | hexdump -C
```
## :two: Exploit

### Reverse Tcp

```
$netcat -v -l -p 4444
```

### Reverse Bind Tcp

```
$netcat -v victim_ip 4444
```

### Reverse Tcp With CPP 

Write on an ide really basic devcpp on windows

- Inlude at your projet : MinGw-x86-64\libws2_32.so

<img src="https://zupimages.net/up/18/52/3s63.png">
<img src="https://zupimages.net/up/18/52/y6mk.png">

### Win 10 pro reverse cpp

<img src="https://zupimages.net/up/18/52/ztqp.png">
<img src="https://zupimages.net/up/18/52/dt6r.png">
<img src="https://zupimages.net/up/18/52/a96f.png">


