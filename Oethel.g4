grammar Oethel;

parse:
    NEWLINE*
    (   
        (   comment
        |   title_1 
        |   title_2
        |   title_3
        |   title_4
        |   title_5
        |   title_6
        |   title_7
        |   title_8
        |   title_9
        |   note
        |   block
        )
        NEWLINE*
    )*
    EOF
    ;

block:
    (   header (list | line)
    |   header (NEWLINE+ (list | line) (NEWLINE (list | line))*)* NEWLINE* WS? '>'
    |   (header NEWLINE)? (list | line) (NEWLINE (list | line))* NEWLINE
    );

line:
    (   WS?
        (   comment
        |   reference
        |   media
        |   bold
        |   italic
        |   underline
        |   strikethrough
        |   link
        |   direct_link
        |   address
        |   definition
        |   text
        )
    )+
    ;

text:
    (   WS?
        (   WORD
        |   LINK_BEGIN
        |   ADDRESS_END
        |   LIST_BULLET
        |   LIST_NUMBER
        |   TITLE_1
        |   TITLE_2
        |   TITLE_3
        |   TITLE_4
        |   TITLE_5
        |   TITLE_6
        |   TITLE_7
        |   TITLE_8
        |   TITLE_9
        )
    )+
    ;

bold: BOLD WS? line WS? BOLD;
italic: ITALIC WS? line WS? ITALIC;
underline: UNDERLINE WS? line WS? UNDERLINE;
strikethrough: STRIKETHROUGH WS? line WS? STRIKETHROUGH;

header: HEADER;

title_1: TITLE_1 line;
title_2: TITLE_2 line;
title_3: TITLE_3 line;
title_4: TITLE_4 line;
title_5: TITLE_5 line;
title_6: TITLE_6 line;
title_7: TITLE_7 line;
title_8: TITLE_8 line;
title_9: TITLE_9 line;

link: LINK_BEGIN line link_target;
link_target: LINK_TARGET;
direct_link: DIRECT_LINK;

address: address_name line ADDRESS_END;
address_name: ADDRESS_NAME;
definition: DEFINITION;

reference: LINK_BEGIN line reference_number;
reference_number: REFERENCE_NUMBER;
note: note_number line;
note_number: NOTE;

media: (media_extension? NEWLINE*) media_content;
media_content: MEDIA_CONTENT;
media_extension: MEDIA_EXTENSION;

comment: WS? COMMENT_INLINE | WS? COMMENT_BLOCK WS?;

list locals [int depth = 0]:
    (
        tabs=WS
        {
            $depth = $tabs.getText().length();
        }
    )?
    (   LIST_NUMBER WS? list_ordered[$depth]
    |   LIST_BULLET WS? list_bulleted[$depth]
    )
    ;

list_bulleted [int currentDepth] locals [int depth, boolean ordered = false, boolean stop = false]:
    line
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            {
                $depth = $tabs.getText().length();
            }
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        WS?
        (   { $depth > $currentDepth }?
                (   { $ordered }?
                        subo=sublist_ordered[$depth]
                        (
                            { $subo.returnDepth >= 0 }?
                                line
                        )?
                |   { !$ordered }?
                        subb=sublist_bulleted[$depth]
                        (
                            { $subb.returnDepth >= 0 }?
                                line
                        )?
                )
        |   { $depth <= $currentDepth }?
                (   { $ordered }?
                        subo=sublist_ordered[$depth]
                        (
                            { $subo.returnDepth >= 0 }?
                                line
                        )?
                |   { !$ordered }?
                        line
                )
        )
    )*
    ;

sublist_bulleted [int currentDepth] returns [int returnDepth = -1] locals [int depth, boolean ordered = false]:
    line
    (
        { $returnDepth < 0 }?
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            {
                $depth = $tabs.getText().length();
            }
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        (   { $depth > $currentDepth }?
                (   { $ordered }?
                        subo=sublist_ordered[$depth]
                        (
                            { $subo.returnDepth >= $currentDepth }?
                                line
                        |   { $subo.returnDepth < $currentDepth }?
                                { $returnDepth = $subo.returnDepth; }
                        )
                |   { !$ordered }?
                        subb=sublist_bulleted[$depth]
                        (
                            { $subb.returnDepth >= $currentDepth }?
                                line
                        |   { $subb.returnDepth < $currentDepth }?
                                { $returnDepth = $subb.returnDepth; }
                        )
                )
        |   { $depth == $currentDepth }?
                (   { $ordered }?
                        subo=sublist_ordered[$depth]
                        (
                            { $subo.returnDepth >= $currentDepth }?
                                line
                        |   { $subo.returnDepth < $currentDepth }?
                                { $returnDepth = $subo.returnDepth; }
                        )
                |   { !$ordered }?
                        line
                )
        |   { $depth < $currentDepth }?
                { $returnDepth = $depth; }
        )
    )*
    ;

list_ordered [int currentDepth] locals [int depth, boolean ordered = false, boolean stop = false]:
    line
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            {
                $depth = $tabs.getText().length();
            }
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        (   { $depth > $currentDepth }?
                (   { $ordered }?
                        subo=sublist_ordered[$depth]
                        (
                            { $subo.returnDepth >= 0 }?
                                line
                        )?
                |   { !$ordered }?
                        subb=sublist_bulleted[$depth]
                        (
                            { $subb.returnDepth >= 0 }?
                                line
                        )?
                )
        |   { $depth <= $currentDepth }?
                (   { !$ordered }?
                        subb=sublist_bulleted[$depth]
                        (
                            { $subb.returnDepth >= 0 }?
                                line
                        )?
                |   { $ordered }?
                        line
                )
        )
    )*
    ;

sublist_ordered [int currentDepth] returns [int returnDepth = -1] locals [int depth, boolean ordered = false]:
    line
    (
        { $returnDepth < 0 }?
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            {
                $depth = $tabs.getText().length();
            }
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        (   { $depth > $currentDepth }?
                (   { $ordered }?
                        subo=sublist_ordered[$depth]
                        (
                            { $subo.returnDepth >= $currentDepth }?
                                line
                        |   { $subo.returnDepth < $currentDepth }?
                                { $returnDepth = $subo.returnDepth; }
                        )
                |   { !$ordered }?
                        subb=sublist_bulleted[$depth]
                        (
                            { $subb.returnDepth >= $currentDepth }?
                                line
                        |   { $subb.returnDepth < $currentDepth }?
                                { $returnDepth = $subb.returnDepth; }
                        )
                )
        |   { $depth == $currentDepth }?
                (   { !$ordered }?
                        subb=sublist_bulleted[$depth]
                        (
                            { $subb.returnDepth >= $currentDepth }?
                                line
                        |   { $subb.returnDepth < $currentDepth }?
                                { $returnDepth = $subb.returnDepth; }
                        )
                |   { $ordered }?
                        line
                )
        |   { $depth < $currentDepth }?
                { $returnDepth = $depth; }
        )
    )*
    ;

NEWLINE: WS? (('\r'? '\n' | '\r') | EOF);
WS: (' ' | '\t')+;

COMMENT_BLOCK: '~~~~' .*? '~~~~'
    {
        String s = getText();
        setText(s.substring(3, s.length() - 3).trim());
    };

COMMENT_INLINE: '~~' WS? ~[\n\r]*
    {
        String s = getText();
        setText(s.substring(2, s.length()).trim());
    };

MEDIA_CONTENT: WS? '{' VOID? (MEDIA_CONTENT | ~[{}])* VOID? '}' WS?
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };

MEDIA_EXTENSION: WS? '<' WS? ('.'[a-zA-Z0-9]+)+ WS? '>' WS?
    {
        String s = getText().trim();
        s = s.substring(1, s.length() - 1).trim();
        setText(s.substring(1, s.length()).trim());
    };

HEADER: WS? '<' WS? ID WS? '>' WS?
    {
        String s = getText().trim();
        setText(s.substring(1, s.length() - 1).trim());
    };

TITLE_1: WS? '->' WS?;
TITLE_2: WS? '-->' WS?;
TITLE_3: WS? '--->' WS?;
TITLE_4: WS? '---->' WS?;
TITLE_5: WS? '----->' WS?;
TITLE_6: WS? '------>' WS?;
TITLE_7: WS? '------->' WS?;
TITLE_8: WS? '-------->' WS?;
TITLE_9: WS? '--------->' WS?;

LIST_BULLET: '-' WS?;
LIST_NUMBER: ([0-9$])+ WS? '-' WS?;

NOTE: WS? '@[' WS? ([0-9$]+) WS? ']' WS?
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

REFERENCE_NUMBER: WS? '][' WS? ([0-9$]+) WS? ']'
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

LINK_TARGET: WS? '][' WS? ~('['|']')+ WS? ']'
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 1).trim());
    };

DIRECT_LINK: WS? '[[' WS? ~('['|']')+ WS? ']]' WS?
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 2).trim());
    };

ADDRESS_NAME: '@[' WS? ~('['|']')+ WS? '][' WS?
    {
        String s = getText().trim();
        setText(s.substring(2, s.length() - 2).trim());
    };

DEFINITION: WS? '@[[' WS? ~('['|']')+ WS? ']]' WS?
    {
        String s = getText().trim();
        setText(s.substring(3, s.length() - 2).trim());
    };

LINK_BEGIN: '[' WS?;
ADDRESS_END: WS? ']';

BOLD: '**';
ITALIC: '//';
UNDERLINE: '__';
STRIKETHROUGH: '--';

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