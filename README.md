# assembly-practice
This is a spot for me to share basic assembly projects to!

These are in NASM x86_64 Linux intel syntax.

If you're on x86_64 Linux (like me), and using NASM you can run these commands to execute assembly programs:

```
nasm -felf64 -test.asm -o test.o
ld test.o -o test.out
```

The nasm one asssembles test.asm with as a NASM file with unlinked variables; the ld command links them and outputs the test.out file.
