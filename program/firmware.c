#include <stdint.h>
#include <stdio.h>

int counter = 25;

int main(void) {
  for (int i = 0; i < 100; i++) {
    counter += i;
  }

  printf("Counter value (Decimal): %d\n", counter);
  printf("Counter value (Hex): %X\n", counter);

  return 0;
}