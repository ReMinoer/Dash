lexer grammar DashLexer;

NEWLINE: WS? (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t')+;

COMMENT_BLOCK_OPEN: '~~~~' VOID? -> pushMode(CommentBlock);
COMMENT_INLINE_OPEN: '~~' WS? -> pushMode(CommentInline);

MEDIA_OPEN: WS? '{' WS? NEWLINE* -> pushMode(Media);
EXTENSION_OPEN: WS? '<' VOID? '.' -> pushMode(Extension);

HEADER_OPEN: WS? '<' VOID? -> pushMode(Header);
HEADER_MODE_OPEN: WS? '<' VOID? '<' VOID? -> pushMode(HeaderMode);

LIST_BULLET: '-' WS?;
LIST_NUMBER: NUMBER WS? '-' WS?;

LINK_OPEN: '[' VOID?;
LINK_MIDDLE: VOID? '][' VOID? -> pushMode(Link);
DIRECT_LINK_OPEN: '[[' VOID? -> pushMode(DirectLink);
BRACKET_CLOSE: VOID? ']';

ADDRESS_OPEN: WS? '@[' VOID? -> pushMode(Address);

BOLD: '**';
ITALIC: '//';
UNDERLINE: '__';
STRIKETHROUGH: '==';

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
COMMENT_BLOCK_CLOSE:  VOID? '~~~~' -> popMode;

mode CommentInline;
COMMENT_INLINE_CONTENT: (WS? ~(' '|'\t'|'\n'|'\r')+)+;
COMMENT_INLINE_CLOSE: WS? (('\r'? '\n' | '\r') | EOF) -> popMode;

mode Media;
MEDIA_CONTENT: (VOID? ('{' MEDIA_CONTENT VOID? '}' | ~('}'|' '|'\t'|'\n'|'\r')+))+;
MEDIA_CLOSE: VOID? '}' WS? -> popMode;

mode Extension;
EXTENSION_CONTENT: (VOID? ('<' EXTENSION_CONTENT VOID? '>' | ~('>'|'-'|'+'|' '|'\t'|'\n'|'\r')+))+;
EXTENSION_CLOSE: VOID? '>' WS? -> popMode;
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
HEADER_CONTENT: (VOID? ('<' HEADER_CONTENT VOID? '>' | ~('>'|' '|'\t'|'\n'|'\r')+))+;
HEADER_CLOSE: VOID? '>' WS? -> popMode;

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
HEADER_MODE_CONTENT: (VOID? ('<' HEADER_MODE_CONTENT VOID? '>' | ~('>'|' '|'\t'|'\n'|'\r')+))+;
HEADER_MODE_CLOSE: VOID? '>' VOID? '>' WS? -> popMode;

mode Link;
LINK_CONTENT: (VOID? ('[' LINK_CONTENT VOID? ']' | ~(']'|' '|'\t'|'\n'|'\r')+))+;
REFERENCE_NUMBER: NUMBER;
LINK_CLOSE: VOID? ']' -> popMode;

mode DirectLink;
DIRECT_LINK_CONTENT: (VOID? ('[' DIRECT_LINK_CONTENT VOID? ']' | ~(']'|' '|'\t'|'\n'|'\r')+))+;
DIRECT_LINK_CLOSE: VOID? ']]' -> popMode;

mode Address;
ADDRESS_CONTENT: (VOID? ('[' ADDRESS_CONTENT VOID? ']' | ~('|'|']'|' '|'\t'|'\n'|'\r')+))+;
NOTE_NUMBER: NUMBER;
ADDRESS_CLOSE: VOID? ']' WS? -> popMode;
ADDRESS_SEPARATOR: VOID? '|' VOID?;