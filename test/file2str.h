#ifndef FILE2STR_H
#define FILE2STR_H

#define FILE2STR(dest, filename) \
    FILE* f = fopen(filename, "r"); \
    if (!f) { return 1; } \
    fseek(f, 0, SEEK_END); \
    int flen = ftell(f); \
    rewind(f); \
    char fstr[flen+1]; \
    dest[flen] = '\00'; \
    fread(dest, flen, sizeof(char), f); \
    fclose(f);

#endif
