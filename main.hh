// Foca Bogdan 336CC
#if !defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include <vector>

class HTMLParser : public yyFlexLexer
{
    public:
        HTMLParser(std::istream& arg_yyin, std::ostream& arg_yyout) : yyFlexLexer(arg_yyin, arg_yyout) {}
	    virtual ~HTMLParser() {}
        virtual int yylex();
};

class StyleTag
{
    public:
        StyleTag(const std::string& name)
        {
            this->name = name;
        }
        std::string name;
};

class Tag
{
    public:
        Tag(const std::string& name)
        {
            this->name = name;
        }
        std::string name;
        std::vector<Tag> subtags;
        std::vector<StyleTag> styletags;
        std::string toString(bool withName = true, const std::string& separator = ":", bool withStyle = false)
        {
            std::string result = "";
            if (withName)
            {
                result += "<" + name + ">";
            }
            if (withStyle && styletags.size() != 0)
            {
                result += separator + "[";
                for (int i = 0; i < styletags.size(); i++)
                {
                    result += styletags[i].name;
                    if (i != styletags.size() - 1)
                    {
                        result += ",";
                    }
                }
                result += "]";
            }
            if (subtags.size() != 0)
            {
                result += separator + "[";
                for (int i = 0; i < subtags.size(); i++)
                {
                    result += subtags[i].toString();
                    if (i != subtags.size() - 1)
                    {
                        result += ",";
                    }
                }
                result += "]";
            }
            return result;
        }
};