#include "mem_utils.h"
 
 int main(int argc, char *argv[])
 {
     const char* my_bin = "test";
     pid_t pid = get_pid_by_name_of_proc_bin_andr(my_bin);
     
     if (pid > 0)
     {
         printf("[*] pid of %s = %d\n", my_bin, pid);
     } else {
         printf("[*] Process '%s' not found.\n", my_bin);
         exit(0);
     }
     
     
     mach_port_t port_pid_1 = get_task_for_pid(pid);
     if (port_pid_1 != MACH_PORT_NULL)
     {
       printf("[!] mach port for pid %d = %d\n", pid, port_pid_1);
     } else {
       printf("[!] mach port not found.");
     }

     
     mach_port_t port_pid_2 = get_task_by_pid(pid);
     if (port_pid_2 != MACH_PORT_NULL)
     {
       printf("[!] mach port for pid %d = %d  [analog by Lavka]\n", pid, port_pid_2);
     } else {
       printf("[!] mach port not found.");
     }

     
     vm_map_offset_t base_addr = get_base_address(port_pid_1);
     if (base_addr == 0)
     {
       printf("[-] get base_addr failed.\n");
     } else {
       printf("[+] Base address: 0x%016llX\n", base_addr);
     }
     
     
     

     // if need, use base_addr + addr to get addr
     // i use addr, which whrite my test program
     
     
     
     char input_addr[64];
     printf("Enter the address (in 0x format): ");
     fgets(input_addr, sizeof(input_addr), stdin);
     input_addr[strcspn(input_addr, "\n")] = 0;
     vm_address_t user_addr = strtoull(input_addr, NULL, 16);
     printf("You entered address: 0x%016llX\n", user_addr);
     
     
     
     
     int *value = (int *)read_value(port_pid_1, user_addr, sizeof(int));
     if (value) {
       printf("Value of addr: %d\n", *value);
     free(value);
     } else {
       printf("Error read.\n");
     }
     
     
     
     int new_value = 123;
     kern_return_t kr = write_value(port_pid_1, user_addr, &new_value, sizeof(int));
     if (kr == KERN_SUCCESS) {
         printf("Succes write value to addr.\n");
     } else {
         printf("Error: %d\n", kr);
     }

     
     int *n_value = (int *)read_value(port_pid_1, user_addr, sizeof(int));
     if (n_value) {
       printf("[NEW] value of addr: %d\n", *value);
     free(n_value);
     } else {
       printf("Error read.\n");
     }

     return EXIT_SUCCESS;
 }
