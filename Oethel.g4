grammar Oethel;

parse
    :   (block (NEWLINE NEWLINE+ block)*)? EOF
    ;

block
    :   TEXT (NEWLINE TEXT)*
    ;

TEXT
    :
    (   '\u0000'..'\u0009'  // Skip 0A '\n'
    |   '\u000B'..'\u000C'  // Skip 0D '\r'
    |   '\u000E'..'\uFFFF'
    )+
    ;

NEWLINE : '\r'? '\n' | '\r';