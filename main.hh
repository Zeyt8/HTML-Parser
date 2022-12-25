// Foca Bogdan 336CC
#if !defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

class HTMLParser : public yyFlexLexer
{
    public:
        HTMLParser(std::istream& arg_yyin, std::ostream& arg_yyout) : yyFlexLexer(arg_yyin, arg_yyout) {}
	    virtual ~HTMLParser() {}
        virtual int yylex();
};