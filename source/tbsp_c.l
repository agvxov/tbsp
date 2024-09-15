%top{
    #define _GNU_SOURCE
}
%{
    #include <stdio.h>
    #include <string.h>

    #include <kvec.h>
    #include <sds.h>

    kvec_t(char *) query;
    static sds buffer;
    static sds query_string_buffer;

    #define ECHOC(x) do { buffer = sdscatlen(buffer, &x, 1); } while(0)
    #define ECHOS(x) do { buffer = sdscat(buffer, x); } while(0)

    extern char * expand_c_query(void);
%}
identifier [a-zA-z][a-zA-z0-9_]*

%x IN_COMMENT IN_MULTILINE_COMMENT IN_STRING
%x IN_QUERY IN_QUERY_STRING

%option nodefault
%option noyywrap
%option nounput noinput

%option prefix="tbsp_c_"
%%
\/\/        {
                ECHOS(yytext);
                BEGIN IN_COMMENT;
            }
\/\*        {
                ECHOS(yytext);
                BEGIN IN_COMMENT;
            }
\"          {
                BEGIN IN_STRING;
            }
\$\$        {
                BEGIN IN_QUERY;
            }
.|\n        {
                ECHOS(yytext);
            }

<IN_COMMENT>{
\n          {
                ECHOS(yytext);
                BEGIN INITIAL;
            }
.           {
                ECHOS(yytext);
            }
}

<IN_MULTILINE_COMMENT>{
\*\/        {
                ECHOS(yytext);
                BEGIN INITIAL;
            }
.           {
                ECHOS(yytext);
            }
}

<IN_STRING>{
\\\"        {
                ECHOS(yytext);
            }
\"          {
                ECHOS(yytext);
                BEGIN INITIAL;
            }
.           {
                ECHOS(yytext);
            }
}

<IN_QUERY>{
\-\>            { ; }
{identifier}    {
                    kv_push(char *, query, strdup(yytext));
                }
\"              {
                    sdsfree(query_string_buffer);
                    query_string_buffer = sdsnew(yytext);
                    BEGIN IN_QUERY_STRING;
                }
.               {
                    char * expanded_query = expand_c_query();
                    ECHOS(expanded_query);
                    free(expanded_query);

                    ECHOS(yytext);

                    BEGIN INITIAL;
                }
}

<IN_QUERY_STRING>{
\"              {
                    query_string_buffer = sdscat(query_string_buffer, yytext);
                    kv_push(char *, query, strdup(query_string_buffer));
                    BEGIN IN_QUERY;
                }
.               {
                    query_string_buffer = sdscat(query_string_buffer, yytext);
                }
}

%%

char * tbsp_c_expland_code(const char * const s) {
	YY_BUFFER_STATE const b = yy_scan_string(s);
    tbsp_c_lex();
	tbsp_c__delete_buffer(b);

    return buffer;
}

// XXX this bleeds
char * expand_c_query(void) {
    const char * const query_fmt = "ts_node_child_by_field_name(%s, %s, strlen(%s))";
    char * r;

    r = (char *)"tbnode";
    for (int i = 0; i < kv_size(query); i++) {
        int ignore = asprintf(&r, query_fmt, r, kv_A(query, i), kv_A(query, i));
        (void)ignore;
    }

    return r;
}

int tbsp_c_yy_init(void) {
    kv_init(query);
    buffer = sdsnew("");
    query_string_buffer = sdsnew("");
    return 0;
}

int tbsp_c_yy_deinit(void) {
    tbsp_c__delete_buffer(YY_CURRENT_BUFFER);
    sdsfree(buffer);
    sdsfree(query_string_buffer);
    return 0;
}
