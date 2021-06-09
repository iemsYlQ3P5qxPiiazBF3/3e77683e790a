```
instruction set:
00: pointer+1
01: pointer-1
0A: compare [tape@pointer] to [hex], if equal, [hex@tape] = 0, else, [hex@tape] = 1
0D: write 2 bytes
0E: source file (name has to be hex, 4 characters 0000-FFFF)
0F: source file 00-FF
10: print tape as hex
11: [tape@pointer] = truly random (/dev/urandom) mod [hex]
12: exit
13: source [hex[1]] if [tape@pointer] = 0, else source [hex[2]]
14: save [pointer]
15: load [pointer]
17: save [tape]
18: load [tape]
19: read input to [tape@pointer]
1A: if [tape@hex[1]] = [tape@hex[2]], then [tape@pointer] = 0, else, [tape@pointer] = 1
1B: invert [tape@pointer] (xor 1)
1C: save [tape@pointer] (not like 14, 15, 17, 18)
1D: load [tape@pointer]
1F: print tape and pointer
20-28: math (xor, and, or, exponenet, modulo)
2A: set pointer to 0
2B: source file until [tape@pointe] is 0


useless instructions:
63: print 99 bottles of beer
16: print "Hello, World!"
29: do nothing (NOP)

sourcing files require they are named in hexadecimal
doing `0F<own file name>` will recurse or something, would not do
padding (unused bytes) can be any value
comments can be done with the unuses 29 args, extra args of commands, or as a command not listed as long as it is not a command (`63`, `20-28`, `2A`, `2B`)
```
