    // Foca Bogdan 336CC
%{
    #include <iostream>
    #include <fstream>
    #include <cstdio>
    #include <vector>
    #include "main.hh"

    std::vector<std::string> body_tags;
%}

%option c++
%option noyywrap
%option yyclass="HTMLParser"
%option batch

%x INSIDE_BODY

content_body <([^/][^>]*)>

%%
"<body>" { BEGIN(INSIDE_BODY); }
"</body>" { BEGIN(INITIAL); }
<INSIDE_BODY>{content_body} {
    body_tags.push_back(yytext);
}
<INITIAL,INSIDE_BODY>.|\n { }
%%

int main(int argc, char* argv[])
{
    std::ifstream in(argv[1]);
    HTMLParser parser(in, std::cout);
    parser.yylex();
    for (auto tag : body_tags) {
        std::cout << tag << std::endl;
    }
    return 0;
}