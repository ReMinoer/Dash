parser grammar DashParser;

options { tokenVocab=DashLexer; }

/* TO-DO
- Fix one line file
- Target conditions
- Alternative text
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
public static final int TabSize = 4;

public static int whiteSpaceSize(String whiteSpace) {
    int size = 0;
    for (char c: whiteSpace.toCharArray())
        switch (c) {
            case ' ': size++; break;
            case '\t': size += TabSize; break;
        }
    return size;
}
}
/*<csharp>
@members
{
public const int TabSize = 4;

public static int WhiteSpaceSize(string whiteSpace) {
    int size = 0;
    foreach (char c in whiteSpace)
        switch (c) {
            case ' ': size++; break;
            case '\t': size += TabSize; break;
        }
    return size;
}
}
*/

parse:
    NEWLINE*
    (documentTitle NEWLINE+)*
    (   
        (   commentBlock
        |   commentInline
        |   headerMode
        |   extensionMode
        |   dashExtensionMode
        |   modeClose
        |   paragraphInline
        |   (   redirection
            |   note
            |   media
            |   paragraph
            )
            (NEWLINE | WS? EOF)
        )
        NEWLINE*
    )
    (   
        (   commentBlock
        |   commentInline
        |   headerMode
        |   extensionMode
        |   dashExtensionMode
        |   modeClose
        |   paragraphInline
        |   (   redirection
            |   note
            |   media
            |   NEWLINE paragraph
            )
            (NEWLINE | WS? EOF)
        )
        NEWLINE*
    )*
    WS? EOF
    ;

documentTitle: HEADER_OPEN HEADER_CLOSE NEWLINE? line;
paragraphInline: (titleHeader | header) WS? (list | line) modeClose?;
paragraph: ((titleHeader | header) NEWLINE)? ((list | line) (NEWLINE (headerMode | list | line))*)? modeClose?;

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

others: ~(WS | WORD | NEWLINE | MODE_CLOSE);
emphasisOthers: ~(WS | WORD | NEWLINE | MODE_CLOSE | SELECTION_CLOSE);
linkOthers: ~(WS | WORD | NEWLINE | MODE_CLOSE | LINK_MIDDLE);

header: HEADER_OPEN headerContent? HEADER_CLOSE;
titleHeader: HEADER_OPEN HEADER_TITLE HEADER_CLOSE;
headerContent: 
    (   HEADER_CONTENT
    |   HEADER_TITLE
    )+;

headerMode: HEADER_MODE_OPEN headerModeContent? HEADER_MODE_CLOSE;
titleHeaderMode: HEADER_MODE_OPEN HEADER_MODE_TITLE HEADER_MODE_CLOSE;
modeClose: MODE_CLOSE;
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

commentInline: COMMENT_INLINE_OPEN commentInlineContent COMMENT_INLINE_CLOSE;
commentInlineContent: COMMENT_INLINE_CONTENT;
commentBlock: COMMENT_BLOCK_OPEN commentBlockContent COMMENT_BLOCK_CLOSE;
commentBlockContent: COMMENT_BLOCK_CONTENT;

media: (EXTENSION_OPEN mediaExtension (EXTENSION_PLUS | EXTENSION_MINUS)* EXTENSION_CLOSE NEWLINE?)? MEDIA_OPEN mediaContent? MEDIA_CLOSE;
mediaExtension: ((EXTENSION_PLUS | EXTENSION_MINUS)* EXTENSION_CONTENT)*;
mediaContent: (MEDIA_CONTENT | MEDIA_BRACES_OPEN | MEDIA_CLOSE)+;

extensionMode: EXTENSION_MODE_OPEN extensionModeExtension (EXTENSION_MODE_PLUS | EXTENSION_MODE_MINUS)* EXTENSION_MODE_CLOSE extensionModeContent MEDIA_MODE_NEWLINE* (MEDIA_MODE_SPACE | MEDIA_MODE_TAB)* MEDIA_MODE_CLOSE;
extensionModeExtension: ((EXTENSION_MODE_PLUS | EXTENSION_MODE_MINUS)* EXTENSION_MODE_CONTENT)*;

extensionModeContent locals [int tabSize = 0, int lineTabSize = 0]:
    (   MEDIA_MODE_SPACE { $tabSize++; }
    |   MEDIA_MODE_TAB { $tabSize += TabSize; }
    )*
    extensionModeLine
    (
        MEDIA_MODE_NEWLINE
        (   { $lineTabSize < $tabSize }?
                (   MEDIA_MODE_SPACE { $lineTabSize++; }
                |   MEDIA_MODE_TAB { $lineTabSize += TabSize; }
                )
        )*
        extensionModeLine { $lineTabSize = 0; }
    )*
    ;

extensionModeLine:
    (   MEDIA_MODE_SPACE
    |   MEDIA_MODE_TAB
    |   MEDIA_MODE_CONTENT
    |   MEDIA_MODE_BRACKET
    )*
    ;

dashExtensionMode: EXTENSION_MODE_OPEN EXTENSION_MODE_DASH (DASH_EXTENSION_PLUS | DASH_EXTENSION_MINUS)* DASH_EXTENSION_CLOSE dashExtensionModeContent DASH_MEDIA_MODE_CLOSE;

dashExtensionModeContent locals [int tabSize = 0, int lineTabSize = 0]:
    (   (DASH_MEDIA_MODE_SPACE | DASH_MEDIA_MODE_INNER_SPACE) { $tabSize++; }
    |   (DASH_MEDIA_MODE_TAB | DASH_MEDIA_MODE_INNER_TAB) { $tabSize += TabSize; }
    )*
    dashExtensionModeLine
    (
        (DASH_MEDIA_MODE_NEWLINE | DASH_MEDIA_MODE_INNER_NEWLINE)
        (   { $lineTabSize < $tabSize }?
                (   (DASH_MEDIA_MODE_SPACE | DASH_MEDIA_MODE_INNER_SPACE) { $lineTabSize++; }
                |   (DASH_MEDIA_MODE_TAB | DASH_MEDIA_MODE_INNER_TAB) { $lineTabSize += TabSize; }
                )
        )*
        dashExtensionModeLine { $lineTabSize = 0; }
    )*
    ;

dashExtensionModeLine:
    (   DASH_MEDIA_MODE_SPACE
    |   DASH_MEDIA_MODE_TAB
    |   DASH_MEDIA_MODE_CONTENT
    |   DASH_MEDIA_MODE_BRACKET
    |   DASH_MEDIA_MODE_CLOSE
    |   DASH_MEDIA_MODE_DASH
    |   DASH_MEDIA_MODE_INNER_SPACE
    |   DASH_MEDIA_MODE_INNER_TAB
    |   DASH_MEDIA_MODE_INNER_CONTENT
    |   DASH_MEDIA_MODE_INNER_BRACKET
    |   DASH_MEDIA_MODE_INNER_CLOSE
    |   DASH_MEDIA_MODE_INNER_DASH
    )*
    ;

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