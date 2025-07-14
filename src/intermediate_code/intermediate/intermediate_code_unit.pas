unit intermediate_code_unit;

interface

type
    intermediate_code = record
        code_type: string;
        op1: string;
        op2: string;
        op3: string;
        op_type: string;
    end;

    intermediate_code_array = array of intermediate_code;

implementation

end.