#include <stdio.h>
#include <stdlib.h>
#include "readcmd.h"
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/file.h>
#include <sys/wait.h>
#include <signal.h>
#include <dirent.h>

/*handler associé à un signal fils*/
void traitement_CHLD(int sig) {
    int status;
    pid_t pid_termine = waitpid(-1, &status, 0|WNOHANG|WUNTRACED|WCONTINUED);
    // bool est_meme_pid = pid_termine == pid_fg;
    if (pid_termine != -1) {
        if (WIFEXITED(status)) {
            printf("\nLe processus fils %d a fini avec le code %d.\n",
                    pid_termine, WEXITSTATUS(status));
        } else if (WIFSIGNALED(status)) {
            printf("\nLe processus fils %d a été tué avec le code %d.\n",
                    pid_termine, WIFSIGNALED(status));
        } else if (WIFSTOPPED(status)) {
            printf("\nLe processus fils %d a été suspendu avec le code %d.\n",
                    pid_termine, WIFSTOPPED(status));
        } else if (WIFCONTINUED(status)) {
            printf("Le processus fils %d a été repris avec le code %d.\n",
                    pid_termine, WIFCONTINUED(status));
        }
        printf("Processus père débloqué via le signal %d.\n", sig);
    }
}
/*ETAPE 11.1*/
// void traitement_INT_STP(int sig) {
//     if (sig == SIGINT || sig == SIGTSTP) {
//     write(STDOUT_FILENO, "\n> ", 3);
//     }
// }

int main(void) {
    bool fini = false;

    struct sigaction action_CHLD;
    action_CHLD.sa_handler = traitement_CHLD;
    sigemptyset(&action_CHLD.sa_mask);
    action_CHLD.sa_flags = SA_RESTART;

    /* Déblocage du processus père après la fin du processus fils. */
    sigaction(SIGCHLD, &action_CHLD, NULL);

    /*ETAPES 11 non effectif*/

    // struct sigaction action_INT_STP;
    // action_INT_STP.sa_handler = traitement_INT_STP;
    // sigemptyset(&action_INT_STP.sa_mask);
    // action_INT_STP.sa_flags = SA_RESTART;

    // struct sigaction action_DFL;
    // action_DFL.sa_handler = SIG_DFL;
    // sigemptyset(&action_DFL.sa_mask);
    // action_DFL.sa_flags = SA_RESTART;

    // /* Signal ignoré. */
    // sigaction(SIGINT, &action_INT_STP, NULL);
    // sigaction(SIGTSTP, &action_INT_STP, NULL);
    
    // Masque qui bloque SIGINT et SIGTSTP
    // sigset_t signal_mask, old_mask;
    // sigemptyset(&signal_mask);
    // sigaddset(&signal_mask, SIGINT);
    // sigaddset(&signal_mask, SIGTSTP);

    while (!fini) {
        //ETAPE 11 effectif
        signal(SIGINT, SIG_IGN);
        signal(SIGTSTP, SIG_IGN);

        // // Masque SIGINT et SIGTSTP
        // sigprocmask(SIG_BLOCK, &signal_mask, &old_mask);

        printf("> ");
        struct cmdline *commande= readcmd();

        if (commande == NULL) {
            // commande == NULL -> erreur readcmd()
            perror("erreur lecture commande \n");
            exit(EXIT_FAILURE);
    
        } else {

            if (commande->err) {
                // commande->err != NULL -> commande->seq == NULL
                printf("erreur saisie de la commande : %s\n", commande->err);
        
            } else {
                int indexseq= 0;
                char **cmd;
                int f1;
                // int tube[2];
                // int lecture_tube;

                while ((cmd= commande->seq[indexseq])) {
                    if (cmd[0]) {

                        /*Quitter le minishell*/
                        if (strcmp(cmd[0], "exit") == 0) {
                            fini= true;
                            printf("Au revoir ...\n");
                        }

                        /*ETAPE 14 - Changer de repertoire*/
                        else if (strcmp(cmd[0], "cd") == 0) {
                            char *chemin = cmd[1];
                            if (chemin == NULL) {
                                // cd par défaut renvoie vers le HOME
                                char *home = getenv("HOME"); //On crée une variable home tmp
                                if (home == NULL) {
                                    fprintf(stderr, "Erreur : HOME non défini.\n");
                                    exit(EXIT_FAILURE);
                                }
                                chemin = strdup(home); //Sans ça il y a un munmap_chunk() error et jsp pq
                                if (chemin == NULL) {
                                    perror("Erreur d'allocation mémoire.");
                                    exit(EXIT_FAILURE);
                                }
                            }
                            if (chdir(chemin) == -1) {
                                perror("Changement de répertoire échoué.");
                            }
                            // Libération de la mémoire allouée par strdup
                            if (chemin != cmd[1]) {
                                free(chemin);
                            }
                        }

                        /*ETAPE 15 - Afficher le contenu du répertoire*/
                        else if (strcmp(cmd[0], "dir") == 0) {
                            char *chemin = cmd[1];
                            DIR *repertoire;
                            struct dirent *entree_repertoire;

                            // Aucun argument donc répertoire courant
                            if (chemin == NULL) {
                                chemin = ".";
                            }

                            //Ouvrir le répertoire
                            repertoire = opendir(chemin);
                            if (repertoire == NULL) {
                                perror("Erreur d'ouverture du répertoire.");
                                exit(EXIT_FAILURE);
                            }

                            //Afficher le contenu
                            while ((entree_repertoire = readdir(repertoire)) != NULL) {
                                printf("%s\n", entree_repertoire -> d_name);
                            }

                            //Fermer le répertoire
                            if (closedir(repertoire) == -1) {
                                perror("Erreur de fermeture du répertoire.");
                                exit(EXIT_FAILURE);
                            }
                        }
                        else {
                            // /* Etape 16 - tubes*/
                            // if (commande -> seq[indexseq + 1] != NULL) {
                            //     if (pipe(tube) == -1) {
                            //         perror("Erreur pipe");
                            //         exit(EXIT_FAILURE);
                            //     }
                            // }

                            pid_t pidFils = fork();

                            if (pidFils == -1) {
                                /* Cas d'erreur */
                                printf("Erreur fork\n");
                                exit(EXIT_FAILURE);

                            } else if (pidFils == 0) {
                                /*Cas fils*/

                                //ETAPE 11 effectif
                                //Interruption du processus fils.
                                signal(SIGINT, SIG_DFL);

                                // Arrêt du processus fils.
                                signal(SIGTSTP, SIG_DFL);

                                // // Débloque les signaux pour les fils
                                // sigprocmask(SIG_UNBLOCK, &signal_mask, NULL);
 
                                if (commande -> backgrounded != NULL) {
                                    /*Cas où le fils est en background*/
                                    //ETAPE 12
                                    setpgrp();
                                
                                /* ETAPE 13*/
                                if (commande -> in != NULL) {
                                    f1 = open(commande -> in, O_RDONLY);
                                    dup2(f1, 0); // 0 pareil que STDIN_FILENO
                                    close(f1);
                                }

                                if (commande -> out != NULL) {
                                    f1 = open(commande -> out, O_WRONLY | O_CREAT, 0644);
                                    dup2(f1, 1); //et 1 pareil que STDOUT_FILENO
                                    close(f1);
                                }
                                
                                /* Exécution de la commande */
                                }
                                if (execvp(cmd[0], cmd) == -1) {
                                    perror("Erreur d'exécution");
                                    exit(EXIT_FAILURE);
                                }
                                exit(0);
                            } else {
                                /*Cas père*/
                                if (commande -> backgrounded == NULL) {
                                    /* Cas où il est en AVANT-PLAN*/
                                    pause();

                                } else {
                                    /*Cas où on le met en ARRIERE-PLAN */
                                    printf("Commande %d lancée en background.", pidFils);
                                }
                            }
                            printf("\n");
                        }
                        indexseq++;
                    }
                }
            }
        }
    }
    return EXIT_SUCCESS;
}
