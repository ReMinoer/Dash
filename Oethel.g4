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

bold: '--' WS* line WS* '--';
italic: '//' WS* line WS* '//';
underline: '__' WS* line WS* '__';
strikethrough: '==' WS* line WS* '==';

header: WS* HEADER WS*;

title: WS* TITLE;
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

link: WS* LINK WS*;
adress: WS* ADRESS WS*;
note: WS* NOTE WS* line;

media: MEDIA;

reference: WORD REFERENCE;

comment: WS* COMMENT_INLINE | WS* COMMENT_BLOCK WS*;

COMMENT_INLINE: '~~' ~[\n\r]*;
COMMENT_BLOCK: '/~~' .*? '~~/';

MEDIA: WS* '{' VOID? (MEDIA | ~[{}])* VOID? '}' WS*;
NEWLINE: WS* (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t');

HEADER: '<' WS* ID WS* '>';
TITLE: '-'+ '>' WS* ID;

LINK: '#[' WS* ID WS* ']';
ADRESS: '@[' WS* ID WS* ']';
NOTE: '@[' WS* ('$'|[0-9]+) WS* ']';
REFERENCE: '[' WS* ('$'|[0-9]+) WS* ']';

WORD: TEXT+;

fragment ID: ~[\n\r{}<>$0-9]+;
fragment TEXT: ~('\n'|'\r'|' '|'\t'|'{'|'}');
fragment VOID: (' ' | '\t' | '\n' | '\r')+;