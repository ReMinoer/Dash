grammar Oethel;

parse: NEWLINE* (block (NEWLINE NEWLINE+ block)*)? NEWLINE* EOF;
block: run (NEWLINE run)*;
run: (WS? (WORD | media | bold | italic | underline | strikethrough))+;

bold: BOLD_TOKEN WS? run WS? BOLD_TOKEN;
italic: ITALIC_TOKEN WS? run WS? ITALIC_TOKEN;
underline: UNDERLINE_TOKEN WS? run WS? UNDERLINE_TOKEN;
strikethrough: STRIKETRHOUGH_TOKEN WS? run WS? STRIKETRHOUGH_TOKEN;

media: MEDIA_OPEN media_block MEDIA_CLOSE;
media_block: media_run (NEWLINE* media_run)*;
media_run: (WS? (WORD | MEDIA_WORD | media))+;

BOLD_TOKEN: '--';
ITALIC_TOKEN: '//';
UNDERLINE_TOKEN: '__';
STRIKETRHOUGH_TOKEN: '==';

MEDIA_OPEN: WS? '{' VOID?;
MEDIA_CLOSE: VOID? '}' WS?;

NEWLINE: WS? ('\r'? '\n' | '\r');
WS: (' ' | '\t')+;

WORD: OTHER+;
MEDIA_WORD: ~('\n'|'\r'|' '|'\t'|'{'|'}');

fragment OTHER: ~('\n'|'\r'|' '|'\t'|'{'|'}'|'-'|'/'|'_'|'=');
fragment VOID: (' ' | '\t' | '\n' | '\r')+;