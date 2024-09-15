#ifndef CLI_H
#define CLI_H
extern char * const output_file_name;
extern char * const input_file_name;

int handle_arguments(const int argc, const char * const * const argv);
#endif
