#if !defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

class HTMLParser : public yyFlexLexer
{
    public:
        HTMLParser() {}
	    virtual ~HTMLParser() {}
        virtual int yylex();
};