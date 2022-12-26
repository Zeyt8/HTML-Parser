    // Foca Bogdan 336CC
%{
    #include <iostream>
    #include <fstream>
    #include <cstdio>
    #include "main.hh"

    Tag body("body");
    int depth = 0;
    std::vector<Tag> div_tags;
%}

%option c++
%option noyywrap
%option yyclass="HTMLParser"
%option batch

%s IN_BODY IN_DIV IN_STYLE

%%

"<body>" {
    depth = 1;
    BEGIN(IN_BODY);
}

"</body>" {
    depth = 0;
    BEGIN(INITIAL);
}

"<head>(.|\n)*<style>)" {
    BEGIN(IN_STYLE);
}

"</head>(.|\n)*</style>)" {
    BEGIN(INITIAL);
}

"<b>"|"</b>" {}

<IN_BODY>"<div "|"<div>" {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext) - 1);
        body.subtags.push_back(Tag(text));
        div_tags.push_back(Tag(text + std::to_string(div_tags.size() + 1)));
        BEGIN(IN_DIV);
    }
}

<IN_DIV>"</div>" {
    BEGIN(IN_BODY);
}

<IN_BODY>"<img " {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext) - 1);
        body.subtags.push_back(Tag(text));
    }
}

<IN_BODY>"<input " {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext) - 1);
        body.subtags.push_back(Tag(text));
    }
}

<IN_BODY>"<"[^/][^ >]*(">"|" ") {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext) - 1);
        body.subtags.push_back(Tag(text));
    }
    depth++;
}

<IN_BODY,IN_DIV>"</"[^>]*">" {
    depth--;
}

<IN_DIV>"<img " {
    std::string text(yytext + 1, yytext + strlen(yytext) - 1);
    div_tags[div_tags.size() - 1].subtags.push_back(Tag(text));
}

<IN_DIV>"<input " {
    std::string text(yytext + 1, yytext + strlen(yytext) - 1);
    div_tags[div_tags.size() - 1].subtags.push_back(Tag(text));
}

<IN_DIV>"<"[^/][^ >]*(">"|" ") {
    std::string text(yytext + 1, yytext + strlen(yytext) - 1);
    div_tags[div_tags.size() - 1].subtags.push_back(Tag(text));
    depth++;
}

<IN_BODY,INITIAL,IN_DIV>.|\n {}

%%

int main(int argc, char* argv[])
{
    std::ifstream in(argv[1]);
    HTMLParser parser(in, std::cout);
    parser.yylex();
    std::cout << "Tagurile din <body>: " << body.toString(false) << std::endl;
    std::cout << "Tagurile din [";
    for (int i = 0; i < div_tags.size(); i++) {
        std::cout << div_tags[i].toString();
        if (i != div_tags.size() - 1) {
            std::cout << ",";
        }
    }
    std::cout << "]" << std::endl;
    return 0;
}