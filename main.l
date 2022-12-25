%{
    #include <iostream>
    #include "main.hh"

    HTMLParser parser;
%}

%option c++
%option noyywrap
%option yyclass="HTMLParser"
%option batch

%%
[0-9]+ { std::cout << "Number: " << yytext << std::endl; }
.|\n { }
%%

int main()
{
    parser.yylex();
}