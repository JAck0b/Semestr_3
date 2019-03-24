#include <stdio.h>
// #include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h> /* wait, sleep */

int main(int argc, char const *argv[]) {
  kill(1, SIGKILL);
  sleep(1);

  setuid(0);
  kill(1, SIGKILL);
  return 0;
}
