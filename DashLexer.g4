lexer grammar DashLexer;

NEWLINE: WS? (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t')+;

COMMENT_BLOCK_OPEN: '###' NEWLINE -> pushMode(CommentBlock);
COMMENT_INLINE_OPEN: '##' WS? -> pushMode(CommentInline);

MEDIA_OPEN: WS? '{' WS? NEWLINE* -> pushMode(Media);
EXTENSION_OPEN: WS? '<' WS? '.' -> pushMode(Extension);
EXTENSION_MODE_OPEN: WS? '<' WS? '<' WS? '.' -> pushMode(ExtensionMode);

HEADER_OPEN: WS? '<' WS? -> pushMode(Header);
HEADER_MODE_OPEN: WS? '<' WS? '<' WS? -> pushMode(HeaderMode);

MODE_CLOSE: VOID? '<...>' WS?;

LIST_BULLET: '-' WS?;
LIST_NUMBER: NUMBER WS? '-' WS?;
LIST_IMPORTANT_BULLET: '->' WS?;
LIST_IMPORTANT_NUMBER: NUMBER WS? '->' WS?;

SELECTION_OPEN: '[' WS?;
SELECTION_CLOSE: WS? ']';

BOLD_OPEN: '*[' WS?;
ITALIC_OPEN: '/[' WS?;
MARK_OPEN: '=[' WS?;
OBSOLETE_OPEN: '~[' WS?;

LINK_MIDDLE: WS? '][' WS? -> pushMode(Link);
DIRECT_LINK_OPEN: '[[' WS? -> pushMode(DirectLink);

ADDRESS_OPEN: WS? '@[' WS? -> pushMode(Address);
REDIRECTION_AUTO_OPEN: WS? '@[[' WS? -> pushMode(DirectLink);

WORD: ~('-'|'\n'|'\r'|' '|'\t'|'<'|'{'|'['|']'|'~')+;

fragment NUMBER: ([0-9]+|'$'+);
fragment VOID: (' '|'\t'|'\n'|'\r')+;

mode CommentBlock;
COMMENT_BLOCK_CONTENT: (VOID? '#'? ~('#'|' '|'\t'|'\n'|'\r'))+;
COMMENT_BLOCK_CLOSE:  VOID? '###' NEWLINE -> popMode;

mode CommentInline;
COMMENT_INLINE_CONTENT: (WS? ~(' '|'\t'|'\n'|'\r')+)+;
COMMENT_INLINE_CLOSE: WS? (('\r'? '\n' | '\r') | EOF) -> popMode;

mode Media;
MEDIA_CONTENT: (VOID? ~('{'|'}'|' '|'\t'|'\n'|'\r')+)+;
MEDIA_BRACES_OPEN: VOID? '{' -> pushMode(Media);
MEDIA_CLOSE: VOID? '}' WS? -> popMode;

mode Extension;
EXTENSION_CONTENT: (WS? ('<' EXTENSION_CONTENT WS? '>' | ~('>'|'-'|'+'|' '|'\t'|'\n'|'\r')+))+;
EXTENSION_CLOSE: WS? '>' WS? -> popMode;
EXTENSION_MINUS: '-';
EXTENSION_PLUS: '+';

mode ExtensionMode;
EXTENSION_MODE_DASH: WS? ('dash' | 'dh') WS? -> pushMode(DashExtension);
EXTENSION_MODE_CONTENT: (WS? ('<' EXTENSION_MODE_CONTENT WS? '>' | ~('>'|'-'|'+'|' '|'\t'|'\n'|'\r')+))+;
EXTENSION_MODE_CLOSE: WS? '>' WS? '>' (WS? (('\r'? '\n' | '\r') | EOF))* -> pushMode(MediaMode);
EXTENSION_MODE_MINUS: WS? '-';
EXTENSION_MODE_PLUS: WS? '+';

mode MediaMode;
MEDIA_MODE_SPACE: ' ';
MEDIA_MODE_TAB: '\t';
MEDIA_MODE_NEWLINE: NEWLINE;
MEDIA_MODE_CONTENT: ~('<'|' '|'\t'|'\n'|'\r')+;
MEDIA_MODE_BRACKET: '<';
MEDIA_MODE_CLOSE: VOID? '<...>' WS? -> popMode, popMode;

mode DashExtension;
DASH_EXTENSION_CLOSE: WS? '>' WS? '>' (WS? (('\r'? '\n' | '\r') | EOF))* -> pushMode(DashMediaMode);
DASH_EXTENSION_PLUS: WS? '+';
DASH_EXTENSION_MINUS: WS? '-';

mode DashMediaMode;
DASH_MEDIA_MODE_SPACE: ' ';
DASH_MEDIA_MODE_TAB: '\t';
DASH_MEDIA_MODE_NEWLINE: NEWLINE;
DASH_MEDIA_MODE_DASH: '<' WS? '<' (~[>] | '>' ~[>])* '>' WS? '>' -> pushMode(DashMediaModeInner);
DASH_MEDIA_MODE_CONTENT: ~('<'|' '|'\t'|'\n'|'\r')+;
DASH_MEDIA_MODE_BRACKET: '<';
DASH_MEDIA_MODE_CLOSE: VOID? '<...>' WS? -> popMode, popMode, popMode;

mode DashMediaModeInner;
DASH_MEDIA_MODE_INNER_SPACE: ' ';
DASH_MEDIA_MODE_INNER_TAB: '\t';
DASH_MEDIA_MODE_INNER_NEWLINE: NEWLINE;
DASH_MEDIA_MODE_INNER_DASH: '<' WS? '<' (~[>] | '>' ~[>])* '>' WS? '>' -> pushMode(DashMediaModeInner);
DASH_MEDIA_MODE_INNER_CONTENT: ~('<'|' '|'\t'|'\n'|'\r')+;
DASH_MEDIA_MODE_INNER_BRACKET: '<';
DASH_MEDIA_MODE_INNER_CLOSE: '<...>' WS? -> popMode;

mode Header;
HEADER_TITLE: '-'+;
HEADER_CONTENT: (WS? ('<' HEADER_CONTENT WS? '>' | ~('>'|' '|'\t'|'\n'|'\r')+))+;
HEADER_CLOSE: WS? '>' WS? -> popMode;

mode HeaderMode;
HEADER_MODE_TITLE: '-'+;
HEADER_MODE_CONTENT: (WS? ('<' HEADER_MODE_CONTENT WS? '>' | ~('>'|' '|'\t'|'\n'|'\r')+))+;
HEADER_MODE_CLOSE: WS? '>' WS? '>' WS? -> popMode;

mode Link;
REFERENCE_NUMBER: NUMBER;
LINK_CONTENT: (WS? ('[' LINK_CONTENT WS? ']' | ~(']'|' '|'\t'|'\n'|'\r')+))+;
LINK_CLOSE: WS? ']' -> popMode;

mode DirectLink;
DIRECT_LINK_CONTENT: (WS? ('[' DIRECT_LINK_CONTENT WS? ']' | ~(']'|' '|'\t'|'\n'|'\r')+))+;
DIRECT_LINK_CLOSE: WS? ']]' -> popMode;

mode Address;
NOTE_NUMBER: NUMBER;
ADDRESS_CONTENT: (WS? ('[' ADDRESS_CONTENT WS? ']' | ~('|'|']'|' '|'\t'|'\n'|'\r')+))+;
ADDRESS_CLOSE: WS? ']' WS? -> popMode;
ADDRESS_SEPARATOR: WS? '|' WS?;