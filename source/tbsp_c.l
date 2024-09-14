%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <string.h>

    #include <kvec.h>
    #include <sds.h>

    kvec_t(char *) query;
    static sds buffer;

    #define ECHOC(x) do { buffer = sdscatlen(buffer, &x, 1); } while(0)
    #define ECHOS(x) do { buffer = sdscat(buffer, x); } while(0)

    extern char * expand_c_query(void);
%}
identifier [a-zA-z][a-zA-z0-9_]*

%x IN_COMMENT IN_MULTILINE_COMMENT IN_STRING
%x IN_QUERY

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
.               {
                    char * expanded_query = expand_c_query();
                    ECHOS(expanded_query);
                    free(expanded_query);

                    ECHOS(yytext);

                    BEGIN INITIAL;
                }
}

%%

char * tbsp_c_expland_code(const char * const s) {
    kv_init(query);
    buffer = sdsnew("");

	YY_BUFFER_STATE const b = yy_scan_string(s);
    tbsp_c_lex();
	tbsp_c__delete_buffer(b);

    return buffer;
}

// XXX this bleeds
char * expand_c_query(void) {
    const char * const query_fmt = "ts_node_child_by_field_name(%s, \"%s\", strlen(\"%s\"))";
    char * r;

    r = (char *)"current_node";
    for (int i = 0; i < kv_size(query); i++) {
        asprintf(&r, query_fmt, r, kv_A(query, i), kv_A(query, i));
    }

    return r;
}