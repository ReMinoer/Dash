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

list: (list_item (NEWLINE list2)* NEWLINE)*;
list2: (WS list_item (NEWLINE list3)* NEWLINE)*;
list3: (WS WS list_item (NEWLINE list4)* NEWLINE)*;
list4: (WS WS WS list_item (NEWLINE list5)* NEWLINE)*;
list5: (BLANK list_item NEWLINE)*;
list_item: '*' BLANK? line;

numbered_list: (numbered_list_item (NEWLINE list2)* NEWLINE)*;
numbered_list2: (WS numbered_list_item (NEWLINE list3)* NEWLINE)*;
numbered_list3: (WS WS numbered_list_item (NEWLINE list4)* NEWLINE)*;
numbered_list4: (WS WS WS numbered_list_item (NEWLINE list5)* NEWLINE)*;
numbered_list5: (BLANK numbered_list_item NEWLINE)*;
numbered_list_item: ('0.'|'1.'|'2.'|'3.'|'4.'|'5.'|'6.'|'7.'|'8.'|'9.'|'$.') BLANK? line;

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