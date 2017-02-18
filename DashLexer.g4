lexer grammar DashLexer;

NEWLINE: WS? (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t')+;

COMMENT_BLOCK_OPEN: '~~~~' VOID? -> pushMode(CommentBlock);
COMMENT_INLINE_OPEN: '~~' WS? -> pushMode(CommentInline);

MEDIA_OPEN: WS? '{' WS? NEWLINE* -> pushMode(Media);
EXTENSION_OPEN: WS? '<' WS? '.' -> pushMode(Extension);

HEADER_OPEN: WS? '<' WS? -> pushMode(Header);
HEADER_MODE_OPEN: WS? '<' WS? '<' WS? -> pushMode(HeaderMode);

LIST_BULLET: '-' WS?;
LIST_NUMBER: NUMBER WS? '-' WS?;

SELECTION_OPEN: '[' WS?;
SELECTION_CLOSE: WS? ']';

BOLD_OPEN: '*[' WS?;
ITALIC_OPEN: '/[' WS?;
UNDERLINE_OPEN: '_[' WS?;
STRIKETHROUGH_OPEN: '=[' WS?;

LINK_MIDDLE: WS? '][' WS? -> pushMode(Link);
DIRECT_LINK_OPEN: '[[' WS? -> pushMode(DirectLink);

ADDRESS_OPEN: WS? '@[' WS? -> pushMode(Address);

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

fragment WORD_CHAR: ~('*'|'/'|'_'|'='|'-'|'\n'|'\r'|' '|'\t'|'{'|'}'|'['|']'|'<'|'>');
fragment NUMBER: [0-9$]+;
fragment VOID: (' '|'\t'|'\n'|'\r')+;

mode CommentBlock;
COMMENT_BLOCK_CONTENT: (VOID? ('~' ('~' '~'?)?)? ~('~'|' '|'\t'|'\n'|'\r'))+;
COMMENT_BLOCK_CLOSE:  VOID? '~~~~' ~('\n'|'\r')* (('\r'? '\n' | '\r') | EOF) -> popMode;

mode CommentInline;
COMMENT_INLINE_CONTENT: (WS? ~(' '|'\t'|'\n'|'\r')+)+;
COMMENT_INLINE_CLOSE: WS? (('\r'? '\n' | '\r') | EOF) -> popMode;

mode Media;
MEDIA_CONTENT: (VOID? ~('{'|'}'|'\''|'"'|' '|'\t'|'\n'|'\r')+)+;
MEDIA_BRACES_OPEN: VOID? '{' -> pushMode(Media);
MEDIA_STRING_OPEN: VOID? '"' -> pushMode(MediaString);
MEDIA_CHAR_OPEN: VOID? '\'' -> pushMode(MediaChar);
MEDIA_CLOSE: VOID? '}' WS? -> popMode;

mode MediaString;
MEDIA_STRING_CONTENT: ~('"')+;
MEDIA_STRING_CLOSE: '"' -> popMode;

mode MediaChar;
MEDIA_CHAR_CONTENT: ~('\'')+;
MEDIA_CHAR_CLOSE: '\'' -> popMode;

mode Extension;
EXTENSION_CONTENT: (WS? ('<' EXTENSION_CONTENT WS? '>' | ~('>'|'-'|'+'|' '|'\t'|'\n'|'\r')+))+;
EXTENSION_CLOSE: WS? '>' WS? -> popMode;
EXTENSION_MINUS: '-';
EXTENSION_PLUS: '+';

mode Header;
HEADER_TITLE_1: '-';
HEADER_TITLE_2: '--';
HEADER_TITLE_3: '---';
HEADER_TITLE_4: '----';
HEADER_TITLE_5: '-----';
HEADER_TITLE_6: '------';
HEADER_TITLE_7: '-------';
HEADER_TITLE_8: '--------';
HEADER_TITLE_9: '---------';
HEADER_CONTENT: (WS? ('<' HEADER_CONTENT WS? '>' | ~('>'|' '|'\t'|'\n'|'\r')+))+;
HEADER_CLOSE: WS? '>' WS? -> popMode;

mode HeaderMode;
HEADER_MODE_TITLE_1: '-';
HEADER_MODE_TITLE_2: '--';
HEADER_MODE_TITLE_3: '---';
HEADER_MODE_TITLE_4: '----';
HEADER_MODE_TITLE_5: '-----';
HEADER_MODE_TITLE_6: '------';
HEADER_MODE_TITLE_7: '-------';
HEADER_MODE_TITLE_8: '--------';
HEADER_MODE_TITLE_9: '---------';
HEADER_MODE_CONTENT: (WS? ('<' HEADER_MODE_CONTENT WS? '>' | ~('>'|' '|'\t'|'\n'|'\r')+))+;
HEADER_MODE_CLOSE: WS? '>' WS? '>' WS? -> popMode;

mode Link;
LINK_CONTENT: (WS? ('[' LINK_CONTENT WS? ']' | ~(']'|' '|'\t'|'\n'|'\r')+))+;
REFERENCE_NUMBER: NUMBER;
LINK_CLOSE: WS? ']' -> popMode;

mode DirectLink;
DIRECT_LINK_CONTENT: (WS? ('[' DIRECT_LINK_CONTENT WS? ']' | ~(']'|' '|'\t'|'\n'|'\r')+))+;
DIRECT_LINK_CLOSE: WS? ']]' -> popMode;

mode Address;
NOTE_NUMBER: NUMBER;
ADDRESS_CONTENT: (WS? ('[' ADDRESS_CONTENT WS? ']' | ~('|'|']'|' '|'\t'|'\n'|'\r')+))+;
ADDRESS_CLOSE: WS? ']' WS? -> popMode;
ADDRESS_SEPARATOR: WS? '|' WS?;