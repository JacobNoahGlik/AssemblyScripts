#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_SIZE 16

typedef struct Node {
    int value;
    struct Node* next;
} Node;

Node* head = NULL;

void add_node(Node** head_ptr, int value);
void print_list(Node* node);
void request_numbers_from_user(Node** head_ptr);

int main() {
    request_numbers_from_user(&head);

    printf("Linked list values: ");
    print_list(head);

    // cleanup
    Node* current = head;
    while (current != NULL) {
        Node* next = current->next;
        free(current);
        current = next;
    }

    return 0;
}

void add_node(Node** head_ptr, int value) {
    Node* new_node = (Node*)malloc(sizeof(Node));
    if (!new_node) {
        fprintf(stderr, "Memory allocation failed.\n");
        return;
    }

    new_node->value = value;
    new_node->next = NULL;

    if (*head_ptr == NULL) {
        *head_ptr = new_node;
        return;
    }

    Node* current = *head_ptr;
    while (current->next != NULL) {
        current = current->next;
    }

    current->next = new_node;
}

void print_list(Node* node) {
    while (node != NULL) {
        printf("%d ", node->value);
        node = node->next;
    }
    printf("\n");
}

void request_numbers_from_user(Node** head_ptr) {
    char input_buffer[BUFFER_SIZE];

    while (1) {
        printf("Enter a number (or press Enter to finish): ");
        if (!fgets(input_buffer, sizeof(input_buffer), stdin)) {
            break; // EOF
        }
        if (input_buffer[0] == '\n') {
            break;
        }
        input_buffer[strcspn(input_buffer, "\n")] = 0;

        int value = 0;
        for (char* p = input_buffer; *p; p++) {
            if (*p < '0' || *p > '9') {
                printf("Invalid input, skipping.\n");
                value = -1;
                break;
            }
            value = value * 10 + (*p - '0');
        }

        if (value >= 0) {
            add_node(head_ptr, value);
        }
    }
}
