grammar Oethel;

parse: NEWLINE* (block (NEWLINE NEWLINE+ block)*)? END_OF_FILE;
block: line (NEWLINE line)*;
line: (WS? WORD | media)+;
media: MEDIA_OPEN line (NEWLINE* line)* MEDIA_CLOSE;

MEDIA_OPEN: WS? '{' VOID?;
MEDIA_CLOSE: VOID? '}' WS?;
END_OF_FILE: NEWLINE* EOF;
NEWLINE: WS? ('\r'? '\n' | '\r');
WS: (' ' | '\t')+;
WORD: ~[\n\r \t{}]+;
fragment VOID: (' ' | '\t' | '\n' | '\r')+;