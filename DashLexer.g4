lexer grammar DashLexer;

NEWLINE: WS? (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t')+;

BLOCK_CLOSE: '</>';

COMMENT_BLOCK_OPEN: '~~~~' VOID? -> pushMode(CommentBlock);
COMMENT_INLINE_OPEN: '~~' WS? -> pushMode(CommentInline);

MEDIA_OPEN: WS? '{' VOID? -> pushMode(Media);
EXTENSION_OPEN: WS? '<' VOID? '.' -> pushMode(Extension);

HEADER_OPEN: WS? '<' VOID? -> pushMode(Header);

TITLE_1: WS? '<->' WS?;
TITLE_2: WS? '<-->' WS?;
TITLE_3: WS? '<--->' WS?;
TITLE_4: WS? '<---->' WS?;
TITLE_5: WS? '<----->' WS?;
TITLE_6: WS? '<------>' WS?;
TITLE_7: WS? '<------->' WS?;
TITLE_8: WS? '<-------->' WS?;
TITLE_9: WS? '<--------->' WS?;

LIST_BULLET: '-' WS?;
LIST_NUMBER: ([0-9$])+ WS? '-' WS?;

LINK_OPEN: '[';
LINK_MIDDLE: '][' -> pushMode(Link);
DIRECT_LINK_OPEN: '[[' -> pushMode(DirectLink);
BRACKET_CLOSE: ']';

ADDRESS_OPEN: '@[' -> pushMode(Address);

BOLD: '--';
ITALIC: '//';
UNDERLINE: '__';
STRIKETHROUGH: '==';

WORD:
        '*'
    |   '/'
    |   '_'
    |   '-'
    |   (   '*'NOT_BOLD
        |   '/'NOT_ITALIC
        |   '_'NOT_UNDERLINE
        |   '-'NOT_STRIKETHROUGH
        |   WORD_CHAR
        )+
    ;

fragment NOT_BOLD:
    (   '/'NOT_ITALIC
    |   '_'NOT_UNDERLINE
    |   '-'NOT_STRIKETHROUGH
    |   WORD_CHAR
    );

fragment NOT_ITALIC:
    (   '*'NOT_BOLD
    |   '_'NOT_UNDERLINE
    |   '-'NOT_STRIKETHROUGH
    |   WORD_CHAR
    );

fragment NOT_UNDERLINE:
    (   '*'NOT_BOLD
    |   '/'NOT_ITALIC
    |   '-'NOT_STRIKETHROUGH
    |   WORD_CHAR
    );

fragment NOT_STRIKETHROUGH:
    (   '*'NOT_BOLD
    |   '/'NOT_ITALIC
    |   '_'NOT_UNDERLINE
    |   WORD_CHAR
    );

fragment WORD_CHAR: ~('*'|'/'|'_'|'-'|'\n'|'\r'|' '|'\t'|'{'|'}'|'['|']'|'<'|'>');
fragment ID: ~[\n\r.{}<>\[\]]+;
fragment VOID: (' '|'\t'|'\n'|'\r')+;

mode CommentBlock;
COMMENT_BLOCK_CONTENT: ~[~]+;
COMMENT_BLOCK_CLOSE:  VOID? '~~~~' -> popMode;

mode CommentInline;
COMMENT_INLINE_CONTENT: ~[\n\r]+;
COMMENT_INLINE_CLOSE: WS? (('\r'? '\n' | '\r') | EOF) -> popMode;

mode Media;
MEDIA_CONTENT: ('{' MEDIA_CONTENT '}' | ~[{}]+)+;
MEDIA_CLOSE: VOID? '}' WS? -> popMode;

mode Extension;
EXTENSION_MINUS: '-';
EXTENSION_PLUS: '+';
EXTENSION_CONTENT: [a-zA-Z0-9]+ ('.'[a-zA-Z0-9]+)*;
EXTENSION_CLOSE: VOID? '>' WS? -> popMode;

mode Header;
HEADER_CONTENT: ~[\n\r.{}<>\[\]]+;
HEADER_CLOSE: VOID? '>' WS? -> popMode;

mode Link;
REFERENCE_NUMBER: [0-9$]+;
LINK_CONTENT: ~[\n\r{}\[\]]+;
LINK_CLOSE: ']' -> popMode;

mode DirectLink;
DIRECT_LINK_CONTENT: ~[\n\r{}\[\]]+;
DIRECT_LINK_CLOSE: ']]' -> popMode;

mode Address;
NOTE_NUMBER: [0-9$]+;
ADDRESS_SEPARATOR: '|';
ADDRESS_CONTENT: ~[\n\r{}\[\]|]+;
ADDRESS_CLOSE: ']' -> popMode;