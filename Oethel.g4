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
    |   header BLANK? line NEWLINE*
    |   (header NEWLINE)? line (NEWLINE line)* NEWLINE+
    |   BLANK? '<' BLANK? header line? (NEWLINE line)* NEWLINE? '>'
    ;

line:
    (   BLANK?
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

bold: '--' BLANK? line BLANK? '--';
italic: '//' BLANK? line BLANK? '//';
underline: '__' BLANK? line BLANK? '__';
strikethrough: '==' BLANK? line BLANK? '==';

header: BLANK? HEADER;

title: BLANK? TITLE;
quote: BLANK? '>' BLANK? line;

list: (BLANK? '*' BLANK? line NEWLINE)*;
numbered_list: (BLANK? ('0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9')+ '.' BLANK? line NEWLINE)*;

link: BLANK? LINK BLANK?;
adress: BLANK? ADRESS BLANK?;

media: MEDIA;

NEWLINE: BLANK? (('\r'? '\n' | '\r') | EOF);
BLANK: WS+;
WS: (' ' | '\t');
MEDIA: BLANK? '{' VOID? (MEDIA | ~[{}])* VOID? '}' BLANK?;

HEADER: '<' BLANK? CONTENT BLANK? '>';
TITLE: '-'+ '>' BLANK? CONTENT;

REF: '#[' INTEGER ']';
NOTE: '@[' INTEGER ']';
LINK: '#[' CONTENT ']';
ADRESS: '@[' CONTENT ']';

WORD: TEXT+;

fragment INTEGER: [0-9]+;
fragment CONTENT: ~[\n\r{}]+;
fragment TEXT: ~('\n'|'\r'|' '|'\t'|'{'|'}');
fragment VOID: (' ' | '\t' | '\n' | '\r')+;