%{
    #include <sds.h>
    #include "tbsp.tab.h"

    int code_nesting = 0;

    int code_caller;

    sds buffer;
%}

identifier [a-zA-z][-a-zA-z0-9_]*

%x IN_DEFINITION_SECTION IN_RULE_SECTION IN_CODE_SECTION
%x IN_CODE

%option nodefault
%option noyywrap
%option nounput noinput
%%
.   { yyless(0); BEGIN IN_DEFINITION_SECTION; }

<IN_DEFINITION_SECTION>{
\%top[[:space:]]*\{     {
                            code_caller = IN_DEFINITION_SECTION;
                            BEGIN IN_CODE;
                            return TOP;
                        }
\%language[[:space:]]   {
                            return LANGUAGE;
                        }
{identifier}            {
                            yylval.strval = strdup(yytext);
                            return IDENTIFIER;
                        }
[[:space:]]             { ; }
\%\%                    {
                            BEGIN IN_RULE_SECTION;
                            return SEPARATOR;
                        }
.                       {
                            yyerror("unknown shit");
                        }
}

<IN_RULE_SECTION>{
\{                  {
                        code_caller = IN_RULE_SECTION;
                        BEGIN IN_CODE;
                    }
\}                  { ; }
([[:space:]]|\n)*   { ; }
enter[[:space:]]    { return ENTER; }
leave[[:space:]]    { return LEAVE; }
{identifier}        {
                        yylval.strval = strdup(yytext);
                        return IDENTIFIER;
                    }
\%\%                {
                        BEGIN IN_CODE_SECTION;
                        return SEPARATOR;
                    }
}

<IN_CODE>{
\{              { ++code_nesting; }
\}              {
                    if (!code_nesting) {
                        yylval.strval = strdup(buffer);
                        sdsclear(buffer);
                        BEGIN code_caller;
                        return CODE_BLOB;
                    }

                    --code_nesting;
                    ;
                }
.|\n            { buffer = sdscat(buffer, yytext); }
}

<IN_CODE_SECTION>{
(.|\n)*         {
                    yylval.strval = strdup(yytext);
                    BEGIN IN_DEFINITION_SECTION;
                    return CODE_BLOB;
                }
}

%%

int tbsp_yy_init(void) {
    buffer = sdsnew("");
    return 0;
}

int tbsp_yy_deinit(void) {
    yy_delete_buffer(YY_CURRENT_BUFFER);
    sdsfree(buffer);
    return 0;
}
