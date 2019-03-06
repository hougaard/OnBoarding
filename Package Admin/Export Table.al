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
        http: HttpClient;
        Content: HttpContent;
        response: HttpResponseMessage;
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
        Content.WriteFrom(PackageTxt);
        if http.Post('http://10.3.1.13:9999/' +
                          PackageID + '_' +
                          Country + '_' +
                          VersionTxt, Content, response) then begin
            if response.HttpStatusCode() <> 200 then
                ERROR('Cannot contact package receiver');
        end;
        //MEssage('Json=%1', PackageTxt);
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
                JA.Insert(i, RecToJson(T, true));
                i += 1;
            until T.Next = 0;
        O.Add('T' + FORMAT(TableNo), JA);
        exit(O);
    end;

    procedure RecToJson(R: RecordRef; HandleTags: Boolean): JsonObject
    var
        J: JsonObject;
        f: FieldRef;
        i: Integer;
        GL: Record "G/L Account";
        NS: Record "No. Series";
        RecRef: RecordRef;
    begin
        for i := 1 to R.FieldCount() do begin
            f := R.FieldIndex(i);
            if HandleTags then begin
                case F.Relation() of
                    15:
                        begin
                            if GL.GET(f.Value) then begin
                                // J.Add('f' + format(f.Number()),
                                //         '@G(' +
                                //         GL."No." +
                                //         ',' +
                                //         GL.Name + ')');
                                RecRef.GetTable(GL);
                                J.Add('f' + format(f.Number()), RecToJson(RecRef, false));
                            end else
                                J.Add('f' + format(f.Number()),
                                        '@G(f' +
                                        format(f.Number) +
                                        ',' +
                                        f.Caption() + ')');
                        END;
                    308:
                        begin
                            if NS.Get(f.Value) then begin
                                // J.Add('f' + format(f.Number()),
                                //         '@N(' +
                                //         Ns.Code +
                                //         ',' +
                                //         NS.Description + ')')
                                RecRef.GetTable(NS);
                                J.Add('f' + format(f.Number()), RecToJson(RecRef, false));
                            end else
                                J.Add('f' + format(f.Number()),
                                        '@N(f' +
                                        format(f.Number) +
                                        ',' +
                                        f.Caption() + ')');
                        end;
                    else
                        J.Add('f' + format(f.Number()), format(f.Value));
                end;
            end else
                J.Add('f' + format(f.Number()), format(f.Value));
        end;
        exit(J);
    end;
}