codeunit 92100 "Onboarding Package Export"
{
    procedure xx(PackageID: Text;
                 Description: Text;
                 Author: Text;
                 Country: Text;
                 VersionTxt: Text;
                 TableFilter: Text)
    var
        J: JsonObject;
        Token: JsonToken;
        Info: JsonObject;
        TJA: JsonArray;
        T: Record AllObjWithCaption;
        i: Integer;
        PackageTxt: Text;
    begin
        T.SETRANGE("Object Type", T."Object Type"::Table);
        T.SETFILTER("Object ID", TableFilter);
        if T.FINDSET THEN
            repeat
                TJA.Insert(i, TableToJson(T."Object ID"));
                i += 1;
            until T.NEXT = 0;
        J.Add('Tables', TJA);
        Info.Add('ID', PackageID);
        Info.Add('Description', Description);
        Info.Add('Author', Author);
        Info.Add('Country', Country);
        Info.Add('Version', VersionTxt);
        J.Add('Info', Info);
        J.AsToken().WriteTo(PackageTxt);
        MEssage('Json=%1', PackageTxt);
    end;

    procedure TableToJson(TableNo: Integer): JsonObject
    var
        T: RecordRef;
        JA: JsonArray;
        i: Integer;
        O: JsonObject;
    begin
        T.OPEN(TableNo);
        if T.FINDSET then
            repeat
                JA.Insert(i, RecToJson(T));
                i += 1;
            until T.Next = 0;
        O.Add('T' + FORMAT(TableNo), JA);
        exit(O);
    end;

    procedure RecToJson(R: RecordRef): JsonObject
    var
        J: JsonObject;
        f: FieldRef;
        i: Integer;
    begin
        for i := 1 to R.FieldCount() do begin
            f := R.FieldIndex(i);
            case F.Relation() of
                15:
                    begin

                    END;
                308:
                    begin

                    end;
                else
                    J.Add('f' + format(f.Number()), format(f.Value));
            end;
            exit(J);
        end;
}