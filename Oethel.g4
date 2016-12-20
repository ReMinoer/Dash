grammar Oethel;

parse:
    (   NEWLINE*
        (   comment
        |   title_1 
        |   title_2
        |   title_3
        |   title_4
        |   title_5
        |   title_6
        |   title_7
        |   title_8
        |   title_9
        |   note
        |   block
        )
    )* EOF;

block:
    (   header (list | numbered_list | line)
    |   header (NEWLINE+ (list | numbered_list | line) (NEWLINE (list | numbered_list | line))*)* NEWLINE* WS* '>'
    |   (header NEWLINE)? (list | numbered_list | line) (NEWLINE (list | numbered_list | line))* NEWLINE
    )   NEWLINE*
    ;

line:
    (   WS*
        (   comment
        |   reference
        |   media
        |   bold
        |   italic
        |   underline
        |   strikethrough
        |   link
        |   adress
        |   WORD | LINK_BEGIN | ADRESS_END
        )
    )+
    ;

bold: BOLD WS* line WS* BOLD;
italic: ITALIC WS* line WS* ITALIC;
underline: UNDERLINE WS* line WS* UNDERLINE;
strikethrough: STRIKETHROUGH WS* line WS* STRIKETHROUGH;

header: HEADER;

title_1: TITLE_1 NEWLINE*;
title_2: TITLE_2 NEWLINE*;
title_3: TITLE_3 NEWLINE*;
title_4: TITLE_4 NEWLINE*;
title_5: TITLE_5 NEWLINE*;
title_6: TITLE_6 NEWLINE*;
title_7: TITLE_7 NEWLINE*;
title_8: TITLE_8 NEWLINE*;
title_9: TITLE_9 NEWLINE*;

/*
list
    [int listDepth]
    :
    @init { int depth; }
    WS* '-' WS* line NEWLINE
    (
        { depth = 0; }
        (WS { depth++; })*
        (
                { depth == listDepth }? '-' WS* line
            |   { depth > listDepth }? list[depth]
        )  
        NEWLINE
    )*;
*/

list: (list_item (NEWLINE list2)* NEWLINE)+;
list2: (WS list_item (NEWLINE list3)*)+;
list3: (WS WS list_item (NEWLINE list4)*)+;
list4: (WS WS WS list_item (NEWLINE list5)*)+;
list5: (WS WS WS WS+ list_item)+;
list_item: '-' WS* line;

numbered_list: (numbered_list_item (NEWLINE numbered_list2)* NEWLINE)+;
numbered_list2: (WS numbered_list_item (NEWLINE numbered_list3)*)+;
numbered_list3: (WS WS numbered_list_item (NEWLINE numbered_list4)*)+;
numbered_list4: (WS WS WS numbered_list_item (NEWLINE numbered_list5)*)+;
numbered_list5: (WS WS WS WS+ numbered_list_item)+;
numbered_list_item: ('0-'|'1-'|'2-'|'3-'|'4-'|'5-'|'6-'|'7-'|'8-'|'9-'|'$-') WS+ line;

link: DIRECT_LINK | '[' line LINK;
adress: DEFINITION | ADRESS line ']';
note: NOTE line;

media: MEDIA;

reference: WORD REFERENCE;

comment: WS* COMMENT_INLINE | WS* COMMENT_BLOCK WS*;

COMMENT_BLOCK: '~~~~' .*? '~~~~'
    {
        String s = getText();
        setText(s.substring(3, s.length() - 3).trim());
    };

COMMENT_INLINE: '~~' WS* ~[\n\r]*
    {
        String s = getText();
        setText(s.substring(2, s.length()).trim());
    };

MEDIA: WS* '{' VOID? (MEDIA | ~[{}])* VOID? '}' WS*
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };

NEWLINE: WS* (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t');

HEADER: WS* '<' WS* ID WS* '>' WS*
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };

TITLE_1: WS* '->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(2, s.length()).trim());
    };

TITLE_2: WS* '-->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(3, s.length()).trim());
    };

TITLE_3: WS* '--->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(4, s.length()).trim());
    };

TITLE_4: WS* '---->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(5, s.length()).trim());
    };

TITLE_5: WS* '----->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(6, s.length()).trim());
    };

TITLE_6: WS* '------>' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(7, s.length()).trim());
    };

TITLE_7: WS* '------->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(8, s.length()).trim());
    };

TITLE_8: WS* '-------->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(9, s.length()).trim());
    };

TITLE_9: WS* '--------->' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(10, s.length()).trim());
    };

DIRECT_LINK: WS* '[[' WS* ~('['|']')+ WS* ']]' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 2).trim());
    };

DEFINITION: WS* '@[[' WS* ~('['|']')+ WS* ']]' WS*
    {
        String s = getText().trim();
        setText(s.substring(3, s.length() - 2).trim());
    };

NOTE: WS* '@[' WS* ('$'|[0-9]+) WS* ']' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

REFERENCE: WS* '[' WS* ('$'|[0-9]+) WS* ']' WS*
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };

ADRESS: '@[' WS* ~('['|']')+ WS* '][' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 2).trim());
    };

LINK: WS* '][' WS* ~('['|']')+ WS* ']'
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

LINK_BEGIN: '[' WS*;
ADRESS_END: WS* ']';

BOLD: '**';
ITALIC: '//';
UNDERLINE: '__';
STRIKETHROUGH: '==';

WORD:
        '*'
    |   '/'
    |   '_'
    |   '='
    |   (   '*'NOT_BOLD
        |   '/'NOT_ITALIC
        |   '_'NOT_UNDERLINE
        |   '='NOT_STRIKETHROUGH
        |   WORD_CHAR
        )+
    ;

fragment NOT_BOLD:
    (   '/'NOT_ITALIC
    |   '_'NOT_UNDERLINE
    |   '='NOT_STRIKETHROUGH
    |   WORD_CHAR
    );

fragment NOT_ITALIC:
    (   '*'NOT_BOLD
    |   '_'NOT_UNDERLINE
    |   '='NOT_STRIKETHROUGH
    |   WORD_CHAR
    );

fragment NOT_UNDERLINE:
    (   '*'NOT_BOLD
    |   '/'NOT_ITALIC
    |   '='NOT_STRIKETHROUGH
    |   WORD_CHAR
    );

fragment NOT_STRIKETHROUGH:
    (   '*'NOT_BOLD
    |   '/'NOT_ITALIC
    |   '_'NOT_UNDERLINE
    |   WORD_CHAR
    );

fragment WORD_CHAR: ~('*'|'/'|'_'|'='|'\n'|'\r'|' '|'\t'|'{'|'}'|'['|']');
fragment ID: ~[\n\r{}<>\[\]]+;
fragment VOID: (' '|'\t'|'\n'|'\r')+;