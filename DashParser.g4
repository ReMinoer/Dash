parser grammar DashParser;

options { tokenVocab=DashLexer; }

/*

-> TO-DO

- New line mode ?
- White space counter (tabulation as 4 spaces)
- Try refactor lists

*/

/*<#>*/
@members
{
private int whiteSpaceSize(String whiteSpace) {
    int size = 0;
    for (char c: whiteSpace.toCharArray())
        switch (c) {
            case ' ': size++; break;
            case '\t': size += 4; break;
        }
    return size;
}
}
/*<csharp>
@members
{
private int WhiteSpaceSize(string whiteSpace) {
    int size = 0;
    foreach (char c in whiteSpace)
        switch (c) {
            case ' ': size++; break;
            case '\t': size += 4; break;
        }
    return size;
}
}
*/

parse:
    NEWLINE*
    (   
        (   comment_block
        |   comment_inline
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
    (   header (list | line) NEWLINE
    |   header (NEWLINE+ (list | line) (NEWLINE (list | line))*)* NEWLINE* WS? BLOCK_CLOSE
    |   (header NEWLINE)? (list | line) (NEWLINE (list | line))*
    );

line:
    (   WS?
        (   comment_block
        |   comment_inline
        |   reference
        |   media
        |   bold
        |   italic
        |   underline
        |   strikethrough
        |   link
        |   direct_link
        |   address
        |   text
        )
    )+
    ;

text:
    (   WS?
        (   WORD
        |   BLOCK_CLOSE
        |   COMMENT_BLOCK_OPEN
        |   COMMENT_INLINE_OPEN
        |   MEDIA_OPEN
        |   EXTENSION_OPEN
        |   HEADER_OPEN
        |   TITLE_1
        |   TITLE_2
        |   TITLE_3
        |   TITLE_4
        |   TITLE_5
        |   TITLE_6
        |   TITLE_7
        |   TITLE_8
        |   TITLE_9
        |   LIST_BULLET
        |   LIST_NUMBER
        |   LINK_OPEN
        |   BRACKET_CLOSE
        |   ADDRESS_OPEN
        |   BOLD
        |   ITALIC
        |   UNDERLINE
        |   STRIKETHROUGH
        |   COMMENT_BLOCK_CONTENT
        |   COMMENT_INLINE_CONTENT
        |   COMMENT_INLINE_CONTENT
        |   MEDIA_CONTENT
        |   EXTENSION_MINUS
        |   EXTENSION_PLUS
        |   EXTENSION_CONTENT
        |   HEADER_CONTENT
        |   REFERENCE_NUMBER
        |   LINK_CONTENT
        |   DIRECT_LINK_CONTENT
        |   NOTE_NUMBER
        |   ADDRESS_SEPARATOR
        |   ADDRESS_CONTENT
        |   ADDRESS_CLOSE
        )
    )+
    ;

bold: BOLD WS? line WS? BOLD;
italic: ITALIC WS? line WS? ITALIC;
underline: UNDERLINE WS? line WS? UNDERLINE;
strikethrough: STRIKETHROUGH WS? line WS? STRIKETHROUGH;

header: HEADER_OPEN header_content HEADER_CLOSE;
header_content: HEADER_CONTENT;

title_1: TITLE_1 line;
title_2: TITLE_2 line;
title_3: TITLE_3 line;
title_4: TITLE_4 line;
title_5: TITLE_5 line;
title_6: TITLE_6 line;
title_7: TITLE_7 line;
title_8: TITLE_8 line;
title_9: TITLE_9 line;

link: LINK_OPEN line LINK_MIDDLE link_content LINK_CLOSE;
link_content: LINK_CONTENT;
direct_link: DIRECT_LINK_OPEN direct_link_content DIRECT_LINK_CLOSE;
direct_link_content: DIRECT_LINK_CONTENT;

address: ADDRESS_OPEN address_content (ADDRESS_SEPARATOR address_content)* ADDRESS_CLOSE;
address_content: ADDRESS_CONTENT;

reference: LINK_OPEN line LINK_MIDDLE reference_number LINK_CLOSE;
reference_number: REFERENCE_NUMBER;

note: ADDRESS_OPEN note_number ADDRESS_CLOSE line;
note_number: NOTE_NUMBER;

media: (EXTENSION_OPEN media_extension (extension_plus | extension_minus)? EXTENSION_CLOSE NEWLINE?)? MEDIA_OPEN media_content MEDIA_CLOSE;
media_content: MEDIA_CONTENT;
media_extension: EXTENSION_CONTENT;
extension_plus: EXTENSION_PLUS;
extension_minus: EXTENSION_MINUS;

comment_inline: COMMENT_INLINE_OPEN comment_inline_content COMMENT_INLINE_CLOSE;
comment_inline_content: COMMENT_INLINE_CONTENT;
comment_block: COMMENT_BLOCK_OPEN comment_block_content COMMENT_BLOCK_CLOSE;
comment_block_content: COMMENT_BLOCK_CONTENT;

list locals [int depth = 0]:
    (
        tabs=WS
        /*<#>*/ { $depth = whiteSpaceSize($tabs.getText()); }
        /*<csharp> { $depth = WhiteSpaceSize($tabs.Text); } */
    )?
    (   LIST_NUMBER WS? list_ordered[$depth]
    |   LIST_BULLET WS? list_bulleted[$depth]
    )
    ;

list_bulleted [int currentDepth] locals /*<#>*/ [int depth, boolean ordered = false, boolean stop = false] /* <csharp> [int depth, bool ordered = false, bool stop = false] */:
    line
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<#>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.Text); } */
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
            /*<#>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.Text); } */
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
            /*<#>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.Text); } */
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
            /*<#>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.Text); } */
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