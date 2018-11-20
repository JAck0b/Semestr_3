#include<stdio.h>

int main() {
	for (int i = 48; i < 50; i++) {
		for (int j = 48; j < 58; j++) {
			for (int k = 48; k < 58; k++) {
				printf("\x1B[38;5;%c%c%cmHello, World!\n\033[0m", (char)i, (char)j, (char)k);
			}
		}
	}
	for (int j = 48; j < 53; j++) {
		for (int k = 48; k < 58; k++) {
			printf("\x1B[38;5;2%c%cmHello, World!\n\033[0m", (char)j, (char)k);
		}
	}
	for (int k = 48; k < 54; k++) {
		printf("\x1B[38;5;25%cmHello, World!\n\033[0m", (char)k);
	}
	return 0;
}
