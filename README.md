# Reverse_shell

## :one: Reverse Shell x86 :fr:

Warning, this reverse shell is not portable, just for show example how does a reverse shell in x86 in assembly code, this method is really old

- Ligne 78 v2 : LoadLibraryA
- Ligne 79 v2 : GetProcAddress
- Ligne 193 v2: SOKADDR_IN

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

<img src="https://zupimages.net/up/18/52/3s63.png">
<img src="https://zupimages.net/up/18/52/y6mk.png">
