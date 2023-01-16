    // Foca Bogdan 336CC
%{
    #include <iostream>
    #include <fstream>
    #include <cstdio>
    #include "main.hh"

    Tag body("body");
    std::vector<Tag*> div_tags;
    std::vector<Tag*> style_tags;
    std::vector<Tag*> top_style_head_tags;
    std::vector<Tag*> style_head_tags;

    int last_div = -1;
    int offset = 0;
%}

%option c++
%option noyywrap
%option yyclass="HTMLParser"
%option batch
%option caseless

%s IN_BODY IN_DIV IN_STYLE IN_INLINE_STYLE IN_TAG

%%

    /* begin body section */
"<body>" {
    yy_push_state(IN_BODY);
}

    /* begin head style section */
"<style>" {
    BEGIN(IN_STYLE);
}

    /* ignore bold sections and break lines */
"<b>"|"</b>"|"<br>"|"<hr>"|"<i>"|"</i>" {}

    /*
    IN INLINE STYLE STATES REGION
    */

    /* match with property if followed by ="someValue" */
<IN_INLINE_STYLE>[^=";\n ]+/=\"[^"]*\" {
    style_head_tags[style_head_tags.size() - 1]->styletags.push_back(StyleTag(yytext));
}

    /* end inline style section */
<IN_INLINE_STYLE>">" {
    yy_pop_state();
}

    /*
    IN STYLE STATES REGION
    */

    /* end head style section */
<IN_STYLE>"</style>" {
    BEGIN(INITIAL);
}

    /* match with tag if followed by space and { */
<IN_STYLE>[^{}\n ]+/(" {") {
    // add said tag to the list of style tags
    style_tags.push_back(new Tag(yytext));
}

    /* match with property if followed by : and value */
<IN_STYLE>[^:{;\n ]+/(:(.|\n)*;) {
    // add that property to the last style tag
    style_tags[style_tags.size() - 1]->styletags.push_back(StyleTag(yytext));
}

    /*
    END TAG REGION
    */

    /* match with end div while in a div */
<IN_DIV>"</div>" {
    yy_pop_state();
    last_div -= offset;
}

    /* end tag */
<IN_BODY,IN_DIV,IN_TAG>"</"[^>]*">" {
    yy_pop_state();
}

    /*
    IN BODY STATES REGION
    */

    /* found div begin in body section */
<IN_BODY>"<div"/">" {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text + std::to_string(div_tags.size() + 1));

    body.subtags.push_back(tag);
    div_tags.push_back(tag);
    offset = div_tags.size() - 1 - last_div;
    last_div = div_tags.size() - 1;

    yy_push_state(IN_DIV);
}

    /* found div with inline style in body section */
<IN_BODY>"<div"/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text + std::to_string(div_tags.size() + 1));

    body.subtags.push_back(tag);
    div_tags.push_back(tag);
    offset = div_tags.size() - 1 - last_div;
    last_div = div_tags.size() - 1;
    style_head_tags.push_back(tag);
    top_style_head_tags.push_back(tag);

    yy_push_state(IN_DIV);
    yy_push_state(IN_INLINE_STYLE);
}

    /* found img or input in body section */
<IN_BODY>"<"(img|input)/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text);

    body.subtags.push_back(tag);
    style_head_tags.push_back(tag);
    top_style_head_tags.push_back(tag);

    yy_push_state(IN_INLINE_STYLE);
}

    /* found other tag in body section */
<IN_BODY>"<"[^/][^ >]*/">" {
    std::string text(yytext + 1, yytext + strlen(yytext));
    body.subtags.push_back(new Tag(text));

    yy_push_state(IN_TAG);
}

    /* found other tag in body section with inline style */
<IN_BODY>"<"[^/][^ >]*/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text);

    body.subtags.push_back(tag);
    style_head_tags.push_back(tag);
    top_style_head_tags.push_back(tag);

    yy_push_state(IN_TAG);
    yy_push_state(IN_INLINE_STYLE);
}

    /*
    IN DIV STATES REGION
    /*

    /* found div begin in another div */
<IN_DIV>"<div"/">" {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text + std::to_string(div_tags.size() + 1));

    div_tags[last_div]->subtags.push_back(tag);
    div_tags.push_back(tag);
    offset = div_tags.size() - 1 - last_div;
    last_div = div_tags.size() - 1;

    yy_push_state(IN_DIV);
}

    /* found div with inline style in another div */
<IN_DIV>"<div"/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text + std::to_string(div_tags.size() + 1));

    div_tags[last_div]->subtags.push_back(tag);
    div_tags.push_back(tag);
    offset = div_tags.size() - 1 - last_div;
    last_div = div_tags.size() - 1;
    style_head_tags.push_back(tag);

    yy_push_state(IN_DIV);
    yy_push_state(IN_INLINE_STYLE);
}

    /* found img or input in div section with inline style */
<IN_DIV>"<"(img|input)/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text);

    div_tags[last_div]->subtags.push_back(tag);
    style_head_tags.push_back(tag);

    yy_push_state(IN_INLINE_STYLE);
}

    /* found other tag in div section */
<IN_DIV>"<"[^/][^ >]*/">" {
    std::string text(yytext + 1, yytext + strlen(yytext));
    div_tags[last_div]->subtags.push_back(new Tag(text));
    yy_push_state(IN_TAG);
}

    /* found other tag in div section with inline style */
<IN_DIV>"<"[^/][^ >]*/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text);

    div_tags[last_div]->subtags.push_back(tag);
    style_head_tags.push_back(tag);

    yy_push_state(IN_TAG);
    yy_push_state(IN_INLINE_STYLE);
}

    /*
    IN TAG REGION
    */

    /* match div inside antoher tag */
<IN_TAG>"<div"/">" {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text + std::to_string(div_tags.size() + 1));

    div_tags.push_back(tag);
    offset = div_tags.size() - 1 - last_div;
    last_div = div_tags.size() - 1;

    yy_push_state(IN_DIV);
}

    /* match div with inline style inside another tag */
<IN_TAG>"<div"/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text + std::to_string(div_tags.size() + 1));

    div_tags.push_back(tag);
    offset = div_tags.size() - 1 - last_div;
    last_div = div_tags.size() - 1;
    style_head_tags.push_back(tag);

    yy_push_state(IN_DIV);
    yy_push_state(IN_INLINE_STYLE);
}

    /* match img or input in antoher tag */
<IN_TAG>"<"(img|input)/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text);

    style_head_tags.push_back(tag);

    yy_push_state(IN_INLINE_STYLE);
}

    /* match another tag with inline style inside another tag */
<IN_TAG>"<"[^/][^ >]*/" " {
    std::string text(yytext + 1, yytext + strlen(yytext));
    Tag* tag = new Tag(text);

    style_head_tags.push_back(tag);

    yy_push_state(IN_TAG);
    yy_push_state(IN_INLINE_STYLE);
}

.|\n {}

%%

int main(int argc, char* argv[])
{
    std::ifstream in(argv[1]);
    HTMLParser parser(in, std::cout);
    parser.yylex();
    // print body tags
    std::cout << "Tagurile din <body>" << body.toString(false) << std::endl;
    // print div tags
    if (div_tags.size() != 0)
    {
        if (div_tags.size() == 1)
            std::cout << "Tagurile din ";
        else
            std::cout << "Tagurile din [";

        for (int i = 0; i < div_tags.size(); i++)
        {
            std::cout << div_tags[i]->toString();
            if (i != div_tags.size() - 1)
            {
                std::cout << ",";
            }
        }
        if (div_tags.size() != 1)
            std::cout << "]";
        std::cout << std::endl;
    }
    if (style_tags.size() != 0)
    {
        std::cout << "Tagurile din <style>:[";
        for (int i = 0; i < style_tags.size(); i++)
        {
            std::cout << style_tags[i]->toString(true, "->", true);
            if (i != style_tags.size() - 1)
            {
                std::cout << ",";
            }
        }
        std::cout << "]" << std::endl;
    }
    if (div_tags.size() != 0 || top_style_head_tags.size() != 0)
    {
        std::cout << "Tagurile de <style>:[";
    }
    if (top_style_head_tags.size() != 0)
    {
        for (int i = 0; i < top_style_head_tags.size(); i++)
        {
            std::cout << top_style_head_tags[i]->toString(true, "->", true, 0);
            if (i != top_style_head_tags.size() - 1)
            {
                std::cout << ",";
            }
            else
            {
                if (div_tags.size() != 0)
                {
                    std::cout << ",";
                }
                else
                {
                    std::cout << "]" << std::endl;
                }
            }
        }
    }
    if (div_tags.size() != 0)
    {
        for (int i = 0; i < div_tags.size(); i++)
        {
            for (int j = 0; j < div_tags[i]->subtags.size(); j++)
            {
                if (div_tags[i]->subtags[j]->styletags.size() != 0)
                {
                    std::cout << "<" + div_tags[i]->name + ">->" << div_tags[i]->subtags[j]->toString(true, "->", true, 0);
                    if (j != div_tags[i]->subtags.size() - 1 || i < div_tags.size() - 1)
                    {
                        std::cout << ",";
                    }
                }
            }
        }
        std::cout << "]" << std::endl;
    }
    // print style tags
    return 0;
}