unit table_token;

interface 

uses
    type_token;

type 
    table = record
        text: string;
        token: typeToken;
    end;

const 
    tableToken: array[0..42] of table = (

        // Arithmetic operators
        (text: '+'; token: _ADD_),
        (text: '-'; token: _SUB_),
        (text: '*'; token: _MUL_),
        (text: '/'; token: _REAL_DIV_),
        (text: 'mod'; token: _MOD_),
        (text: 'div'; token: _INTER_DIV_),

        // Logic operators
        (text: 'or'; token: _OR_),
        (text: 'and'; token: _AND_),
        (text: 'not'; token: _NOT_),
        (text: '='; token: _EQUAL_),
        (text: '=='; token: _DOUBLE_EQUAL_),
        (text: '<>'; token: _NOT_EQUAL_),
        (text: '>'; token: _GREATER_),
        (text: '>='; token: _GREATER_EQUAL_),
        (text: '<'; token: _LOWER_),
        (text: '<='; token: _LOWER_EQUAL_),
        (text: ':='; token: _ASSIGN_),

        // Keywords
        (text: 'program'; token: _PROGRAM_),
        (text: 'var'; token: _VAR_),
        (text: 'integer'; token: _INTEGER_),
        (text: 'real'; token: _REAL_),
        (text: 'string'; token: _STRING_),
        (text: 'begin'; token: _BEGIN_),
        (text: 'end'; token: _END_),
        (text: 'for'; token: _FOR_),
        (text: 'to'; token: _TO_),
        (text: 'while'; token: _WHILE_),
        (text: 'do'; token: _DO_),
        (text: 'break'; token: _BREAK_),
        (text: 'continue'; token: _CONTINUE_),
        (text: 'if'; token: _IF_),
        (text: 'else'; token: _ELSE_),
        (text: 'then'; token: _THEN_),
        (text: 'write'; token: _WRITE_),
        (text: 'writeln'; token: _WRITELN_),
        (text: 'read'; token: _READ_),
        (text: 'readln'; token: _READLN_),

        // Symbols
        (text: ';'; token: _SEMICOLON_),
        (text: ','; token: _COMMA_),
        (text: '.'; token: _DOT_),
        (text: ':'; token: _COLON_),
        (text: '('; token: _LEFT_PAREN_),
        (text: ')'; token: _RIGHT_PAREN_)
    );

implementation

end.