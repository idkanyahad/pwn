##____________if inside gdb_____________
set disassembly-flavor intel
break *main+798
commands
    silent
    x/gx $rbp-0x18
    continue
end
##source script.gdb -> run


## _____gdb -x script.gdb /challenge/embryogdb_level5_________
set disassembly-flavor intel
start
break *main+798
commands
    silent
    printf "%llx\n", *(unsigned long long *)($rbp-0x18)
    continue
end
continue
