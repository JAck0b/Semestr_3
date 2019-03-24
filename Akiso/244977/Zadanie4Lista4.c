#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/time.h>

#define WORD_DELIM " \t\r\n\a:"
#define EXIT "exit"
#define INPUT 0
#define OUTPUT 1
#define ERROR 2


bool background = false;
bool setting = false;
int status = 0;
int quantity_of_pipes;
int redirection[3];
int place_of_redirection[3];
int gpid = -1;

static void handler(int signum)
{
  if (gpid != -1) {
    kill(-gpid, SIGINT);
  }
}

void init() {
  printf("%s\n", "********************************************");
  printf("\n" );
  printf("\n" );
  printf("%s\n", "             Welcome in lsh.");
  printf("\n" );
  printf("\n" );
  printf("%s\n", "********************************************");
  printf("\n" );
  printf("\n" );
  printf("\n" );
}

void sort(int array[3], int *out) {

  int min = 255;
  int max = 0;
  int pointerMin = 0;
  int pointerMax = 0;
  for (int i = 0; i < 3; i++) {
    if (array[i] < min) {
      min = array[i];
      pointerMin = i;
    }
    if (array[i] > max) {
      max = array[i];
      pointerMax = i;
    }
  }
  out[0] = pointerMin;
  out[2] = pointerMax;
  for (int i = 0; i < 3; i++) {
    if (out[0] != i && out[2] != i) {
      out[1] = i;
    }
  }
}

void remove_newline_ch(char *line) {

    int new_line = strlen(line) -1;
    if (line[new_line] == '\n')
      line[new_line] = '\0';
}

char** line_split(char *line){

  background = false;

	int position =0;
	char** words=malloc(1024*sizeof(char*));
	char* word;

	word =  strtok(line, WORD_DELIM);
	while (word != NULL){
    if (strcmp(word, "&") != 0) {
      words[position] = word;
      position++;
      word = strtok(NULL, WORD_DELIM);

    } else if (strcmp(word, "&") == 0){
      background = true;
      word = strtok(NULL, WORD_DELIM);

    }
	}
	words[position] = NULL;

	return words;
}

void part_of_array(char** array, char** new, int beginning, int end) {

  int j = 0;
  for (int i = beginning+1; i < end && array[i] != NULL; i++) {
    new[j] = array[i];
    j++;
  }
  new[j] = NULL;
}

void find_redirection(char* array[]) {

  redirection[INPUT] = 0;
  redirection[OUTPUT] = 0;
  redirection[ERROR] = 0;
  place_of_redirection[INPUT] = 1000;
  place_of_redirection[OUTPUT] = 1000;
  place_of_redirection[ERROR] = 1000;
  for (int i = 0; array[i] != NULL; i++) {
    if (strcmp(array[i], "<") == 0) {
      place_of_redirection[INPUT] = i;
      redirection[INPUT] = 1;
    } else if (strcmp(array[i], ">") == 0) {
      place_of_redirection[OUTPUT] = i;
      redirection[OUTPUT] = 1;
    } else if (strcmp(array[i], "2>") == 0) {
      place_of_redirection[ERROR] = i;
      redirection[ERROR] = 1;
    }
  }
}

void search_path(char* words[], char** path) {

  for (int i = 0; path[i] != NULL; i++) {
    DIR *dp;
    struct dirent *ep;

    dp = opendir (path[i]);
    if (dp != NULL) {
        while (ep = readdir (dp)) {
          if (strcmp((ep->d_name), words[0]) == 0) {

              char tmp[100];
              find_redirection(words);
              strcpy(tmp, path[i]);
              strcat(tmp, "/");
              strcat(tmp, words[0]);
              int queue[3];
              int newfd;
              sort(place_of_redirection, queue);
              char** pice = malloc(100*sizeof(char*));
              part_of_array(words, pice, -1, 1000);

              for (int i = 0 ; i < 3; i++) {
                if (redirection[queue[i]] == 1 && i == 0) {
                  part_of_array(words, pice, -1, place_of_redirection[queue[i]]);
                }
                if (queue[i] == OUTPUT && redirection[queue[i]] == 1) {
                  if ((newfd = open(words[place_of_redirection[OUTPUT]+1], O_CREAT|O_TRUNC|O_WRONLY, 0644)) < 0) {
                    perror(words[place_of_redirection[OUTPUT]+1]); /* open failed */ exit(1);
                  }
                  dup2(newfd, OUTPUT);
                  close(newfd);
                }
                if (queue[i] == INPUT && redirection[queue[i]] == 1) {
                  if ((newfd = open(words[place_of_redirection[INPUT]+1], O_RDWR, 0644)) < 0) {
                    perror(words[place_of_redirection[INPUT]+1]); /* open failed */ exit(1);
                  }
                  dup2(newfd, INPUT);
                  close(newfd);
                }
                if (queue[i] == ERROR && redirection[queue[i]] == 1) {
                  if ((newfd = open(words[place_of_redirection[ERROR]+1], O_CREAT|O_TRUNC|O_WRONLY, 0644)) < 0) {
                    perror(words[place_of_redirection[ERROR]+1]); /* open failed */ exit(1);
                  }
                  dup2(newfd, ERROR);
                  close(newfd);
                }
              }
              execvp(tmp, pice);
              perror("Exec failed");


          }
        }

        (void) closedir (dp);
      }
    else {
      perror ("Couldn't open the directory");
    }
    if (setting) {
      break;
    }
  }
  kill(getpid(), SIGINT);
}

void search_dir (char** words) {

  char tmp[100];
  find_redirection(words);

  int queue[3];
  int newfd;
  sort(place_of_redirection, queue);
  char** pice = malloc(100*sizeof(char*));
  part_of_array(words, pice, -1, 1000);

  for (int i = 0 ; i < 3; i++) {
    if (redirection[queue[i]] == 1 && i == 0) {
      part_of_array(words, pice, -1, place_of_redirection[queue[i]]);
    }
    if (queue[i] == OUTPUT && redirection[queue[i]] == 1) {
      if ((newfd = open(words[place_of_redirection[OUTPUT]+1], O_CREAT|O_TRUNC|O_WRONLY, 0644)) < 0) {
        perror(words[place_of_redirection[OUTPUT]+1]); /* open failed */ exit(1);
      }
      dup2(newfd, OUTPUT);
      close(newfd);
    }
    if (queue[i] == INPUT && redirection[queue[i]] == 1) {
      if ((newfd = open(words[place_of_redirection[INPUT]+1], O_RDWR, 0644)) < 0) {
        perror(words[place_of_redirection[INPUT]+1]); /* open failed */ exit(1);
      }
      dup2(newfd, INPUT);
      close(newfd);
    }
    if (queue[i] == ERROR && redirection[queue[i]] == 1) {
      if ((newfd = open(words[place_of_redirection[ERROR]+1], O_CREAT|O_TRUNC|O_WRONLY, 0644)) < 0) {
        perror(words[place_of_redirection[ERROR]+1]); /* open failed */ exit(1);
      }
      dup2(newfd, ERROR);
      close(newfd);
    }
  }
  execvp(words[0], pice);
  perror("Exec failed");


  kill(getpid(), SIGINT);

}

void use_cd (char* words[]) {

  int out;
  char tmp[sizeof(words[1]-2)];

  // if (strlen(words[1]) > 1 && words[1][0] == '"' && words[1][strlen(words[1])-1] == '"') {
  //   for (int i = 0; i < strlen(words[1])-2; i++) {
  //     words[1][i] = words[1][i+1];
  //   }
  //   words[1][strlen(words[1])-2] = '\0';
  // }

  out = chdir(words[1]);

}

void enter_command(char* command) {

  char cwd[255];
  if (getcwd(cwd, sizeof(cwd)) != NULL) {
    redirection[OUTPUT] = 0;
    redirection[INPUT] = 0;
    redirection[ERROR] = 0;
    place_of_redirection[OUTPUT] = 1000;
    place_of_redirection[INPUT] = 1000;
    place_of_redirection[ERROR] = 1000;
    setting = false;
    memset(command, 0, sizeof(command));
    printf("%s", cwd);
    printf("$ ");
    char * l = fgets(command, 255, stdin);
    if (l == NULL) {
      printf("\n");
      _exit(0);
    }
    remove_newline_ch(command);
   } else {
       perror("getcwd() error");
   }

}

void run(char** words, char** path, pid_t c_pid) {

  signal (SIGCHLD, SIG_IGN);

  if (words[0] != NULL && words[0][0] != '.' && words[0][1] != '/' && strcmp(words[0], "cd") != 0) {
    gpid = fork();
    c_pid = gpid;
    if (c_pid == 0) {
      setpgid(0, gpid);
        search_path(words, path);
    } else if (c_pid > 0) {
      if (background == 0) {
        waitpid(c_pid, &status, 0);
      }
    } else {
       perror("fork failed");
       _exit(2);
    }
  } else if (words[0][0] == '.' && words[0][1] == '/' && strcmp(words[0], "cd") != 0){
    gpid= fork();
    c_pid = gpid;
    if (c_pid == 0) {
      setpgid(0, gpid);
      search_dir(words);
    } else if (c_pid > 0) {
      if (background == 0) {
        waitpid(c_pid, &status, 0);
      }
    } else {
       perror("fork failed");
       _exit(2);
    }
  } else if (strcmp(words[0], "cd") == 0) {
    use_cd(words);
  }

}

int counting_pipes(char* array[]) {

  int counter = 0;
  for (int i = 0; array[i] != NULL; i++) {
    if (strcmp(array[i], "|") == 0) {
      counter++;
    }
  }
  return counter;
}



void find_pipe(char* array[], int pipes_places[]) {

  int j = 0;
  for (int i = 0; array[i] != NULL; i++) {
    if (strcmp(array[i], "|") == 0) {
      pipes_places[j] = i;
      j++;
    }
  }
}


void multi_run (char** words, char** path, int *pipes_places, int quantity_of_pipes) {

  pid_t pids[quantity_of_pipes+1];
  int pipes[quantity_of_pipes][2];
  int current_pipe = 0;

  for (int i = 0; i <= quantity_of_pipes; i++) {

    if (i < quantity_of_pipes) {
      pipe(pipes[i]);
    }
    if (i == 0) {
      gpid= fork();
      pids[i] = gpid;
    } else {
      pids[i] = fork();
    }
    if (pids[i] == 0) {
      setpgid(0, gpid);
      if (i == 0) {

        close(pipes[i][0]);
        dup2(pipes[i][1], 1); // ouput
        close(pipes[i][1]);
        char** tmp = malloc(100*sizeof(char*));
        part_of_array(words, tmp, -1, pipes_places[i]);
        if (tmp[0] != NULL && tmp[0][0] != '.' && tmp[0][1] != '/' && strcmp(words[0], "cd") != 0) {
          search_path(tmp, path);
        } else if (words[0][0] == '.' && words[0][1] == '/' && strcmp(words[0], "cd") != 0) {
          search_dir(tmp);
        }

      }  else if (i < quantity_of_pipes){

        close(pipes[i-1][1]);
        dup2(pipes[i-1][0], 0); // input
        close(pipes[i-1][0]);

        close(pipes[i][0]);
        dup2(pipes[i][1], 1); // ouput
        close(pipes[i][1]);

        char** tmp = malloc(100*sizeof(char*));
        part_of_array(words, tmp, pipes_places[i-1], pipes_places[i]);
        if (tmp[0] != NULL && tmp[0][0] != '.' && tmp[0][1] != '/' && strcmp(words[0], "cd") != 0) {
          search_path(tmp, path);
        } else if (words[0][0] == '.' && words[0][1] == '/' && strcmp(words[0], "cd") != 0) {
          search_dir(tmp);
        }

      } else if (i == quantity_of_pipes) {

        close(pipes[i-1][1]);
        dup2(pipes[i-1][0], 0); // input
        close(pipes[i-1][0]);

        char** tmp = malloc(100*sizeof(char*));
        part_of_array(words, tmp, pipes_places[i-1], pipes_places[i-1]+100);
        if (tmp[0] != NULL && tmp[0][0] != '.' && tmp[0][1] != '/' && strcmp(words[0], "cd") != 0) {
          search_path(tmp, path);
        } else if (words[0][0] == '.' && words[0][1] == '/' && strcmp(words[0], "cd") != 0) {
          search_dir(tmp);
        }

      }
    }
    if (i > 0) {
      close(pipes[i-1][0]);
      close(pipes[i-1][1]);
    }
  }
  for (int i = 0; i < quantity_of_pipes; i++) {
    close(pipes[i][0]);
    close(pipes[i][1]);
  }
  if (background == false) {
    pid_t c_pid;
    while ((c_pid = wait(&status)) > 0);
  }
}

int main() {
   struct sigaction sa;


   sa.sa_handler = handler;
   sigemptyset(&sa.sa_mask);
   sa.sa_flags = SA_RESTART; /* Restart functions if
                                interrupted by handler */
   if (sigaction(SIGINT, &sa, NULL) == -1){}


  char command[255];
  char** path;
  path = line_split(getenv("PATH"));
  pid_t c_pid;
  init();


  enter_command(command);

  while (strcmp(command, EXIT) != 0 && command != NULL) {
    gpid = -1;
    char** words = malloc(1024*sizeof(char*)); // our splitted command

    words = line_split(command);
    find_redirection(words);

    int tmp[3];
    sort(place_of_redirection, tmp);

    quantity_of_pipes = counting_pipes(words);
    int pipes_places[quantity_of_pipes];
    find_pipe(words, pipes_places);
    find_redirection(words);

    if (quantity_of_pipes > 0) {
      multi_run(words, path, pipes_places, quantity_of_pipes);
    } else {
      run(words, path, c_pid);
    }
    // wait(NULL);
    enter_command(command);
  }
  printf("\n" );
  printf("\n" );
  printf("%s\n", "******************EXIT**********************");
  printf("\n" );
  printf("\n" );
  while ((c_pid = wait(&status)) > 0);


  return 0;
}
