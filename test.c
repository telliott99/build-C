#include <stdio.h>

int f1(int);

int f1(int x){
    printf( "f1: %d;", x );
        return x+1;
}

int main(int argc, char** argv){
    printf("test:\n");
    printf("  main %d\n", f1(1));
    return 0;
}
