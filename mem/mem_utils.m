#include "mem_utils.h"
#include <Foundation/Foundation.h>

/*
 
   *   Import functions for work with memory on IOS (only in libsystem_kernel.dylib)
   *   Imports from /usr/lib/system/libsystem_kernel.dylib
 
*/

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#include <sys/sysctl.h>
#include <sys/types.h>

/*
 
   * if you use mach_vm_read or vm_read, check memory, it is important to avoid memory leaks.
   * Use vm_deallocate to fix leaks memory.
   *
   * ---------------- OR -----------------
   *
   * Use mach_vm_read_overwrite instead.
 
*/

extern kern_return_t
vm_read(
        vm_map_read_t target_task,
        vm_address_t address,
        vm_size_t size,
        vm_offset_t *data,
        mach_msg_type_number_t *dataCnt
        );

extern kern_return_t
mach_vm_read_overwrite(
                       vm_map_t           target_task,
                       mach_vm_address_t  address,
                       mach_vm_size_t     size,
                       mach_vm_address_t  data,
                       mach_vm_size_t     *outsize);


extern kern_return_t
mach_vm_write(
              vm_map_t                          map,
              mach_vm_address_t                 address,
              pointer_t                         data,
              __unused mach_msg_type_number_t   size);

extern kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);

extern kern_return_t
processor_set_default(
                      host_t host,
                      processor_set_name_t *default_set
                      );

extern kern_return_t
host_processor_set_priv(
                        host_priv_t host_priv,
                        processor_set_name_t set_name,
                        processor_set_t *set
                        );

extern kern_return_t
processor_set_tasks(
                    processor_set_t processor_set,
                    task_array_t *task_list,
                    mach_msg_type_number_t *task_listCnt
                    );

extern kern_return_t pid_for_task(task_t task, int *pid);

extern kern_return_t
task_info(
          task_name_t target_task,
          task_flavor_t flavor,
          task_info_t task_info_out,
          mach_msg_type_number_t *task_info_outCnt
          );

extern host_name_port_t mach_host_self();

#else
#include <mach/mach_vm.h>
#include <mach-o/dyld_images.h>
#include <libproc.h>
#endif


#if !TARGET_OS_IPHONE && !TARGET_OS_IOS && !TARGET_OS_TV && !TARGET_OS_WATCH && !TARGET_IPHONE_SIMULATOR
pid_t get_pid_by_name_of_proc_bin_andr(const char* name_of_bin)
{
    int pids[1024]; 
    int pids_counter = proc_listallpids(pids, sizeof(pids));
    
    if (pids_counter < 0) {
        perror("Error getting process list");
        return -1;
    }

    for (int i = 0; i < pids_counter / sizeof(pid_t); i++) 
    {
        char name[PROC_PIDPATHINFO_MAXSIZE];
        
        if (proc_pidpath(pids[i], name, sizeof(name)) > 0)
        {
            const char* bin_name = strrchr(name, '/');
            if (bin_name) bin_name++; else bin_name = name;

           
            if (strstr(bin_name, name_of_bin) != NULL)
            {
                return pids[i];
            }
        }
    }

    return -1; 
}
#endif // !TARGET_OS_IPHONE && !TARGET_OS_IOS && !TARGET_OS_TV && !TARGET_OS_WATCH && !TARGET_IPHONE_SIMULATOR


#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
pid_t get_pid_by_name_of_proc_bin_andr(const char* name_of_bin)
{
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size = 0;

    if (sysctl(mib, 4, NULL, &size, NULL, 0) == -1) {
        perror("sysctl: getting process list size failed");
        return -1;
    }

    struct kinfo_proc* process_list = (struct kinfo_proc*)malloc(size);
    if (!process_list) {
        perror("malloc failed");
        return -1;
    }

    if (sysctl(mib, 4, process_list, &size, NULL, 0) == -1) {
        perror("sysctl: getting process list failed");
        free(process_list);
        return -1;
    }

    size_t process_count = size / sizeof(struct kinfo_proc);
    pid_t result_pid = -1;

    for (size_t i = 0; i < process_count; i++) {
        if (strcmp(process_list[i].kp_proc.p_comm, name_of_bin) == 0) {
            result_pid = process_list[i].kp_proc.p_pid;
            break;
        }
    }

    free(process_list);
    return result_pid;
    
}
#endif // TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

task_t get_task_for_pid(pid_t pid)
{
    mach_port_t task;
    kern_return_t kr = task_for_pid(mach_task_self(), pid, &task);
    if (kr == KERN_SUCCESS) {
        return task;
    }
    
    return MACH_PORT_NULL;
}


/*

   * Thanks for Jonathan Levin to this idea for use func https://newosxbook.com/articles/PST2.html
   * get_task_by_pid is analog for get_task_for_pid
   * maybe now the functions are the same, initially they were different, i decided to leave 2
*/

#if !TARGET_OS_IPHONE && !TARGET_OS_IOS && !TARGET_OS_TV && !TARGET_OS_WATCH && !TARGET_IPHONE_SIMULATOR
task_t get_task_by_pid(pid_t pid)
{
    task_port_t psDefault;
    task_port_t psDefault_control;

    task_array_t tasks;
    mach_msg_type_number_t numTasks;
    kern_return_t kr;

   
    host_t self_host = mach_host_self();
    kr = processor_set_default(self_host, &psDefault);
    if (kr != KERN_SUCCESS)
    {
        fprintf(stderr, "Error in processor_set_default: %x\n", kr);
        return MACH_PORT_NULL;
    }

   
    kr = host_processor_set_priv(self_host, psDefault, &psDefault_control);
    if (kr != KERN_SUCCESS)
    {
        fprintf(stderr, "Error in host_processor_set_priv: %x\n", kr);
        return MACH_PORT_NULL;
    }

  
    kr = processor_set_tasks(psDefault_control, &tasks, &numTasks);
    if (kr != KERN_SUCCESS) {
        fprintf(stderr, "Error in processor_set_tasks: %x\n", kr);
        return MACH_PORT_NULL;
    }

  
    for (int i = 0; i < numTasks; i++)
    {
        int task_pid;
        kr = pid_for_task(tasks[i], &task_pid);
        if (kr != KERN_SUCCESS) {
            continue;
        }

        if (task_pid == pid) return tasks[i];
    }

    return MACH_PORT_NULL;
}
#endif // !TARGET_OS_IPHONE && !TARGET_OS_IOS && !TARGET_OS_TV && !TARGET_OS_WATCH && !TARGET_IPHONE_SIMULATOR

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
task_t get_task_by_pid(pid_t pid)
{
    task_port_t psDefault;
    task_port_t psDefault_control;

    task_array_t tasks;
    mach_msg_type_number_t numTasks;
    kern_return_t kr;

   
    host_t self_host = mach_host_self();
    kr = processor_set_default(self_host, &psDefault);
    if (kr != KERN_SUCCESS)
    {
        fprintf(stderr, "Error in processor_set_default: %x\n", kr);
        return MACH_PORT_NULL;
    }

   
    kr = host_processor_set_priv(self_host, psDefault, &psDefault_control);
    if (kr != KERN_SUCCESS)
    {
        fprintf(stderr, "Error in host_processor_set_priv: %x\n", kr);
        return MACH_PORT_NULL;
    }

  
    kr = processor_set_tasks(psDefault_control, &tasks, &numTasks);
    if (kr != KERN_SUCCESS) {
        fprintf(stderr, "Error in processor_set_tasks: %x\n", kr);
        return MACH_PORT_NULL;
    }

  
    for (int i = 0; i < numTasks; i++)
    {
        int task_pid;
        kr = pid_for_task(tasks[i], &task_pid);
        if (kr != KERN_SUCCESS) {
            continue;
        }

        if (task_pid == pid) return tasks[i];
    }

    return MACH_PORT_NULL;
}
#endif // TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR


vm_map_offset_t get_base_address(mach_port_t task)
{
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t depth = 0;

    struct vm_region_submap_info_64 info;
    mach_msg_type_number_t info_count = 16;

    kern_return_t kr = mach_vm_region_recurse(
        task, &vmoffset, 
        &vmsize, &depth,
        (vm_region_recurse_info_t)&info, &info_count
    );


    if (kr != KERN_SUCCESS) {
        fprintf(stderr, "[-] get base_addres failed.\n");
        return 0;
    }

    return vmoffset;
}

void *read_value(mach_port_t task, mach_vm_offset_t offset, size_t size)
{
    if (size == 0) return NULL;

    void *buffer = malloc(size);
    if (!buffer) return NULL;

    mach_vm_size_t read_size = 0;
    kern_return_t kr = mach_vm_read_overwrite(task, offset, size, (mach_vm_address_t)buffer, &read_size);
    
    if (kr != KERN_SUCCESS || read_size != size) {
        free(buffer);
        return NULL;
    }

    return buffer;
}

kern_return_t write_value(mach_port_t task, mach_vm_offset_t offset, const void *value, size_t size)
{
    if (size == 0 || value == NULL) return KERN_INVALID_ARGUMENT;

    kern_return_t kr = mach_vm_write(task, offset, (mach_vm_address_t)value, size);
    if (kr != KERN_SUCCESS) {
        return kr;
    }

    return KERN_SUCCESS;
}
