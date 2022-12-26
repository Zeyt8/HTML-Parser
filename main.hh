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

class Tag
{
    public:
        Tag(std::string name)
        {
            this->name = name;
            this->name[name.size() - 1] = '>';
        }
        std::string name;
        std::vector<Tag> subtags;
        std::string toString(bool withName = true)
        {
            std::string result = "";
            if (withName)
            {
                result += name;
                if (subtags.size() == 0)
                {
                    return result;
                }
                result += "->";
            }
            result += "[";
            for (int i = 0; i < subtags.size(); i++)
            {
                result += subtags[i].toString();
                if (i != subtags.size() - 1)
                {
                    result += ",";
                }
            }
            result += "]";
            return result;
        }
};
