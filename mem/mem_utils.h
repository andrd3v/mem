#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/sysctl.h>
#include <mach/mach.h>

pid_t get_pid_by_name_of_proc_bin_andr(const char* name_of_bin);
task_t get_task_for_pid(pid_t pid);


// analog for get_task_for_pid https://newosxbook.com/articles/PST2.html,
// idea to use: Lavka (Telegram: https://t.me/wallhack_cheat)

task_t get_task_by_pid(pid_t pid);

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------


vm_map_offset_t get_base_address(mach_port_t task);

void *read_value(mach_port_t task, mach_vm_offset_t offset, size_t size);
kern_return_t write_value(
                          mach_port_t task,
                          mach_vm_offset_t offset,
                          const void *value,
                          size_t size
                        );
