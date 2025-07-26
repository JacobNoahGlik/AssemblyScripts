#include <stdio.h>
#include <stdbool.h>

void order(int* array, int size, bool descending);
void print_array(const char* prefix, const int* array, int size);

int main() {
    int array[] = {19, 4, 27, 11, 8};
    int size = sizeof(array) / sizeof(int);
    bool ascending = true, descending = false;
    print_array("Starting array: ", array, size);
    order(array, size, ascending);
    print_array("Ascending array: ", array, size);
    order(array, size, descending);
    print_array("Descending array: ", array, size);
}

void order(int* array, int size, bool ascending) {
    for (int i = 0; i < size - 1; ++i) {
        for (int j = i + 1; j < size; ++j) {
            if ( (ascending && array[i] > array[j]) || (!ascending && array[i] < array[j]) ) {
                int temp = array[j];
                array[j] = array[i];
                array[i] = temp;
            }
        }
    }
}

void print_array(const char* prefix, const int* array, int size) {
    printf("%s", prefix);
    int i = 0;
    for (; i < size - 1; ++i) {
        printf("%d, ", array[i]);
    }
    if (i == size - 1)
        printf("%d\n", array[i]);
}

