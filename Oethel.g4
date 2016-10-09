grammar Oethel;

parse:
    NEWLINE*
    (block (NEWLINE NEWLINE+ block)*)?
    NEWLINE* EOF
    ;

block:
        title
    |   line (NEWLINE line)*
    ;

line:
    (   WS?
        (   WORD
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

bold: '--' WS? line WS? '--';
italic: '//' WS? line WS? '//';
underline: '__' WS? line WS? '__';
strikethrough: '==' WS? line WS? '==';

title: WS? TITLE WS?;

link: WS? LINK WS?;
adress: WS? ADRESS WS?;

media: WS? MEDIA WS?;

NEWLINE: WS? ('\r'? '\n' | '\r');
WS: (' ' | '\t')+;
MEDIA: '{' VOID? (MEDIA | ~[{}])* VOID? '}';

TITLE: '-'+ '>' WS? CONTENT+;

LINK: '#[' CONTENT+ ']';
ADRESS: '@[' CONTENT+ ']';

WORD: TEXT+;

fragment CONTENT: ~[\n\r{}];
fragment TEXT: ~('\n'|'\r'|' '|'\t'|'{'|'}'|'-'|'/'|'_'|'=');
fragment VOID: (' ' | '\t' | '\n' | '\r')+;