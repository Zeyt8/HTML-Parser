%{
    #include <stdio.h>
%}

%%
[0-9]+ { printf("Number: %s\n", yytext); }
.|\n { }
%%

int main()
{
    yylex();
}