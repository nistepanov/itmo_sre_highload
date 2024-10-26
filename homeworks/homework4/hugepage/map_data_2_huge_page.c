#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <unistd.h>

#define FILEPATH "/mnt/huge/mymappedfile"
#define FILESIZE (2 * 1024 * 1024)  // 2 MB
#define WORD "HelloHugePages"

int main() {
    int fd;
    void *map;

    fd = open(FILEPATH, O_CREAT | O_RDWR, 0755);
    if (fd == -1) {
        perror("open");
        exit(EXIT_FAILURE);
    }

    if (ftruncate(fd, FILESIZE) == -1) {
        perror("ftruncate");
        exit(EXIT_FAILURE);
    }

    // map file to huge pages using HUGETLB flags
    map = mmap(NULL, FILESIZE, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_HUGETLB, fd, 0);
    if (map == MAP_FAILED) {
        perror("mmap");
        exit(EXIT_FAILURE);
    }

    strcpy((char *)map, WORD);

    if (munmap(map, FILESIZE) == -1) {
        perror("munmap");
        exit(EXIT_FAILURE);
    }

    close(fd);
    return 0;
}