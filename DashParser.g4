parser grammar DashParser;

options { tokenVocab=DashLexer; }

/* TO-DO
- Target conditions
- Back to line mode
- Media inline
- Unit tests
- Handle empty content
- Use line separator for header mode and media
- Try refactor lists
*/

/*<>*/
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
    ( documentTitle NEWLINE* )*
    (   
        (   commentBlock
        |   commentInline
        |   headerMode
        |   extensionMode
        |   dashExtensionMode
        |   MODE_CLOSE
        |   (   redirection
            |   note
            |   paragraph
            )
            (NEWLINE | WS? EOF)
        )
        NEWLINE*
    )*
    WS? EOF
    ;

documentTitle: HEADER_OPEN HEADER_CLOSE NEWLINE? line;
paragraph: (titleHeader | header) line | NEWLINE ((titleHeader | header) NEWLINE)? ((list | line) (NEWLINE (headerMode | list | line))*)? MODE_CLOSE?;

line:
    (   WS?
        (   commentBlock
        |   commentInline
        |   reference
        |   media
        |   bold
        |   italic
        |   mark
        |   obsolete
        |   emphasis
        |   link
        |   directLink
        |   address
        |   text
        |   others
        )
    )+
    ;

emphasisLine:
    (   WS?
        (   commentBlock
        |   commentInline
        |   reference
        |   media
        |   bold
        |   italic
        |   mark
        |   obsolete
        |   emphasis
        |   link
        |   directLink
        |   address
        |   text
        |   emphasisOthers
        )
    )+
    ;

linkLine:
    (   WS?
        (   commentBlock
        |   commentInline
        |   reference
        |   media
        |   bold
        |   italic
        |   mark
        |   obsolete
        |   emphasis
        |   link
        |   directLink
        |   address
        |   text
        |   linkOthers
        )
    )+
    ;

text: (WS? WORD)+;

others:
    (   COMMENT_BLOCK_OPEN
    |   COMMENT_INLINE_OPEN
    |   MEDIA_OPEN
    |   EXTENSION_OPEN
    |   HEADER_OPEN
    |   HEADER_MODE_OPEN
    |   LIST_BULLET
    |   LIST_NUMBER
    |   SELECTION_OPEN
    |   SELECTION_CLOSE
    |   BOLD_OPEN
    |   ITALIC_OPEN
    |   MARK_OPEN
    |   OBSOLETE_OPEN
    |   LINK_MIDDLE
    |   DIRECT_LINK_OPEN
    |   ADDRESS_OPEN
    |   COMMENT_BLOCK_CONTENT
    |   COMMENT_BLOCK_CLOSE
    |   COMMENT_INLINE_CONTENT
    |   COMMENT_INLINE_CLOSE
    |   MEDIA_CONTENT
    |   MEDIA_BRACES_OPEN
    |   MEDIA_CLOSE
    |   EXTENSION_CONTENT
    |   EXTENSION_CLOSE
    |   EXTENSION_MINUS
    |   EXTENSION_PLUS
    |   HEADER_CONTENT
    |   HEADER_CLOSE
    |   HEADER_MODE_CONTENT
    |   HEADER_MODE_CLOSE
    |   LINK_CONTENT
    |   REFERENCE_NUMBER
    |   LINK_CLOSE
    |   DIRECT_LINK_CONTENT
    |   DIRECT_LINK_CLOSE
    |   ADDRESS_CONTENT
    |   NOTE_NUMBER
    |   ADDRESS_CLOSE
    |   ADDRESS_SEPARATOR
    );

// Without SELECTION_CLOSE
emphasisOthers:
    (   COMMENT_BLOCK_OPEN
    |   COMMENT_INLINE_OPEN
    |   MEDIA_OPEN
    |   EXTENSION_OPEN
    |   HEADER_OPEN
    |   HEADER_MODE_OPEN
    |   LIST_BULLET
    |   LIST_NUMBER
    |   SELECTION_OPEN
    |   BOLD_OPEN
    |   ITALIC_OPEN
    |   MARK_OPEN
    |   OBSOLETE_OPEN
    |   LINK_MIDDLE
    |   DIRECT_LINK_OPEN
    |   ADDRESS_OPEN
    |   COMMENT_BLOCK_CONTENT
    |   COMMENT_BLOCK_CLOSE
    |   COMMENT_INLINE_CONTENT
    |   COMMENT_INLINE_CLOSE
    |   MEDIA_CONTENT
    |   MEDIA_BRACES_OPEN
    |   MEDIA_CLOSE
    |   EXTENSION_CONTENT
    |   EXTENSION_CLOSE
    |   EXTENSION_MINUS
    |   EXTENSION_PLUS
    |   HEADER_CONTENT
    |   HEADER_CLOSE
    |   HEADER_MODE_CONTENT
    |   HEADER_MODE_CLOSE
    |   LINK_CONTENT
    |   REFERENCE_NUMBER
    |   LINK_CLOSE
    |   DIRECT_LINK_CONTENT
    |   DIRECT_LINK_CLOSE
    |   ADDRESS_CONTENT
    |   NOTE_NUMBER
    |   ADDRESS_CLOSE
    |   ADDRESS_SEPARATOR
    );

// Without LINK_MIDDLE
linkOthers: 
    (   COMMENT_BLOCK_OPEN
    |   COMMENT_INLINE_OPEN
    |   MEDIA_OPEN
    |   EXTENSION_OPEN
    |   HEADER_OPEN
    |   HEADER_MODE_OPEN
    |   LIST_BULLET
    |   LIST_NUMBER
    |   SELECTION_OPEN
    |   SELECTION_CLOSE
    |   BOLD_OPEN
    |   ITALIC_OPEN
    |   MARK_OPEN
    |   OBSOLETE_OPEN
    |   DIRECT_LINK_OPEN
    |   ADDRESS_OPEN
    |   COMMENT_BLOCK_CONTENT
    |   COMMENT_BLOCK_CLOSE
    |   COMMENT_INLINE_CONTENT
    |   COMMENT_INLINE_CLOSE
    |   MEDIA_CONTENT
    |   MEDIA_BRACES_OPEN
    |   MEDIA_CLOSE
    |   EXTENSION_CONTENT
    |   EXTENSION_CLOSE
    |   EXTENSION_MINUS
    |   EXTENSION_PLUS
    |   HEADER_CONTENT
    |   HEADER_CLOSE
    |   HEADER_MODE_CONTENT
    |   HEADER_MODE_CLOSE
    |   LINK_CONTENT
    |   REFERENCE_NUMBER
    |   LINK_CLOSE
    |   DIRECT_LINK_CONTENT
    |   DIRECT_LINK_CLOSE
    |   ADDRESS_CONTENT
    |   NOTE_NUMBER
    |   ADDRESS_CLOSE
    |   ADDRESS_SEPARATOR
    );

header: HEADER_OPEN headerContent? HEADER_CLOSE;
titleHeader: HEADER_OPEN HEADER_TITLE HEADER_CLOSE;
headerContent: 
    (   HEADER_CONTENT
    |   HEADER_TITLE
    )+;

headerMode: HEADER_MODE_OPEN headerModeContent? HEADER_MODE_CLOSE;
titleHeaderMode: HEADER_MODE_OPEN HEADER_MODE_TITLE HEADER_MODE_CLOSE;
headerModeContent: 
    (   HEADER_MODE_CONTENT
    |   HEADER_MODE_TITLE
    )+;

bold: BOLD_OPEN emphasisLine SELECTION_CLOSE;
italic: ITALIC_OPEN emphasisLine SELECTION_CLOSE;
mark: MARK_OPEN emphasisLine SELECTION_CLOSE;
obsolete: OBSOLETE_OPEN emphasisLine SELECTION_CLOSE;
emphasis: HEADER_OPEN headerContent HEADER_CLOSE SELECTION_OPEN emphasisLine SELECTION_CLOSE;

link: SELECTION_OPEN linkLine LINK_MIDDLE linkContent LINK_CLOSE;
linkContent: LINK_CONTENT;
directLink: DIRECT_LINK_OPEN directLinkContent DIRECT_LINK_CLOSE;
directLinkContent: DIRECT_LINK_CONTENT;

address: ADDRESS_OPEN addressContent (ADDRESS_SEPARATOR addressContent)* ADDRESS_CLOSE;
addressContent: ADDRESS_CONTENT;

reference: SELECTION_OPEN linkLine LINK_MIDDLE referenceNumber LINK_CLOSE;
referenceNumber: REFERENCE_NUMBER;

note: ADDRESS_OPEN noteNumber ADDRESS_CLOSE line;
redirection: ADDRESS_OPEN noteNumber ADDRESS_CLOSE DIRECT_LINK_OPEN directLinkContent DIRECT_LINK_CLOSE;
noteNumber: NOTE_NUMBER;

media: (EXTENSION_OPEN mediaExtension (EXTENSION_PLUS | EXTENSION_MINUS)* EXTENSION_CLOSE NEWLINE?)? MEDIA_OPEN mediaContent? MEDIA_CLOSE;
mediaExtension: ((EXTENSION_PLUS | EXTENSION_MINUS)* EXTENSION_CONTENT)*;
mediaContent: (MEDIA_CONTENT | MEDIA_BRACES_OPEN | MEDIA_CLOSE)+;

extensionMode: EXTENSION_MODE_OPEN extensionModeExtension (EXTENSION_MODE_PLUS | EXTENSION_MODE_MINUS)* EXTENSION_MODE_CLOSE extensionModeContent? MEDIA_MODE_CLOSE;
extensionModeExtension: ((EXTENSION_MODE_PLUS | EXTENSION_MODE_MINUS)* EXTENSION_MODE_CONTENT)*;
extensionModeContent: (MEDIA_MODE_CONTENT | MEDIA_MODE_BRACKET)+;

dashExtensionMode: EXTENSION_MODE_OPEN EXTENSION_MODE_DASH (DASH_EXTENSION_PLUS | DASH_EXTENSION_MINUS)* DASH_EXTENSION_CLOSE dashExtensionModeContent? DASH_MEDIA_MODE_CLOSE;
dashExtensionModeContent:
    (   DASH_MEDIA_MODE_CONTENT
    |   DASH_MEDIA_MODE_BRACKET
    |   DASH_MEDIA_MODE_CLOSE
    |   DASH_MEDIA_MODE_DASH
    |   DASH_MEDIA_MODE_INNER_CONTENT
    |   DASH_MEDIA_MODE_INNER_BRACKET
    |   DASH_MEDIA_MODE_INNER_CLOSE
    |   DASH_MEDIA_MODE_INNER_DASH
    )+
    ;

commentInline: COMMENT_INLINE_OPEN commentInlineContent COMMENT_INLINE_CLOSE;
commentInlineContent: COMMENT_INLINE_CONTENT;
commentBlock: COMMENT_BLOCK_OPEN commentBlockContent COMMENT_BLOCK_CLOSE;
commentBlockContent: COMMENT_BLOCK_CONTENT;

list locals [int depth = 0]:
    (
        tabs=WS
        /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
        /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
    )?
    (   LIST_NUMBER WS? listOrdered[$depth]
    |   LIST_BULLET WS? listBulleted[$depth]
    )
    ;

listBulleted [int currentDepth] locals /*<>*/ [int depth, boolean ordered = false] /* <csharp> [int depth, bool ordered = false] */:
    line
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        WS?
        (   { $ordered }?
                subo=sublistOrdered[$depth]
                (
                    { $subo.returnDepth >= 0 }?
                        line
                )?
        |   { !$ordered && $depth > $currentDepth }?
                subb=sublistBulleted[$depth]
                (
                    { $subb.returnDepth >= 0 }?
                        line
                )?
        |   { !$ordered && $depth <= $currentDepth }?
                line?
        )
    )*
    ;

sublistBulleted [int currentDepth] returns [int returnDepth = -1] locals /*<>*/ [int depth, boolean ordered = false] /* <csharp> [int depth, bool ordered = false] */:
    line
    (
        { $returnDepth < 0 }?
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        (   { $ordered && $depth >= $currentDepth }?
                subo=sublistOrdered[$depth]
                (
                    { $subo.returnDepth >= $currentDepth }?
                        line
                |   { $subo.returnDepth < $currentDepth }?
                        { $returnDepth = $subo.returnDepth; }
                )
        |   { !$ordered && $depth > $currentDepth }?
                subb=sublistBulleted[$depth]
                (
                    { $subb.returnDepth >= $currentDepth }?
                        line
                |   { $subb.returnDepth < $currentDepth }?
                        { $returnDepth = $subb.returnDepth; }
                )
        |   { !$ordered && $depth == $currentDepth }?
                line
        |   { $depth < $currentDepth }?
                { $returnDepth = $depth; }
        )
    )*
    ;

listOrdered [int currentDepth] locals /*<>*/ [int depth, boolean ordered = false] /* <csharp> [int depth, bool ordered = false] */:
    line
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        (   { !$ordered }?
                subb=sublistBulleted[$depth]
                (
                    { $subb.returnDepth >= 0 }?
                        line
                )?
        |   { $ordered && $depth > $currentDepth }?
                subo=sublistOrdered[$depth]
                (
                    { $subo.returnDepth >= 0 }?
                        line
                )?
        |   { $ordered && $depth <= $currentDepth }?
                line?
        )
    )*
    ;

sublistOrdered [int currentDepth] returns [int returnDepth = -1] locals /*<>*/ [int depth, boolean ordered = false] /* <csharp> [int depth, bool ordered = false] */:
    line
    (
        { $returnDepth < 0 }?
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   LIST_NUMBER { $ordered = true; }
        |   LIST_BULLET
        )
        (   { !$ordered && $depth >= $currentDepth }?
                subb=sublistBulleted[$depth]
                (
                    { $subb.returnDepth >= $currentDepth }?
                        line
                |   { $subb.returnDepth < $currentDepth }?
                        { $returnDepth = $subb.returnDepth; }
                )
        |   { $ordered && $depth > $currentDepth }?
                subo=sublistOrdered[$depth]
                (
                    { $subo.returnDepth >= $currentDepth }?
                        line
                |   { $subo.returnDepth < $currentDepth }?
                        { $returnDepth = $subo.returnDepth; }
                )
        |   { $ordered && $depth == $currentDepth }?
                line
        |   { $depth < $currentDepth }?
                { $returnDepth = $depth; }
        )
    )*
    ;