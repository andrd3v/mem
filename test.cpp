#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <cstring>

class game_manager {
public:
    int hp = 100;
    char name[16];

    void update_game() {
        hp = 52;
        strncpy(name, "andrdev", sizeof(name) - 1);
        name[sizeof(name) - 1] = '\0';

        printf("Gamer %s: hp = %d\n", name, hp);
        printf("Address of hp (local): %p\n", (void*)&hp);
        printf("Address of name (local): %p\n", (void*)&name);
    }
};

int main() {
    game_manager player;
    
    while (1) {
        printf("value hp: %d, address of player.hp: %p\n",player.hp ,(void*)&player.hp);
        sleep(1);
    }

    return 0;
}
