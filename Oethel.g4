grammar Oethel;

parse
    :   block* EOF
    ;

block
    :   line+ NEWLINE*
    ;

line
    :   TEXT NEWLINE?
    ;

TEXT
    :
    (   '\u0000'..'\u0009'  // Skip '\n'
    |   '\u000B'..'\u000C'  // Skip '\r'
    |   '\u000E'..'\uFFFF'
    )+
    ;

NEWLINE : '\r'? '\n' | '\r';