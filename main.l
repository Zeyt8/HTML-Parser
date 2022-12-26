    // Foca Bogdan 336CC
%{
    #include <iostream>
    #include <fstream>
    #include <cstdio>
    #include "main.hh"

    Tag body("body");
    int depth = 0;
%}

%option c++
%option noyywrap
%option yyclass="HTMLParser"
%option batch

%s IN_BODY

%%

"<body>" {
    depth = 1;
    BEGIN(IN_BODY);
}

"</body>" {
    depth = 0;
    BEGIN(INITIAL);
}

<IN_BODY>"<img " {
    if (depth == 1) {
        body.subtags.push_back(Tag(yytext));
    }
}

<IN_BODY>"<input " {
    if (depth == 1) {
        body.subtags.push_back(Tag(yytext));
    }
}

<IN_BODY>"<"[^/][^ >]*(">"|" ") {
    if (depth == 1) {
        body.subtags.push_back(Tag(yytext));
    }
    depth++;
}

<IN_BODY>"</"[^>]*">" {
    depth--;
}

<IN_BODY,INITIAL>.|\n {}

%%

int main(int argc, char* argv[])
{
    std::ifstream in(argv[1]);
    HTMLParser parser(in, std::cout);
    parser.yylex();
    std::cout << "Tagurile din <body>: " << body.toString(false) << std::endl;
    return 0;
}