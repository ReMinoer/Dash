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
        |   (   adressEntry
            |   noteEntry
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
        |   (   adressEntry
            |   noteEntry
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
        |   directLink
        |   link
        |   reference
        |   media
        |   bold
        |   italic
        |   quote
        |   obsolete
        |   emphasis
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
        |   directLink
        |   link
        |   reference
        |   media
        |   bold
        |   italic
        |   quote
        |   obsolete
        |   emphasis
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
        |   directLink
        |   link
        |   reference
        |   media
        |   bold
        |   italic
        |   quote
        |   obsolete
        |   emphasis
        |   address
        |   text
        |   linkOthers
        )
    )+
    ;

text: (WS? WORD)+;

others: ~(WS | WORD | NEWLINE | MODE_CLOSE);
emphasisOthers: ~(WS | WORD | NEWLINE | MODE_CLOSE | SELECTION_CLOSE);
linkOthers:
    ~(  WS
    |   WORD
    |   NEWLINE
    |   MODE_CLOSE
    |   DIRECT_LINK_CLOSE
    |   LINK_CLOSE_NUMBER
    |   LINK_CLOSE
    |   PARAMETER_MIDDLE
    |   REFERENCE_CLOSE_NUMBER
    |   REFERENCE_CLOSE
    );

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
quote: QUOTE_OPEN emphasisLine SELECTION_CLOSE;
obsolete: OBSOLETE_OPEN emphasisLine SELECTION_CLOSE;
emphasis: HEADER_OPEN headerContent HEADER_CLOSE SELECTION_OPEN emphasisLine SELECTION_CLOSE;

link: SELECTION_OPEN linkLine ((PARAMETER_MIDDLE parameter PARAMETER_LINK_CLOSE) | LINK_CLOSE | LINK_CLOSE_NUMBER);
directLink: SELECTION_OPEN linkLine DIRECT_LINK_CLOSE;
reference: SELECTION_OPEN linkLine ((PARAMETER_MIDDLE parameter PARAMETER_REFERENCE_CLOSE) | REFERENCE_CLOSE | REFERENCE_CLOSE_NUMBER);
parameter: PARAMETER_CONTENT;

address: INTERNAL_ADDRESS_OPEN addressContent INTERNAL_ADDRESS_CLOSE;
addressContent: INTERNAL_ADDRESS_CONTENT;

adressEntry: (ADDRESS_ENTRY | ADDRESS_ENTRY_NUMBER) line;
noteEntry: (NOTE_ENTRY | NOTE_ENTRY_NUMBER) line;

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

listItem
    /* <> */ [boolean important]
    /* <csharp> [bool important] */
: line;

list
locals
    /* <> */ [int depth, boolean importantItem]
    /* <csharp> [int depth, bool importantItem] */
:
    (
        tabs=WS
        /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
        /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
    )?
    (   (   LIST_BULLET { $importantItem = false; }
        |   LIST_IMPORTANT_BULLET { $importantItem = true; }
        )
        WS? listBulleted[$depth, $importantItem]
    |   (   LIST_NUMBER { $importantItem = false; }
        |   LIST_IMPORTANT_NUMBER { $importantItem = true; }
        )
        WS? listOrdered[$depth, $importantItem]
    )
    ;

listBulleted
    /* <> */ [int currentDepth, boolean importantItem]
    /* <csharp> [int currentDepth, bool importantItem] */
locals
    /* <> */ [int depth, boolean ordered]
    /* <csharp> [int depth, bool ordered] */
:
    listItem[$importantItem]
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   (   LIST_BULLET { $importantItem = false; $ordered = false; }
            |   LIST_IMPORTANT_BULLET { $importantItem = true; $ordered = false; }
            )
        |   (   LIST_NUMBER { $importantItem = false; $ordered = true; }
            |   LIST_IMPORTANT_NUMBER { $importantItem = true; $ordered = true; }
            )
        )
        WS?
        (   { $ordered }?
                subo=sublistOrdered[$depth, $importantItem]
                (
                    { $subo.returnDepth >= 0 }?
                        listItem[$subo.returnImportant]
                )?
        |   { !$ordered && $depth > $currentDepth }?
                subb=sublistBulleted[$depth, $importantItem]
                (
                    { $subb.returnDepth >= 0 }?
                        listItem[$subb.returnImportant]
                )?
        |   { !$ordered && $depth <= $currentDepth }?
                listItem[$importantItem]?
        )
    )*
    ;

sublistBulleted
    /* <> */ [int currentDepth, boolean importantItem]
    /* <csharp> [int currentDepth, bool importantItem] */
returns
    /* <> */ [int returnDepth = -1, boolean returnImportant]
    /* <csharp> [int returnDepth = -1, bool returnImportant] */
locals
    /* <> */ [int depth, boolean ordered]
    /* <csharp> [int depth, bool ordered] */
:
    listItem[$importantItem]
    (
        { $returnDepth < 0 }?
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   (   LIST_BULLET { $importantItem = false; $ordered = false; }
            |   LIST_IMPORTANT_BULLET { $importantItem = true; $ordered = false; }
            )
        |   (   LIST_NUMBER { $importantItem = false; $ordered = true; }
            |   LIST_IMPORTANT_NUMBER { $importantItem = true; $ordered = true; }
            )
        )
        (   { $ordered && $depth >= $currentDepth }?
                subo=sublistOrdered[$depth, $importantItem]
                (
                    { $subo.returnDepth >= $currentDepth }?
                        listItem[$subo.returnImportant]
                |   { $subo.returnDepth < $currentDepth }?
                        { $returnDepth = $subo.returnDepth; $returnImportant = $subo.returnImportant; }
                )
        |   { !$ordered && $depth > $currentDepth }?
                subb=sublistBulleted[$depth, $importantItem]
                (
                    { $subb.returnDepth >= $currentDepth }?
                        listItem[$subb.returnImportant]
                |   { $subb.returnDepth < $currentDepth }?
                        { $returnDepth = $subb.returnDepth; $returnImportant = $subb.returnImportant; }
                )
        |   { !$ordered && $depth == $currentDepth }?
                listItem[$importantItem]
        |   { $depth < $currentDepth }?
                { $returnDepth = $depth; $returnImportant = $importantItem; }
        )
    )*
    ;

listOrdered
    /* <> */ [int currentDepth, boolean importantItem]
    /* <csharp> [int currentDepth, bool importantItem] */
locals
    /* <> */ [int depth, boolean ordered]
    /* <csharp> [int depth, bool ordered] */
:
    listItem[$importantItem]
    (
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   (   LIST_BULLET { $importantItem = false; $ordered = false; }
            |   LIST_IMPORTANT_BULLET { $importantItem = true; $ordered = false; }
            )
        |   (   LIST_NUMBER { $importantItem = false; $ordered = true; }
            |   LIST_IMPORTANT_NUMBER { $importantItem = true; $ordered = true; }
            )
        )
        (   { !$ordered }?
                subb=sublistBulleted[$depth, $importantItem]
                (
                    { $subb.returnDepth >= 0 }?
                        listItem[$subb.returnImportant]
                )?
        |   { $ordered && $depth > $currentDepth }?
                subo=sublistOrdered[$depth, $importantItem]
                (
                    { $subo.returnDepth >= 0 }?
                        listItem[$subo.returnImportant]
                )?
        |   { $ordered && $depth <= $currentDepth }?
                listItem[$importantItem]?
        )
    )*
    ;

sublistOrdered
    /* <> */ [int currentDepth, boolean importantItem]
    /* <csharp> [int currentDepth, bool importantItem] */
returns
    /* <> */ [int returnDepth = -1, boolean returnImportant]
    /* <csharp> [int returnDepth = -1, bool returnImportant] */
locals
    /* <> */ [int depth, boolean ordered]
    /* <csharp> [int depth, bool ordered] */
:
    listItem[$importantItem]
    (
        { $returnDepth < 0 }?
        NEWLINE
        { $depth = 0; }
        (
            tabs=WS
            /*<>*/ { $depth = whiteSpaceSize($tabs.getText()); }
            /*<csharp> { $depth = WhiteSpaceSize($tabs.text); } */
        )?
        (   (   LIST_BULLET { $importantItem = false; $ordered = false; }
            |   LIST_IMPORTANT_BULLET { $importantItem = true; $ordered = false; }
            )
        |   (   LIST_NUMBER { $importantItem = false; $ordered = true; }
            |   LIST_IMPORTANT_NUMBER { $importantItem = true; $ordered = true; }
            )
        )
        (   { !$ordered && $depth >= $currentDepth }?
                subb=sublistBulleted[$depth, $importantItem]
                (
                    { $subb.returnDepth >= $currentDepth }?
                        listItem[$subb.returnImportant]
                |   { $subb.returnDepth < $currentDepth }?
                        { $returnDepth = $subb.returnDepth; $returnImportant = $subb.returnImportant; }
                )
        |   { $ordered && $depth > $currentDepth }?
                subo=sublistOrdered[$depth, $importantItem]
                (
                    { $subo.returnDepth >= $currentDepth }?
                        listItem[$subo.returnImportant]
                |   { $subo.returnDepth < $currentDepth }?
                        { $returnDepth = $subo.returnDepth; $returnImportant = $subo.returnImportant; }
                )
        |   { $ordered && $depth == $currentDepth }?
                listItem[$importantItem]
        |   { $depth < $currentDepth }?
                { $returnDepth = $depth; $returnImportant = $importantItem; }
        )
    )*
    ;