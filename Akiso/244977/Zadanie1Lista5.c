#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define STDOUT 1
#define STDIN 0
#define MAX_LENGTH 255

// This function convert integers into strings using base.
char *changeBase(int number, int base, bool sign) {
  static char characters[] = "0123456789ABSCEF";
  static char table[255];
  char *pointer = &table[254];
  *pointer = '\0';
  pointer--;
  while (number != 0) {
    *pointer = characters[number%base];
    number = number / base;
    pointer--;
  }
  if (sign) {
    *pointer = '-';
  } else {
    pointer++;
  }
  return pointer;
}


int fromString(char* number, int base) {
  int final = -123456789;
  int length = strlen(number) - 1;
  int start = 0;
  bool sign = false;
  if (number[0] == '-') {
    start = 1;
    sign = true;
  }
  if (length > 0) {
    if (number[start] >= 'A' && number[start] <= 'F' ) {
      final = number[start] - 55;
    } else {
      final = number[start] - '0';
    }
    for (int i = start + 1; i < length; i++) {
      if (number[i] >= 'A' && number[i] <= 'F' ) {
        final = final*base + number[i] - 55;
      } else {
        final = final*base + number[i] - '0';
      }
    }
  }

  if (sign) {
    final = -final;
  }
  return final;
}

void myprintf(char* message, ...) {
  char *pointer;
  char *p = (char *) &message + sizeof message;

  for(pointer = message; *pointer != '\0'; pointer++) {
    if (*pointer != '%') {
      write(STDOUT, pointer, sizeof(char));
    } else {
      pointer++;
      switch (*pointer) {
        case 's': {
          char *str = *((char **) p);
          p = p + sizeof(*str);
          while (*str != '\0') {
            write(STDOUT, str, 1);
            str++;
          }
          break;
        }
        case 'd':{
          int number = *((int *) p);
          bool sign = false;
          if (number < 0) {
            number = -number;
            sign = true;
          }
          p = p + sizeof(number);
          char *converted = changeBase(number, 10, sign);
          while (*converted != '\0') {
            write(STDOUT, converted, 1);
            converted++;
          }
          break;
        }
        case 'x': {
          int number = *((int *) p);
          bool sign = false;
          if (number < 0) {
            number = -number;
            sign = true;
          }
          p = p + sizeof(number);
          char *converted = changeBase(number, 16, sign);
          while (*converted != '\0') {
            write(STDOUT, converted, 1);
            converted++;
          }
          break;
        }
        case 'b': {
          int number = *((int *) p);
          bool sign = false;
          if (number < 0) {
            number = -number;
            sign = true;
          }
          p = p + sizeof(number);
          char *converted = changeBase(number, 2, sign);
          while (*converted != '\0') {
            write(STDOUT, converted, 1);
            converted++;
          }
          break;
        }
      }
    }
  }
  p = NULL;
}

void myscanf(char *message, ...) {
  char *pointer;
  char *p = (char *) &message + sizeof message;

  for(pointer = message; *pointer != '\0'; pointer++) {

    if (*pointer == '%') {
      pointer++;
      switch (*pointer) {
        case 's': {
          char **s = (char **)(*(char **) p);
          char *str = malloc(MAX_LENGTH * sizeof(char));
          read(STDIN, str, MAX_LENGTH);
          str[strlen(str)-1] = '\0';
          *s = str;
          p = p + sizeof(*s);
          break;
        }
        case 'd': {
          int *number = (int*)*((int *) p);
          char *str = malloc(MAX_LENGTH * sizeof(char));
          read(STDIN, str, MAX_LENGTH);
          *number = fromString(str, 10);
          p = p + sizeof(int*);
          break;
        }
        case 'x': {
          int *number = (int*)*((int *) p);
          char *str = malloc(MAX_LENGTH * sizeof(char));
          read(STDIN, str, MAX_LENGTH);
          *number = fromString(str, 16);
          p = p + sizeof(int);
          break;
        }
        case 'b': {
          int *number = (int*)*((int *) p);
          char *str = malloc(MAX_LENGTH * sizeof(char));
          read(STDIN, str, MAX_LENGTH);
          *number = fromString(str, 2);
          p = p + sizeof(int);
          break;
        }
      }
    }
  }
  p = NULL;
}

int main(int argc, char const *argv[]) {
  char *var = malloc(123 * sizeof(char));
  int d;
  int x;
  int b;
  myscanf("%d %x %b %s", &d, &x, &b, &var);
  myprintf("%d %x %b %s\n", d, x, b, var);
  printf("%d %d %d %s\n", d, x, b, var);
  free(var);
  return 0;
}
