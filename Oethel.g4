grammar Oethel;

parse:
    NEWLINE*
    block (NEWLINE block)*
    EOF
    ;

block:
        title NEWLINE*
    |   quote NEWLINE*
    |   list
    |   numbered_list
    |   note NEWLINE*
    |   header line NEWLINE*
    |   WS* '<' NEWLINE* WS* header NEWLINE* WS* (inner_block (NEWLINE+ inner_block)*) NEWLINE* WS* '>'
    |   (header NEWLINE)? line (NEWLINE line)* NEWLINE+
    ;

inner_block:
        list
    |   numbered_list
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

title: TITLE;
quote: WS* '>' WS* line;

list: (list_item (NEWLINE list2)* NEWLINE)*;
list2: (WS list_item (NEWLINE list3)*)+;
list3: (WS WS list_item (NEWLINE list4)*)+;
list4: (WS WS WS list_item (NEWLINE list5)*)+;
list5: (WS WS WS WS+ list_item)+;
list_item: '*' WS* line;

numbered_list: (numbered_list_item (NEWLINE numbered_list2)* NEWLINE)*;
numbered_list2: (WS numbered_list_item (NEWLINE numbered_list3)*)+;
numbered_list3: (WS WS numbered_list_item (NEWLINE numbered_list4)*)+;
numbered_list4: (WS WS WS numbered_list_item (NEWLINE numbered_list5)*)+;
numbered_list5: (WS WS WS WS+ numbered_list_item)+;
numbered_list_item: ('0.'|'1.'|'2.'|'3.'|'4.'|'5.'|'6.'|'7.'|'8.'|'9.'|'$.') WS* line;

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


BOLD: '--';
ITALIC: '//';
UNDERLINE: '__';
STRIKETHROUGH: '==';

NEWLINE: WS* (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t');

HEADER: WS* '<' WS* ID WS* '>' WS*
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };

TITLE: WS* '-'+ '>' WS* ID
    {
        String s = getText().trim();
        setText(s.substring(s.indexOf('>') + 1, s.length()).trim());
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