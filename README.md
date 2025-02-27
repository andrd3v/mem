# Read and write external IOS and mac OS X

This tool allows you to interact with the memory of running processes on iOS or mac OS X. It is designed to work with the macOS and iOS environment, enabling the reading and writing of memory values within processes.

## Features
- Retrieve the PID of a process by its binary name.
- Access a task port associated with a process, either through get_task_for_pid or an alternative method (get_task_by_pid).
- Get the base address of a process’s memory.
- Read and write values at specified memory addresses within a process’s memory space.


## How to Use

- Permissions: The tool requires access to the task ports of processes. This may require root privileges (run with sudo ./program)


## Usage

Run the test program
```bash
cd memory

#compile
clang++ test.cpp -o test
#OR
g++ test.cpp -o test

#run
./test
```

Run the mem program
```bash
cd memory
cd mem

#compile
make

#run
sudo ./mem
```


test write addr of player hp
```bash
❯ ./test
value hp: 100, address of player.hp: 0x16ce9ef58
value hp: 100, address of player.hp: 0x16ce9ef58
value hp: 100, address of player.hp: 0x16ce9ef58
```

in mem program enter addr of player hp
```bash
❯ sudo ./mem
[*] pid of test = 55153
[!] mach port for pid 55153 = 2563
[!] mach port for pid 55153 = 2563  [analog by Lavka]
[+] Base address: 0x0000000102F60000
Enter the address (in 0x format): 0x16ce9ef58
```

click enter and see result
```bash
❯ sudo ./mem
[*] pid of test = 55153
[!] mach port for pid 55153 = 2563
[!] mach port for pid 55153 = 2563  [analog by Lavka]
[+] Base address: 0x0000000102F60000
Enter the address (in 0x format): 0x16ce9ef58
You entered address: 0x000000016CE9EF58
Value of addr: 100 # [!] we can read value [!]
Succes write value to addr. # [!] we can write value [!]
[NEW] value of addr: 123 # <--- new value
```

check test program (value of hp changed)
```bash
value hp: 100, address of player.hp: 0x16ce9ef58
value hp: 100, address of player.hp: 0x16ce9ef58
value hp: 100, address of player.hp: 0x16ce9ef58
value hp: 100, address of player.hp: 0x16ce9ef58
value hp: 123, address of player.hp: 0x16ce9ef58
value hp: 123, address of player.hp: 0x16ce9ef58
value hp: 123, address of player.hp: 0x16ce9ef58
value hp: 123, address of player.hp: 0x16ce9ef58
value hp: 123, address of player.hp: 0x16ce9ef58
value hp: 123, address of player.hp: 0x16ce9ef58
```

## Important Notes:

- Memory Leaks: When using functions like mach_vm_read or vm_read, it’s important to manage memory correctly to avoid leaks. Ensure that you call vm_deallocate where necessary.
- Error Handling: The program provides basic error handling for failed operations (e.g., failed to read or write memory, unable to find task port).
- Compatibility: This tool is designed specifically for macOS and iOS environments. It relies on libsystem_kernel.dylib for certain system calls like mach_vm_read_overwrite and mach_vm_write. (On iOS)

Please, if you use iOS, this work only with sudo, you need jailbreak or TrollStore or etc... When you sign ipa, add ent.plist for entitlements.
In ent.plist change com.andrdev.XXX to your bundleID.

#### add in Makefile (for your app, with theos): 
```Makefile
ifeq ($(TARGET_CODESIGN),ldid)
YOURAPP_CODESIGN_FLAGS += -Sent.plist
else
YOURAPP_CODESIGN_FLAGS += --entitlements ent.plist $(TARGET_CODESIGN_FLAGS)
endif
```



## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Warning!

The `get_task_by_pid` function requires `root` permissions even on iOS.

Even if you set `com.apple.security.get-task-allow` (and etc...) in `entitlements.plist`, iOS will still not allow access to someone else's process.

## Credits

- Code by: andrdev (https://t.me/andrdevv)
- Function get_task_by_pid (analog get_task_for_pid) inspired by: Jonathan Levin (https://newosxbook.com/articles/PST2.html)  – the idea for use func.

## License
Feel free to use and modify this code for educational and research purposes. Please ensure that you have the proper permissions and adhere to relevant laws when using this tool.

[MIT](https://choosealicense.com/licenses/mit/)
