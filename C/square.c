#include <stdio.h>

int square(int n);
int input(const char* prompt);

int main() {
    int number = input("Enter a number to square: ");
    int result = square(number);
    printf("%d squared = %d\n", number, result);
    return 0;
}

int square(int n) {
    return n * n;
}

int input(const char* prompt) {
    int value;
    printf("%s", prompt);
    scanf("%d", &value);
    return value;
}