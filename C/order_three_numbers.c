#include <stdio.h>

void order_numbers(int* a, int* b, int* c);

int main() {
    int a = 19, b = 27, c = 4;
    printf("Values are: %d, %d, %d\n", a, b, c);
    order_numbers(&a, &b, &c);
    printf("Ordered values are: %d, %d, %d\n", a, b, c);
}

void order_numbers(int* a, int* b, int* c) {
    if (*a < *b) {
        int temp = *b;
        *b = *a;
        *a = temp;
    }
    if (*b < *c) {
        int temp = *c;
        *c = *b;
        *b = temp;
    }
    if (*a < *b) {
        int temp = *b;
        *b = *a;
        *a = temp;
    }
}