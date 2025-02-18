#include <stdio.h>
#include <string.h>

#define SECRET "OpenSesame"
#define FLAG "FLAG{You_Got_It}"

int main() {
    char input[50];

    // Disable buffering for stdout
    setvbuf(stdout, NULL, _IONBF, 0);
    
    printf("Enter the secret code: ");
    scanf("%49s", input);
    
    if (strcmp(input, SECRET) == 0) {
        printf("Correct! Here is your flag: %s\n", FLAG);
    } else {
        printf("Incorrect code!\n");
    }
    
    return 0;
}