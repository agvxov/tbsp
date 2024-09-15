#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

extern void yyerror(const char * const fmt, ...);

char * output_file_name = NULL;
char * input_file_name  = NULL;

static
const char * help_message = "\
tbsp [options] <file>  : convert tbsp source file to C/C++ source file\n\
    -h          : show help\n\
    -o <string> : specify output file\
";

static
char * default_output_name(const char * const name) {
    static const char default_extension[] = ".tb.c";
    char * r;

    const int len = strlen(name);

    int i = len;
    for (; i != 0; i--) {
        if (name[i] == '.') {
            break;
        }
    }

    if (i == 0) {
        i = len;
    }

    r = (char *)malloc(i + sizeof(default_extension));
    memcpy(r, name, i);
    memcpy(r + i, default_extension, sizeof(default_extension));

    return r;
}

int handle_arguments(const int argc, const char * const * const argv) {
    if (argc < 2) {
        puts(help_message);
        return 1;
    }

    int opt;
    while ((opt = getopt(argc, (char * const *)argv, "ho:")) != -1) {
        switch (opt) {
            case 'h': {
                puts(help_message);
            } exit(0);
            case 'o': {
                output_file_name = strdup(optarg);
            } break;
            default: {
                yyerror("unknown option '%s'", argv[optind]);
            } return 1;
        }
    }

    input_file_name = strdup(argv[argc-1]);

    if (!output_file_name) {
        output_file_name = default_output_name(input_file_name);
    }

    return 0;
}
