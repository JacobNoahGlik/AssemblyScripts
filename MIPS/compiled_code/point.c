#include <stdio.h>
#include <stdlib.h>

struct point {
    int x;
    int y;
};
typedef struct point Point;

Point* new_point(int x, int y);
void display_point(const Point* point);
void free_point(Point* point);

int main() {
    Point* origin = new_point(0, 0);
    display_point(origin);
    free_point(origin);
    return 0;
}

Point* new_point(int x, int y) {
    Point* temp = (Point*)malloc(sizeof(Point));
    temp->x = x;
    temp->y = y;
    return temp;
}

void display_point(const Point* point) {
    printf("Point(%d, %d)\n", point->x, point->y);
}

void free_point(Point* point) {
    free(point);
}