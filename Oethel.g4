grammar Oethel;

parse:
    NEWLINE*
    block (NEWLINE block)*
    ;

block:
        title NEWLINE*
    |   quote NEWLINE*
    |   list
    |   numbered_list
    |   header WS? line NEWLINE*
    |   (header NEWLINE)? line (NEWLINE line)* NEWLINE+
    |   WS? '<' WS? header line? (NEWLINE line)* NEWLINE? '>'
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

header: WS? HEADER;

title: WS? TITLE;
quote: WS? '>' WS? line;

list: (WS? '*' WS? line NEWLINE)*;
numbered_list: (WS? ('0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9')+ '.' WS? line NEWLINE)*;

link: WS? LINK WS?;
adress: WS? ADRESS WS?;

media: MEDIA;

NEWLINE: WS? (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t')+;
MEDIA: WS? '{' VOID? (MEDIA | ~[{}])* VOID? '}' WS?;

HEADER: '<' WS? CONTENT WS? '>';
TITLE: '-'+ '>' WS? CONTENT;

REF: '#[' INTEGER ']';
NOTE: '@[' INTEGER ']';
LINK: '#[' CONTENT ']';
ADRESS: '@[' CONTENT ']';

WORD: TEXT+;

fragment INTEGER: [0-9]+;
fragment CONTENT: ~[\n\r{}]+;
fragment TEXT: ~('\n'|'\r'|' '|'\t'|'{'|'}');
fragment VOID: (' ' | '\t' | '\n' | '\r')+;