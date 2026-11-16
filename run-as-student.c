#define _GNU_SOURCE
#include <errno.h>
#include <grp.h>
#include <pwd.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <sys/wait.h>
#include <unistd.h>

/* Runs a command as the user "student"; installed set-uid root, executable by runner only. */

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: run-as-student command [args...]\n");
        return 2;
    }

    struct passwd *student = getpwnam("student");
    if (student == NULL) {
        fprintf(stderr, "run-as-student: user student not found\n");
        return 2;
    }

    uid_t caller_uid = getuid();
    gid_t caller_gid = getgid();
    pid_t parent = getpid();

    pid_t child = fork();
    if (child < 0) {
        perror("run-as-student: fork");
        return 2;
    }

    if (child == 0) {
        if (setgroups(0, NULL) != 0
            || setresgid(student->pw_gid, student->pw_gid, student->pw_gid) != 0
            || setresuid(student->pw_uid, student->pw_uid, student->pw_uid) != 0) {
            perror("run-as-student: drop privileges");
            _exit(2);
        }

        /* Changing credentials clears the parent-death signal, so set it after. */
        if (prctl(PR_SET_PDEATHSIG, SIGKILL) != 0) {
            perror("run-as-student: prctl");
            _exit(2);
        }
        /* The parent may have died before the signal was set. */
        if (getppid() != parent) {
            _exit(2);
        }

        execvp(argv[1], argv + 1);
        perror("run-as-student: exec");
        _exit(127);
    }

    /* Real and saved UID stay the caller's: the judge can kill this process, the student cannot. */
    /* Effective UID is the student's: the kernel only sends the parent-death signal when the dying parent may signal the child. */
    if (setresgid(caller_gid, caller_gid, caller_gid) != 0
        || setresuid(caller_uid, student->pw_uid, caller_uid) != 0) {
        perror("run-as-student: drop privileges");
        return 2;
    }

    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) {
            perror("run-as-student: waitpid");
            return 2;
        }
    }

    /* Die of the same signal, so the caller sees the return code it would see without this helper. */
    if (WIFSIGNALED(status)) {
        int signal_number = WTERMSIG(status);
        signal(signal_number, SIG_DFL);
        kill(getpid(), signal_number);
    }
    return WEXITSTATUS(status);
}
