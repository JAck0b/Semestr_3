#include <signal.h>
#include <stdio.h>
#include <unistd.h> /* getpid */
#include <sys/wait.h> /* wait, sleep */

int i;
int j;

void cntl_c_handler(int dummy) {
  signal(SIGINT, cntl_c_handler);
  printf("i=%d, j=%d  Control-C\n", i, j);
}

void kill_c_handler(int dummy) {
  signal(SIGINT, cntl_c_handler);
  signal(SIGKILL, kill_c_handler);
  printf("Killed" );
}

int main () {
  signal(SIGINT, cntl_c_handler);
  signal(SIGKILL, kill_c_handler);
  printf("Pid = %d\n", getpid());

  sleep(3);
  kill(getpid(), SIGKILL);
  
  for ( j = 0; j < 20000; j++) {
    for ( i = 0; i < 1000000; i++) {
    }
  }
}
