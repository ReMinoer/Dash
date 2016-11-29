grammar Oethel;

parse:
    (NEWLINE* (comment|block))*
    EOF
    ;

block:
        title_1 NEWLINE*
    |   title_2 NEWLINE*
    |   title_3 NEWLINE*
    |   title_4 NEWLINE*
    |   title_5 NEWLINE*
    |   title_6 NEWLINE*
    |   title_7 NEWLINE*
    |   title_8 NEWLINE*
    |   title_9 NEWLINE*
    |   quote NEWLINE*
    |   list NEWLINE*
    |   numbered_list NEWLINE*
    |   note NEWLINE*
    |   header line NEWLINE*
    |   WS* (header_alt | '<' NEWLINE* WS* header) NEWLINE* WS* (inner_block (NEWLINE+ inner_block)*) NEWLINE* WS* '>' NEWLINE*
    |   (header NEWLINE)? line (NEWLINE line)* (NEWLINE+ | EOF)
    ;

inner_block:
        list NEWLINE*
    |   numbered_list NEWLINE*
    |   line (NEWLINE line)*
    ;

line:
    (   WS*
        (   WORD
        |   comment
        |   reference
        |   media
        |   bold
        |   italic
        |   underline
        |   strikethrough
        |   link
        |   adress
        )
    )+
    ;

bold: BOLD WS* line WS* BOLD;
italic: ITALIC WS* line WS* ITALIC;
underline: UNDERLINE WS* line WS* UNDERLINE;
strikethrough: STRIKETHROUGH WS* line WS* STRIKETHROUGH;

header: HEADER;
header_alt: HEADER_ALT;

title_1: TITLE_1;
title_2: TITLE_2;
title_3: TITLE_3;
title_4: TITLE_4;
title_5: TITLE_5;
title_6: TITLE_6;
title_7: TITLE_7;
title_8: TITLE_8;
title_9: TITLE_9;
quote: WS* '>' WS* line;

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

link: LINK;
adress: ADRESS;
note: NOTE line;

media: MEDIA;

reference: WORD REFERENCE;

comment: WS* COMMENT_INLINE | WS* COMMENT_BLOCK WS*;

COMMENT_INLINE: '~~' WS* ~[\n\r]*
    {
        String s = getText();
        setText(s.substring(2, s.length()).trim());
    };

COMMENT_BLOCK: '/~~' .*? '~~/'
    {
        String s = getText();
        setText(s.substring(3, s.length() - 3).trim());
    };

MEDIA: WS* '{' VOID? (MEDIA | ~[{}])* VOID? '}' WS*
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };


BOLD: '**';
ITALIC: '//';
UNDERLINE: '__';
STRIKETHROUGH: '==';

NEWLINE: WS* (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t');

HEADER_ALT: WS* '<<' WS* ID WS* '>' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

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

REFERENCE: '#[' WS* ('$'|[0-9]+) WS* ']'
    {
        String s = getText();
        setText(s.substring(2, s.length() - 1).trim());
    };

NOTE: WS* '@[' WS* ('$'|[0-9]+) WS* ']' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

LINK: WS* '#[' WS* ID WS* ']' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

ADRESS: WS* '@[' WS* ID WS* ']' WS*
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

WORD: TEXT+;

fragment ID: ~[\n\r{}<>]+;
fragment TEXT: ~('\n'|'\r'|' '|'\t'|'{'|'}');
fragment VOID: (' ' | '\t' | '\n' | '\r')+;