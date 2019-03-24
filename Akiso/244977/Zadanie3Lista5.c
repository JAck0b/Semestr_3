#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/time.h> //FD_SET, FD_ISSET, FD_ZERO macros

#define TRUE 1
#define FALSE 0
#define PORT 8888

// Select partner.
void selectPartner(char buffer[], char **nickname, char **partner,
	int valread, int new_socket, int client_socket[], int max_clients, int i) {
		// Prepare to write users.
		strcpy(buffer, "Select one user:\n");
		for (int ite = 0; ite < max_clients; ite++) {
			if (client_socket[ite] != 0) {
				strcat(buffer, nickname[ite]);
			}
		}
		strcat(buffer, "\n\0");
		// Sending users.
		if( send(new_socket, buffer, strlen(buffer), 0) != strlen(buffer) )
		{
			perror("Cannot send.");
		}
		// Reading partner
		if ((valread = read( new_socket , buffer, 1024)) == 0) {
			perror("Cannot read.");
		}
		buffer[valread] = '\0';
		strcpy(partner[i], nickname[i]);
		for (int ite = 0; ite < max_clients; ite++) {
			if (strcmp(nickname[ite], buffer) == 0) {
				strcpy(partner[i], buffer);
				break;
			}
		}
	}

	int main(int argc , char *argv[])
	{
		int opt = TRUE;
		int master_socket , addrlen , new_socket , client_socket[30] ,
		max_clients = 30 , activity, i , valread , sd;
		int max_sd;
		char **nickname = malloc(30*sizeof(char *));
		char **partner  = malloc(30*sizeof(char *));
		for (int i = 0; i < 30; i++) {
			nickname[i] = malloc(10*sizeof(char *));
			partner[i] = malloc(10*sizeof(char *));
		}
		struct sockaddr_in address;

		char buffer[1025];

		// Set of socket descriptors.
		fd_set readfds;

		// Init message.
		char *message = "Enter your nickname (max 10 char) \r\n";

		//initialise all client_socket[] to 0 so not checked
		for (i = 0; i < max_clients; i++) {
			client_socket[i] = 0;
		}

		//create a master socket
		if( (master_socket = socket(AF_INET , SOCK_STREAM , 0)) == 0) {
			perror("Cannot create master socket.");
			exit(EXIT_FAILURE);
		}

		// Set master socket to allow multiple connections.
		if( setsockopt(master_socket, SOL_SOCKET, SO_REUSEADDR, (char *)&opt,
		sizeof(opt)) < 0 ) {
			perror("Cannot use setsockopt.");
			exit(EXIT_FAILURE);
		}

		// Creating of address.
		address.sin_family = AF_INET;
		address.sin_addr.s_addr = INADDR_ANY;
		address.sin_port = htons( PORT );

		// Attaching port 8888 with socket.
		if (bind(master_socket, (struct sockaddr *)&address, sizeof(address))<0) {
			perror("Cannot bind.");
			exit(EXIT_FAILURE);
		}
		printf("Listener on port %d \n", PORT);

		// Waiting for clients.Max 3 clients can wait.
		if (listen(master_socket, 5) < 0) {
			perror("Cannot listen.");
			exit(EXIT_FAILURE);
		}

		addrlen = sizeof(address);
		printf("Waiting for connections ...");

		while(TRUE) {
			// Clear the socket set.
			FD_ZERO(&readfds);

			// Add master socket to set.
			FD_SET(master_socket, &readfds);
			max_sd = master_socket;

			// Add child sockets to set.
			for ( i = 0 ; i < max_clients ; i++) {
				sd = client_socket[i];

				if(sd > 0)
				FD_SET( sd , &readfds);

				if(sd > max_sd)
				max_sd = sd;
			}

			// Wait for an activity on one of the sockets , timeout is NULL so infinite.
			activity = select( max_sd + 1 , &readfds , NULL , NULL , NULL);

			if ((activity < 0) && (errno!=EINTR)) {
				printf("select error");
			}

			// If something happened on the master socket.
			if (FD_ISSET(master_socket, &readfds)) {
				if ((new_socket = accept(master_socket,
					(struct sockaddr *)&address, (socklen_t*)&addrlen))<0) {
						perror("Cannot accept.");
						exit(EXIT_FAILURE);
					}

					printf("New connection , socket fd is %d , ip is : %s , port : %d \n"
					, new_socket , inet_ntoa(address.sin_addr) , ntohs(address.sin_port));

					// Init message to client.
					if(send(new_socket, message, strlen(message), 0) != strlen(message)) {
						perror("Cannot send.");
					}

					printf("Welcome message sent successfully");

					// Adding new user.
					for (i = 0; i < max_clients; i++) {
						if( client_socket[i] == 0 )	{
							// Reading their name.
							if ((valread = read( new_socket , buffer, 1024)) == 0) {
								perror("Cannot read.");
							}
							buffer[valread] = '\0';
							strcpy(nickname[i], buffer);
							// Setting partner.
							selectPartner(buffer, nickname, partner, valread, new_socket,
								client_socket, max_clients, i);

								client_socket[i] = new_socket;
								printf("Adding to list of sockets as %d, %s\n" , i, nickname[i]);

								break;
							}
						}
					}

					// Operation IO.
					for (i = 0; i < max_clients; i++) {
						sd = client_socket[i];

						if (FD_ISSET( sd , &readfds)) {
							// Check if it was for closing and read the message.
							if ((valread = read( sd , buffer, 1024)) == 0 && sd != 0) {
								// Somebody disconnected.
								getpeername(sd , (struct sockaddr*)&address ,
								(socklen_t*)&addrlen);
								printf("Host disconnected , ip %s , port %d \n" ,
								inet_ntoa(address.sin_addr) , ntohs(address.sin_port));
								// Client = 0 to not list it in clients.
								client_socket[i] = 0;
								// Changing partner.
								int ite = 0;
								while (ite < max_clients) {
									if (strcmp(partner[ite], nickname[i]) == 0 && strcmp(partner[ite],
										 nickname[ite]) != 0) {
										char tmp[1025];
										strcpy(tmp, "Your partner is disconnected.\n");
										strcat(tmp, "\0");
										if( send(client_socket[ite], tmp, strlen(tmp), 0) != strlen(tmp) )
										{
											perror("Cannot send.");
										}
										selectPartner(tmp, nickname, partner, valread, client_socket[ite],
											 client_socket, max_clients, ite);

									}
									ite++;
								}

								close( sd );
								memset(nickname[i], 0, 10);
								memset(partner[i], 0, 10);
							} else {
								// End message.
								buffer[valread] = '\0';

								int ite = 0;
								while (ite < max_clients) {
									if (strcmp(partner[i], nickname[ite]) == 0) {
										break;
									}
									ite++;
								}
								if (send(client_socket[ite] , buffer , strlen(buffer) , 0 ) != strlen(buffer)) {
									perror("Cannot send.");
								}
							}
						}
					}
				}

				for (int i = 0; i < 30; i++) {
					free(nickname[i]);
					free(partner[i]);
				}
				free(nickname);
				free(nickname);

				return 0;
			}
