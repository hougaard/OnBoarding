codeunit 70310076 "Onboarding Import COA Hgd"
{
    var
        TotalColumns: Integer;
        TotalRows: Integer;

    trigger OnRun();
    var
        ExcelBuffer: Record "Excel Buffer";
        GL: Record "G/L Account";
        InS: InStream;
        FileName: Text;
        row: Integer;
        //col: Integer;
        ExcelFileLbl: Label 'Chart Of Accounts Excel File';
        IncomeLbl: Label 'income';
    begin
        if UploadIntoStream(ExcelFileLbl, '', '', FileName, InS) then begin
            ExcelBuffer.OpenBookStream(InS, 'Sheet1');
            ExcelBuffer.ReadSheet();
            GetLastRowandColumn(ExcelBuffer);
            row := 1;

            repeat
                row += 1; // First time, skip over headings row

                GL.Init();
                GL.VALIDATE("No.", GetTextCell(ExcelBuffer, row, 1));
                GL.INSERT(TRUE);
                GL.VALIDATE(Name, GetTextCell(ExcelBuffer, row, 2));
                if strpos(lowercase(GetTextCell(ExcelBuffer, row, 3)), IncomeLbl) <> 0 then
                    Gl.VALIDATE("Income/Balance", GL."Income/Balance"::"Income Statement")
                else
                    GL.VALIDATE("Income/Balance", GL."Income/Balance"::"Balance Sheet");
                GL.Modify(True);
            until row = TotalRows;
        end;
    end;

    procedure GetTextCell(var ExcelBuffer: Record "Excel Buffer"; Row: Integer; Col: Integer): Text;
    begin
        ExcelBuffer.GET(Row, Col);
        exit(ExcelBuffer."Cell Value as Text");
    end;

    procedure GetDateCell(var ExcelBuffer: Record "Excel Buffer"; Row: Integer; Col: Integer): Date;
    var
        d: Date;
    begin
        ExcelBuffer.GET(Row, Col);
        Evaluate(d, ExcelBuffer."Cell Value as Text");
        exit(d);
    end;

    procedure GetDecimalCell(var ExcelBuffer: Record "Excel Buffer"; Row: Integer; Col: Integer): Decimal;
    var
        d: Decimal;
    begin
        ExcelBuffer.GET(Row, Col);
        Evaluate(d, ExcelBuffer."Cell Value as Text");
        exit(d);
    end;

    procedure GetLastRowandColumn(var ExcelBuffer: Record "Excel Buffer")
    begin
        ExcelBuffer.SETRANGE("Row No.", 1);
        TotalColumns := ExcelBuffer.COUNT();
        ExcelBuffer.reset();
        IF ExcelBuffer.FINDLAST() THEN
            TotalRows := ExcelBuffer."Row No.";
    end;
}