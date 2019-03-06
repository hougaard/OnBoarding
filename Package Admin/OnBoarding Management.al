codeunit 92101 "OnBoarding Management"
{
    procedure GetPackages()
    var
        http: HttpClient;
        jsonTxt: Text;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
        files: JsonArray;
        fileToken: JsonToken;
        JO: JsonObject;
        filename: Text;
        value: JsonToken;
        Headers: HttpHeaders;
    begin
        request.SetRequestUri('https://api.github.com/repos/hougaard/OnBoardingPackages/contents/');
        request.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365 Business Central');
        request.Method('GET');
        if http.Send(request, response) then begin
            if response.HttpStatusCode() = 200 then begin
                response.Content().ReadAs(jsonTxt);
                files.ReadFrom(jsonTxt);
                foreach fileToken in files do begin
                    JO := fileToken.AsObject();
                    JO.Get('download_url', value);
                    value.WriteTo(filename);
                    if strpos(filename, '.json') <> 0 then begin
                        filename := copystr(filename, 2, strlen(filename) - 2);
                        if http.Get(filename, response) then begin
                            response.Content().ReadAs(jsonTxt);
                            ImportPackage(jsonTxt);
                        end;
                    end;
                end;
            end else
                Error('Cannot read package list, error %1', response.HttpStatusCode());
        end else
            Error('Cannot contact Github');
    end;

    procedure ImportPackage(JsonTxt: Text)
    var
        jPackage: JsonObject;
        jInfoToken: JsonToken;
        jInfo: JsonObject;
        jTables: JsonArray;
        jTablesToken: JsonToken;
        jTableToken: JsonToken;
        jTable: JsonObject;
        Package: Record "OnBoarding Package";
        pTable: Record "OnBoarding Table";
        pField: Record "OnBoarding Field";
        Keys: List of [Text];
        Values: List of [JsonToken];
        TableTxt: Text;
        TableNo: Integer;
        jRecords: JsonArray;
    begin
        Package.DELETEALL;
        pTable.DELETEALL;
        pField.DELETEALL;
        if jPackage.ReadFrom(JsonTxt) then begin
            if jPackage.Get('Info', jInfoToken) then begin
                Package.INIT;
                Package.ID := GetTextFromToken(JInfoToken, 'ID');
                Package.Description := GetTextFromToken(jInfoToken, 'Description');
                Package."Minimum Version" := GetTextFromToken(jInfoToken, 'Version');
                Package.Author := GetTextFromToken(jInfoToken, 'Author');
                Package.Country := GetTextFromToken(jInfoToken, 'Country');
                Package.INSERT;

                if jPackage.Get('Tables', jTablesToken) then begin
                    jTables := jTablesToken.AsArray();
                    foreach jTableToken in jTables do begin
                        jTable := jTableToken.AsObject();
                        Keys := jTable.Keys();
                        Keys.Get(1, TableTxt);
                        EVALUATE(TableNo, copystr(TableTxt, 2));
                        Values := jTable.Values();
                        jRecords := Values.Get(1).AsArray();
                        ImportRecords(Package.ID, TableNo, jRecords);
                    end;
                end;
            end;
        end;
    end;

    procedure ImportRecords(PackageID: Text; TableNo: Integer; jRecords: JsonArray)
    var
        TableRec: Record "OnBoarding Table";
        R: RecordRef;
        jRecordToken: JsonToken;
        jRecord: JsonObject;
        jFieldToken: JsonToken;
        jField: JsonToken;
        RecNo: Integer;
        FieldRec: Record "OnBoarding Field";
        FieldNoTxt: Text;
        FieldNo: Integer;
        Keys: List of [Text];
        Values: List of [JsonToken];
        i: Integer;
    begin
        TableRec.INIT;
        TableRec."Package ID" := PackageID;
        TableRec."Table No." := TableNo;
        R.OPEN(TableNo);
        TableRec.Desciption := R.Caption();
        TableRec.INSERT;
        foreach jRecordToken in jRecords do begin
            RecNo += 1;
            jRecord := jRecordToken.AsObject();
            Keys := jRecord.Keys();
            Values := jRecord.Values();
            for i := 1 to Keys.Count do begin
                FieldRec.INIT;
                FieldRec."Package ID" := PackageID;
                FieldRec."Table No." := TableNo;
                FieldRec."Record No." := RecNo;
                jField := Values.Get(i);
                Keys.Get(i, FieldNoTxt);
                Evaluate(FieldNo, copystr(FieldNoTxt, 2));
                FieldRec."Field No." := FieldNo;
                FieldRec."Field Value" := jField.AsValue().AsText();
                FieldRec.INSERT;
            end;
        end;
    end;

    procedure GetTextFromToken(T: JsonToken; Member: Text): Text
    var
        O: JsonObject;
        V: JsonToken;
        Data: Text;
    begin
        O := T.AsObject();
        O.Get(Member, V);
        V.WriteTo(Data);
        EXIT(copystr(Data, 2, strlen(Data) - 2));
    end;

    procedure RunTheProcess()
    var
        Step1: Page "OnBoarding Step 1";
        Step2: Page "OnBoarding Step 2";
        Modules: Record "OnBoarding Modules";
        Packages: Record "OnBoarding Package";
        PF: Record "OnBoarding Field";
    begin
        RefreshModules();
        RefreshPackages();
        COMMIT;

        Step1.Editable(true);
        Step1.RunModal();
        Modules.SETRANGE(Select, true);
        if not Modules.IsEmpty() THEN BEGIN
            if Modules.FINDFIRST then
                repeat
                    Packages.Setrange(Module, Modules."Module ID");
                    Step2.SetRecord(Packages);
                    Step2.Editable(true);
                    Step2.SetCaption(Modules.Description);
                    Step2.RunModal();
                    COMMIT;
                until Modules.NEXT = 0;
        END else
            Error('No modules selected, aborting');
        Packages.reset;
        packages.Setrange(Select, true);
        if not packages.IsEmpty() then begin
            // Loop Through selected packages:
            // - Locate accounts
            // - Locate number series
            // - Dates?
            if Packages.findset then
                repeat
                    PF.Setrange("Package ID", packages.ID);
                    pf.Setrange("Record No.", 1);
                    if pf.findset then
                        repeat
                        //if pf
                        until pf.next = 0;
                until Packages.next = 0;
        end else
            error('No packages selected, aborting');
    end;

    procedure RefreshPackages()
    var
        Package: Record "OnBoarding Package";
    begin
        Package.DELETEALL;
        // Refresh from web services
        Package.INIT;
        Package."Module" := 'FIN';
        Package.Description := 'Base Finance setup';
        Package.ID := 'FIN';
        Package.Author := 'Microsoft';
        Package.Country := 'NA';
        Package."Minimum Version" := '13.0.0.0';
        Package.INSERT;
    end;

    procedure RefreshModules()
    var
        Modules: Record "OnBoarding Modules";
    begin
        Modules.DELETEALL;

        Modules.INIT;
        Modules."Module ID" := 'FIN';
        Modules."Select" := false;
        Modules.Description := 'Financial Management';
        Modules.INSERT;

        Modules.INIT;
        Modules."Module ID" := 'SALE';
        Modules."Select" := false;
        Modules.Description := 'Sales and Account Receivables';
        Modules.INSERT;

        Modules.INIT;
        Modules."Module ID" := 'PURCHASE';
        Modules."Select" := false;
        Modules.Description := 'Purchase and Account Payables';
        Modules.INSERT;

        Modules.INIT;
        Modules."Module ID" := 'INVENTORY';
        Modules."Select" := false;
        Modules.Description := 'Inventory';
        Modules.INSERT;

    end;
}