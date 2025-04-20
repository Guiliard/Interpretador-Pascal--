unit type_token_unit;

interface

type 
    typeToken = (

        // Arithmetic operators
        _ADD_,              // +
        _SUB_,              // -
        _MUL_,              // *
        _REAL_DIV_,         // /
        _MOD_,              // mod
        _INTER_DIV_,        // div

        // Logic operators
        _OR_,               // or
        _AND_,              // and
        _NOT_,              // not
        _EQUAL_,            // =
        _DOUBLE_EQUAL_,     // ==
        _NOT_EQUAL_,        // <>
        _GREATER_,          // >
        _GREATER_EQUAL_,    // >=
        _LOWER_,            // <
        _LOWER_EQUAL_,      // <=
        _ASSIGN_,           // :=

        // Keywords
        _PROGRAM_,          // program
        _VAR_,              // var
        _INTEGER_,          // integer
        _REAL_,             // real
        _STRING_,           // string
        _BEGIN_,            // begin
        _END_,              // end
        _FOR_,              // for
        _TO_,               // to
        _WHILE_,            // while
        _DO_,               // do
        _BREAK_,            // break
        _CONTINUE_,         // continue
        _IF_,               // if
        _ELSE_,             // else
        _THEN_,             // then
        _WRITE_,            // write
        _WRITELN_,          // writeln
        _READ_,             // read
        _READLN_,           // readln

        // Symbols
        _SEMICOLON_,        // ;
        _COMMA_,            // ,
        _DOT_,              // .
        _COLON_,            // :
        _LEFT_PAREN_,       // (
        _RIGHT_PAREN_,      // )

        // Others
        _VARIABLE_,         // variable
        _HEXADECIMAL_,      // hexadecimal
        _OCTAL_,            // octal
        _DECIMAL_,          // decimal
        _FLOAT_,            // float
        _STRING_LITERAL_,   // string literal
	    _INVALID_TOKEN_,    // invalid token
	    _END_OF_FILE_       // end of file
    );

implementation

end.