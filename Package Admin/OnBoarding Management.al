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
                case FieldNoTxt[1] of
                    'f':
                        FieldRec."Field Value" := jField.AsValue().AsText();
                    'G':
                        begin
                            FieldRec."Field Value" := CreateTag(PackageID, 'G', jField);
                        END;
                    'N':
                        begin
                            FieldRec."Field Value" := CreateTag(PackageID, 'N', jField);
                        end;
                end;
                FieldRec.INSERT;
            end;
        end;
    end;

    procedure CreateTag(PackageID: Text; TagType: Text; jField: JsonToken): Text;
    var
        Tag: Record "Package Tag";
    begin
        case TagType of
            'G':
                begin
                    /*
                    Yes	8	Account Category	Option		
                    Yes	9	Income/Balance	Option		
                    Yes	14	Direct Posting	Boolean		
                    Yes	16	Reconciliation Account	Boolean		
                    Yes	43	Gen. Posting Type	Option		
                    Yes	44	Gen. Bus. Posting Group	Code	20	
                    Yes	45	Gen. Prod. Posting Group	Code	20	
                    Yes	54	Tax Area Code	Code	20	
                    Yes	55	Tax Liable	Boolean		
                    Yes	56	Tax Group Code	Code	20	
                    Yes	57	VAT Bus. Posting Group	Code	20	
                    Yes	58	VAT Prod. Posting Group	Code	20	
                    */
                    Tag.INIT;
                    Tag."Package ID" := PackageID;
                    Tag.Tag := '@' + TagType + GetTextFromToken(jField, 'f1');
                    Tag."Tag Type" := Tag."Tag Type"::"G/L Account";
                    Tag.Description := GetTextFromToken(jField, 'f2');
                    Tag.Groups := GetTextFromToken(jField, 'Totals');
                    if Tag.INSERT then;
                end;
            'N':
                begin
                    Tag.INIT;
                    Tag."Package ID" := PackageID;
                    Tag.Tag := '@' + TagType + GetTextFromToken(jField, 'f1');
                    Tag."Tag Type" := Tag."Tag Type"::"No. Series";
                    Tag.Description := GetTextFromToken(jField, 'f2');
                    if Tag.INSERT then;

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
        Step3: Page "OnBoarding Step 3";
        Modules: Record "OnBoarding Modules";
        Packages: Record "OnBoarding Package";
        PF: Record "OnBoarding Field";
    begin
        RefreshModules();
        GetPackages();
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
            SelectTagsFromSelectedPackages();
            COMMIT;
            Step3.Editable(true);
            Step3.RunModal();

        end else
            error('No packages selected, aborting');
    end;

    procedure SelectTagsFromSelectedPackages()
    var
        STag: Record "OnBoarding Selected Tag";
        Tag: Record "Package Tag";
        Package: Record "OnBoarding Package";
    begin
        Package.SetRange(Select, true);
        if Package.FINDSET then
            repeat
                Tag.setrange("Package ID", Package.ID);
                if Tag.findset then
                    repeat
                        Stag.INIT;
                        STag.Tag := Tag.Tag;
                        Stag.Description := Tag.Description;
                        Stag."Tag Type" := Tag."Tag Type";
                        if STag.Insert() then; // We allow getting
                                               // the same tag from
                                               // multiple packages
                    until tag.next = 0;
            until Package.next = 0;
    end;

    procedure GenerateCOA()
    begin

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