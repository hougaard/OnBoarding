codeunit 92100 "Onboarding Package Export"
{
    procedure BuildAccountSchedulePackges(Author: Text;
                                          Country: Text;
                                          VersionTxt: Text)
    var
        AS: Record "Acc. Schedule Name";
        J: JsonObject;
        Token: JsonToken;
        Info: JsonObject;
        TJA: JsonArray;
        T: RecordRef;
        F: FieldRef;
        i: Integer;
        PackageTxt: Text;
        http: HttpClient;
        Content: HttpContent;
        response: HttpResponseMessage;
    begin
        if AS.FINDSET then
            repeat
                // Account Schedule
                T.OPEN(84);
                F := T.Field(1);
                F.SetRange(AS.Name);
                TJA.Insert(i, TableRefToJson(T));
                i += 1;
                T.CLOSE();

                // Schedule Line
                T.OPEN(85);
                F := T.Field(1);
                F.SetRange(AS.Name);
                TJA.Insert(i, TableRefToJson(T));
                i += 1;
                T.CLOSE();

                T.OPEN(344); //Column Layout
                F := T.Field(1);
                F.SetRange(AS."Default Column Layout");
                TJA.Insert(i, TableRefToJson(T));
                i += 1;
                T.CLOSE();

                J.Add('Tables', TJA);
                Info.Add('ID', AS.Name);
                Info.Add('Description', AS.Description);
                Info.Add('Author', Author);
                Info.Add('Country', Country);
                Info.Add('Version', VersionTxt);
                J.Add('Info', Info);
                J.AsToken().WriteTo(PackageTxt);
                Content.WriteFrom(PackageTxt);
                if http.Post('http://10.3.1.13:9999/' +
                                AS.Name + '_' +
                                Country + '_' +
                                VersionTxt, Content, response) then begin
                    if response.HttpStatusCode() <> 200 then
                        ERROR('Cannot contact package receiver');
                end;

            until AS.NEXT = 0;
    end;

    procedure BuildPackageAndExportToGitHub(PackageID: Text;
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
    begin
        T.OPEN(TableNo);
        exit(TableRefToJSon(T));
    end;

    procedure TableRefToJson(T: RecordRef): JsonObject
    var
        JA: JsonArray;
        i: Integer;
        O: JsonObject;
    begin
        if T.FINDSET then
            repeat
                JA.Insert(i, RecToJson(T, true));
                i += 1;
            until T.Next = 0;
        O.Add('T' + FORMAT(T.Number), JA);
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
            if f.Class() = FieldClass::Normal then begin
                if HandleTags then begin
                    case F.Relation() of
                        15:
                            begin
                                if GL.GET(f.Value) then begin
                                    RecRef.GetTable(GL);
                                    J.Add('G' + format(f.Number()), GLTagToJson(RecRef));
                                end else
                                    if format(f.value) <> '' then
                                        error('Unknown G/L Account %1 in table %2', f.Value, R.Caption());
                            END;
                        308:
                            begin
                                if NS.Get(f.Value) then begin
                                    J.Add('N' + format(f.Number), NSTagToJson(NS));
                                end else
                                    if format(f.value) <> '' then
                                        error('Unknown Number Series %1 in table %2', f.Value, R.Caption());
                            end;
                        else
                            J.Add('f' + format(f.Number()), format(f.Value));
                    end;
                end else
                    J.Add('f' + format(f.Number()), format(f.Value));
            end;
        end;
        exit(J);
    end;

    procedure NSTagToJson(NS: Record "No. Series"): JsonObject
    var
        J: JsonObject;
        f: FieldRef;
        i: Integer;
        RecRef: RecordRef;
    begin
        J.Add('f1', NS.Code);
        J.Add('f2', NS.Description);
        exit(J);
    end;

    procedure GLTagToJson(R: RecordRef): JsonObject
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
            if f.Class() = FieldClass::Normal then begin
                J.Add('f' + format(f.Number()), format(f.Value));
            end;
        end;
        R.SetTable(GL);
        J.Add('Totals', GetGLAccountGroups(GL));
        exit(J);
    end;

    procedure GetGLAccountGroups(GL: Record "G/L Account"): Text
    // Build a string of all the Total this account is part of
    var
        Before: Record "G/L Account";
        GroupTxt: Text;
        Groups: Array[30] of Text;
        Count: Integer;
        i: Integer;
    begin
        Before.SETFILTER("No.", '..' + GL."No.");
        Before.SETFILTER("Account Type", '%1|%2',
                        Before."Account Type"::"Begin-Total",
                        Before."Account Type"::"End-Total");
        if Before.FINDSET then
            repeat
                if before."Account Type" = before."Account Type"::"Begin-Total" then begin
                    Count += 1;
                    Groups[Count] := before.Name;
                end;
                if (before."Account Type" = before."Account Type"::"End-Total") and
                   (Count > 0) then
                    Count -= 1;
            until Before.NEXT = 0;
        if Count > 0 then
            for i := Count downto 1 do begin
                if GroupTxt <> '' then
                    GroupTxt += ',';
                GroupTxt += Groups[i];
            end;
        exit(GroupTxt);
    end;
}