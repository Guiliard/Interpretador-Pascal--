unit intermediate_code_unit;

interface

type
    intermediate_code = record
        code_type: string;  // Type of operation (e.g., "ASSIGN", "ADD", etc.)
        op1: string;       // First operand
        op2: string;       // Second operand
        op3: string;       // Third operand (often used for result)
        op_type: string;    // Type of operation (e.g., "INTEGER", "REAL", etc.)
    end;

    // Array to store multiple intermediate code instructions
    intermediate_code_array = array of intermediate_code;

implementation

end.