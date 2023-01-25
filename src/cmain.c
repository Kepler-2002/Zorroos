#include <stddef.h> 

size_t puts(char const *); 

size_t to_string(char *ptr, size_t len, int value) {
    char buffer[10]; 
    size_t local_len = 10; 
    size_t ans;
    while (value) {
        int mod = value % 10; 
        value /= 10; 
        buffer[local_len - 1] = '0' + mod; 
        local_len -= 1; 
    }
    if (11 - local_len < len) {
        ans = 11 - local_len; 
        int j = 0; 
        int i = local_len; 
        for (; i < 10; ) {
            ptr[j] = buffer[i]; 
            ++j; ++i; 
        }
        ptr[j] = '\0'; 
    } else {
        ans = 0; 
    }
    return ans; 
}

int cmain() {
    puts("\x1b[33;1mC Lang Start: \x1b[0m\n"); 
    void const *ptr = cmain; 
    char buffer[128]; 
    // snprintf(buffer, sizeof buffer, "The addr: %ld\n", (unsigned long ) ptr); 
    to_string(buffer, sizeof buffer, (unsigned int )(unsigned long ) ptr); 
    puts(buffer); 
    return 2; 
}