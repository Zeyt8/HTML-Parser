    // Foca Bogdan 336CC
%{
    #include <iostream>
    #include <fstream>
    #include <cstdio>
    #include "main.hh"

    Tag body("body");
    int depth = 0;
    std::vector<Tag> div_tags;
    std::vector<Tag> style_head_tags;
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

<IN_BODY>"</body>" {
    depth = 0;
    BEGIN(INITIAL);
}

<INITIAL>"<head>"(.|\n)*"<style>" {
    BEGIN(IN_STYLE);
}

<IN_STYLE>"</style>"(.|\n)*"</head>" {
    BEGIN(INITIAL);
}

"<b>"|"</b>" {}

<IN_STYLE>[^{}\n ]+/(" {") {
    style_head_tags.push_back(Tag(yytext));
}

<IN_STYLE>[^:{;\n ]+/(:(.|\n)*;) {
    style_head_tags[style_head_tags.size() - 1].styletags.push_back(StyleTag(yytext));
}

<IN_BODY>"<div"/(">"|" ") {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext));
        body.subtags.push_back(Tag(text));
        div_tags.push_back(Tag(text + std::to_string(div_tags.size() + 1)));
        BEGIN(IN_DIV);
    }
}

<IN_DIV>"</div>" {
    BEGIN(IN_BODY);
}

<IN_BODY>"<img"/" " {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext));
        body.subtags.push_back(Tag(text));
    }
}

<IN_BODY>"<input"/" " {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext));
        body.subtags.push_back(Tag(text));
    }
}

<IN_BODY>"<"[^/][^ >]*/(">"|" ") {
    if (depth == 1) {
        std::string text(yytext + 1, yytext + strlen(yytext));
        body.subtags.push_back(Tag(text));
    }
    depth++;
}

<IN_BODY,IN_DIV>"</"[^>]*">" {
    depth--;
}

<IN_DIV>"<img"/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    div_tags[div_tags.size() - 1].subtags.push_back(Tag(text));
}

<IN_DIV>"<input"/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    div_tags[div_tags.size() - 1].subtags.push_back(Tag(text));
}

<IN_DIV>"<"[^/][^ >]*/(">"|" ") {
    std::string text(yytext + 1, yytext + strlen(yytext));
    div_tags[div_tags.size() - 1].subtags.push_back(Tag(text));
    depth++;
}

<IN_BODY,INITIAL,IN_DIV,IN_STYLE>.|\n {}

%%

int main(int argc, char* argv[])
{
    std::ifstream in(argv[1]);
    HTMLParser parser(in, std::cout);
    parser.yylex();
    std::cout << "Tagurile din <body>: " << body.toString(false) << std::endl;
    if (div_tags.size() != 0)
    {
        if (div_tags.size() == 1)
            std::cout << "Tagurile din ";
        else
            std::cout << "Tagurile din [";

        for (int i = 0; i < div_tags.size(); i++)
        {
            std::cout << div_tags[i].toString();
            if (i != div_tags.size() - 1)
            {
                std::cout << ",";
            }
        }

        if (div_tags.size() != 1)
            std::cout << "]" << std::endl;
    }
    if (style_head_tags.size() != 0)
    {
        std::cout << "Tagurile de <style>:[";
        for (int i = 0; i < style_head_tags.size(); i++)
        {
            std::cout << style_head_tags[i].toString(true, "->", true);
            if (i != style_head_tags.size() - 1)
            {
                std::cout << ",";
            }
        }
        std::cout << "]";
    }
    std::cout << std::endl;
    return 0;
}