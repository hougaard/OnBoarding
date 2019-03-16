codeunit 92101 "OnBoarding Management"
{
    procedure CreateEverything()
    begin
        // Create Number Series
        CreateNumberSeries();

        // Create Chart Of Accounts
        CreateChartOfAccounts();

        // Create all the data from the selected packages
        CreateDataFromPackages();
    end;

    procedure CreateDataFromPackages()
    var
        Package: Record "OnBoarding Package";
        T: Record "OnBoarding Table";
        F: Record "OnBoarding Field";
        R: RecordRef;
        Fr: FieldRef;
        stag: Record "OnBoarding Selected Tag";
        NewRec: Boolean;
        CurrentRec: Integer;
        _decimal: Decimal;
        _date: Date;
        _datetime: DateTime;
        _time: Time;
        _integer: Integer;
        _boolean: Boolean;
    begin
        Package.Setrange(Select, true);
        if Package.FINDSET then
            repeat
                T.Setrange("Package ID", Package.ID);
                if T.Findset then
                    repeat
                        R.OPEN(T."Table No.");
                        NewRec := true;
                        F.SETRANGE("Package ID", Package.ID);
                        F.SETRANGE("Table No.", T."Table No.");
                        if F.FINDSET THEN begin
                            CurrentRec := F."Record No.";
                            R.INIT;
                            repeat
                                if CurrentRec <> F."Record No." then begin
                                    // New Rec, time to insert
                                    R.INSERT;
                                    R.INIT;
                                    CurrentRec := F."Record No.";
                                end;
                                Fr := R.Field(F."Field No.");
                                case Fr.Relation() of
                                    15:
                                        begin
                                            stag.get(F."Field Value");
                                            Fr.value := stag.TagValue;
                                        end;
                                    308:
                                        begin
                                            stag.get(F."Field Value");
                                            Fr.Value := stag.TagValue;
                                        end;
                                    else
                                        case lowercase(format(Fr.Type())) of
                                            'code',
                                            'guid',
                                            'text':
                                                fr.value := F."Field Value";
                                            'decimal':
                                                begin
                                                    evaluate(_decimal, F."Field Value", 9);
                                                    fr.value := _decimal;
                                                end;
                                            'boolean':
                                                begin
                                                    evaluate(_boolean, F."Field Value", 9);
                                                    fr.value := _boolean;
                                                end;
                                            'integer',
                                            'option':
                                                begin
                                                    evaluate(_integer, F."Field Value", 9);
                                                    fr.value := _integer;
                                                end;
                                            'date':
                                                begin
                                                    evaluate(_date, f."Field Value", 9);
                                                    fr.value := _date;
                                                end;
                                            'datetime':
                                                begin
                                                    evaluate(_datetime, f."Field Value", 9);
                                                    fr.value := _datetime;
                                                end;
                                            'time':
                                                begin
                                                    evaluate(_time, f."Field Value", 9);
                                                    fr.value := _time;
                                                end;
                                        end;
                                end;
                            until F.NEXT = 0;
                            R.INSERT;
                        end;
                        R.CLOSE;
                    until T.NEXT = 0;
            until Package.NEXT = 0;
    end;

    procedure CreateChartOfAccounts()
    var
        stag: Record "OnBoarding Selected Tag";
        GL: Record "G/L Account";
        Indent: Codeunit "G/L Account-Indent";
    begin
        stag.setrange("Tag Type", stag."Tag Type"::"G/L Account");
        if stag.findset then
            repeat
                if not GL.GET(stag.TagValue) then begin
                    // We're missing this G/L Account, create it!
                    GL.INIT;
                    GL.VALIDATE("No.", stag.TagValue);
                    GL.INSERT(TRUE);
                    GL.VALIDATE(Name, stag.Description);
                    GL.VALIDATE("Income/Balance", stag."Income/Balance");
                    case stag."Total Begin/End" of
                        stag."Total Begin/End"::"Begin":
                            GL.VALIDATE("Account Type", Gl."Account Type"::"Begin-Total");
                        stag."Total Begin/End"::"End":
                            GL.VALIDATE("Account Type", Gl."Account Type"::"End-Total");
                        else
                            Gl.Validate("Account Type", gl."Account Type"::Posting);
                    end;
                    GL.MODIFY(true);
                end;
            until stag.next = 0;
        Indent.Indent();
    end;

    procedure CreateNumberSeries()
    var
        stag: Record "OnBoarding Selected Tag";
        ns: Record "No. Series";
        nsl: Record "No. Series Line";
    begin
        stag.setrange("Tag Type", stag."Tag Type"::"No. Series");
        if stag.findset then
            repeat
                ns.INIT;
                ns.Validate(Code, stag.Tag);
                ns.insert(true);
                ns.validate(Description, stag.Description);
                ns.validate("Default Nos.", true);
                ns.Modify(true);
                nsl.Init();
                nsl.Validate("Series Code", ns.code);
                nsl.insert(true);
                nsl.validate("Starting No.", stag.TagValue);
                nsl.Modify(true);
            until stag.next = 0;
    end;

    procedure VerifyAccountAssignment()
    begin

    end;

    procedure BuildChartOfAccountFromTags(var FirstAccount: Integer;
                                          var AccountIncre: Integer;
                                          var CreateTotals: Boolean;
                                          var TotalIncre: Integer)
    var
        STag: Record "OnBoarding Selected Tag";
        Tag: Record "Package Tag";
        Packages: Record "OnBoarding Package";
        NextIncomeNo: Integer;
        NextBalanceNo: Integer;
        Totals: List of [Text];
        Total: Text;
        StagTest: Record "OnBoarding Selected Tag";
        AfterIndex: Integer;
        BeforeIndex: Integer;
        i: Integer;
        ParentTotalEnd: Integer;
        ParentIndention: Integer;
        BeginIndex: Integer;
        NotFirst: Boolean;
    begin
        sTag.DeleteAll();
        NextIncomeNo := 0;
        NextBalanceNo := 10000000;
        Packages.SetRange(Select, true);
        if Packages.FINDSET then
            repeat
                Tag.setrange("Package ID", Packages.ID);
                Tag.Setrange("Tag Type", Tag."Tag Type"::"G/L Account");
                if tag.findset then
                    repeat
                        Totals := tag.Groups.Split(',');
                        if Totals.Count() > 0 then
                            Totals.Get(1, Total)
                        else
                            Total := '';
                        Stag.setrange(Tag, Tag.Tag);
                        if not stag.findfirst then begin
                            // A tag we haven't see before,
                            // First we'll check if the totals
                            // group this account is part of is
                            // already known
                            if Total <> '' then begin
                                //Message('%1 has groups: %2', tag.Description, tag.Groups);
                                StagTest.RESET;
                                StagTest.setrange("Totals Group", Total);
                                StagTest.setrange("Total Begin/End", StagTest."Total Begin/End"::"End");
                                if StagTest.findfirst then begin
                                    // This group is know, lets add the account in that
                                    AfterIndex := StagTest.SortIndex;
                                    StagTest.Setrange("Totals Group"); // Reset so we can step back to 
                                    StagTest.Setrange("Total Begin/End"); // find the prevoius Index
                                    if StagTest.next(-1) = -1 then
                                        BeforeIndex := StagTest.SortIndex
                                    else
                                        error('This should never happen, a total-end account without a total-begin account');
                                    Stag.INIT;
                                    Stag.SortIndex := ROUND((AfterIndex - BeforeIndex) / 2 + BeforeIndex, 1);
                                    Stag.Tag := Tag.Tag;
                                    Stag.Description := Tag.Description;
                                    Stag."Indention Level" := StagTest."Indention Level";
                                    stag.INSERT;
                                    case Stag."Income/Balance" of
                                        Stag."Income/Balance"::"Balance Sheet":
                                            if Stag.SortIndex > NextBalanceNo then
                                                NextBalanceNo := Stag.SortIndex;
                                        Stag."Income/Balance"::"Income Statement":
                                            if Stag.SortIndex > NextIncomeNo then
                                                NextIncomeNo := Stag.SortIndex;
                                    end;
                                    //Message('Insert %1 as %2 (%3)', stag.Description, Stag.SortIndex, stag."Total Begin/End");
                                end else begin
                                    // The totals group is unknown, let's
                                    // add the groups and then the account.
                                    // Start with the last (outmost) group
                                    ParentTotalEnd := 0;
                                    for i := Totals.Count() downto 1 do begin
                                        Totals.get(i, Total);
                                        StagTest.RESET;
                                        StagTest.setrange("Totals Group", Total);
                                        StagTest.setrange("Total Begin/End", StagTest."Total Begin/End"::"End");
                                        if not StagTest.findfirst then begin
                                            // This group does not exists, let's figure out where to create it
                                            // in the number range
                                            stagTest.reset;
                                            if ParentTotalEnd <> 0 then begin
                                                stagTest.get(ParentTotalEnd);
                                                ParentIndention := stagTest."Indention Level";
                                                AfterIndex := ParentTotalEnd;
                                                if stagtest.next(-1) = -1 then
                                                    BeforeIndex := stagtest.SortIndex
                                                else
                                                    BeforeIndex := 0;
                                            end else begin
                                                ParentIndention := 0; // -1 ??
                                                if Stag."Income/Balance" = Stag."Income/Balance"::"Income Statement" then
                                                    ParentTotalEnd := NextIncomeNo
                                                else
                                                    ParentTotalEnd := NextBalanceNo;
                                                AfterIndex := ParentTotalEnd + 10000000;
                                                BeforeIndex := ParentTotalEnd;
                                            end;
                                            StagTest.INIT; // Create Total-Begin
                                            StagTest.SortIndex := BeforeIndex + 10000;
                                            StagTest.Description := Total;
                                            StagTest."Income/Balance" := stag."Income/Balance";
                                            stagtest."Indention Level" := ParentIndention + 1;
                                            StagTest."Total Begin/End" := StagTest."Total Begin/End"::"Begin";
                                            stagTest."Totals Group" := Total;
                                            StagTest.INSERT;
                                            BeginIndex := StagTest.SortIndex;
                                            case StagTest."Income/Balance" of
                                                StagTest."Income/Balance"::"Balance Sheet":
                                                    if StagTest.SortIndex > NextBalanceNo then
                                                        NextBalanceNo := StagTest.SortIndex;
                                                StagTest."Income/Balance"::"Income Statement":
                                                    if StagTest.SortIndex > NextIncomeNo then
                                                        NextIncomeNo := StagTest.SortIndex;
                                            end;
                                            //Message('Insert %1 as %2 (%3)', stagTest.Description, StagTest.SortIndex, stagTest."Total Begin/End");

                                            StagTest.INIT; // Create Total-End
                                            StagTest.SortIndex := ROUND((AfterIndex - BeginIndex) / 2 + BeginIndex, 1);
                                            ;
                                            StagTest.Description := Total;
                                            StagTest."Income/Balance" := stag."Income/Balance";
                                            stagtest."Indention Level" := ParentIndention + 1;
                                            StagTest."Total Begin/End" := StagTest."Total Begin/End"::"End";
                                            stagTest."Totals Group" := Total;
                                            StagTest.INSERT;
                                            case StagTest."Income/Balance" of
                                                StagTest."Income/Balance"::"Balance Sheet":
                                                    if StagTest.SortIndex > NextBalanceNo then
                                                        NextBalanceNo := StagTest.SortIndex;
                                                StagTest."Income/Balance"::"Income Statement":
                                                    if StagTest.SortIndex > NextIncomeNo then
                                                        NextIncomeNo := StagTest.SortIndex;
                                            end;
                                            //Message('Insert %1 as %2 (%3)', stagTest.Description, StagTest.SortIndex, stagTest."Total Begin/End");

                                            ParentTotalEnd := stagTest.SortIndex;

                                        end else begin
                                            ParentTotalEnd := StagTest.SortIndex;
                                        end;
                                    end;
                                    // So At this point, all totals will be there, 
                                    // let's find the End of the inner total and
                                    // place the account just before that.
                                    StagTest.reset;
                                    Totals.get(1, Total);
                                    stagtest.setrange("Totals Group", total);
                                    stagtest.Setrange("Total Begin/End", stagtest."Total Begin/End"::"End");
                                    if stagtest.findfirst then begin
                                        AfterIndex := StagTest.SortIndex;
                                        StagTest.Setrange("Totals Group"); // Reset so we can step back to 
                                        StagTest.Setrange("Total Begin/End"); // find the prevoius Index
                                        if StagTest.next(-1) = -1 then
                                            BeforeIndex := StagTest.SortIndex
                                        else
                                            error('This should never happen, a total-end account without a total-begin account');
                                        Stag.INIT;
                                        Stag.SortIndex := ROUND((AfterIndex - BeforeIndex) / 2 + BeforeIndex, 1);
                                        Stag.Tag := Tag.Tag;
                                        Stag.Description := Tag.Description;
                                        Stag."Indention Level" := StagTest."Indention Level" + 1;
                                        stag."Income/Balance" := Tag."Income/Balance";
                                        stag.Insert;
                                        case Stag."Income/Balance" of
                                            Stag."Income/Balance"::"Balance Sheet":
                                                if Stag.SortIndex > NextBalanceNo then
                                                    NextBalanceNo := Stag.SortIndex;
                                            Stag."Income/Balance"::"Income Statement":
                                                if Stag.SortIndex > NextIncomeNo then
                                                    NextIncomeNo := Stag.SortIndex;
                                        end;

                                        //Message('Insert %1 as %2 (%3)', stag.Description, Stag.SortIndex, stag."Total Begin/End");
                                    end else
                                        error('Cannot find the total we just created');
                                end;
                            end else begin
                                // tag not part of any totals....
                                error('TODO: Account outside total');
                            end;
                        end else begin
                            // Ignore this tag for now...
                        end;
                    until tag.next = 0;
            until Packages.NEXT = 0;
        // Now assign account numbers to the account we have just created
        stag.reset;
        stag.SetCurrentKey(SortIndex);
        if stag.findset then
            repeat
                if NotFirst then
                    if stag."Total Begin/End" = stag."Total Begin/End"::" " then
                        FirstAccount += AccountIncre
                    else
                        FirstAccount += TotalIncre;

                stag.TagValue := Format(FirstAccount, 0, 9);
                stag.Modify();
                NotFirst := true;
            until stag.next = 0;
        if not CreateTotals then Begin
            // We'll just remove the totals again
            stag.reset;
            stag.setrange("Total Begin/End", 1, 2);
            stag.deleteall;
        end;
    end;

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
        Package: Record "OnBoarding Package";
        pTable: Record "OnBoarding Table";
        pField: Record "OnBoarding Field";
    begin
        Package.DELETEALL;
        pTable.DELETEALL;
        pField.DELETEALL;

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
        if jPackage.ReadFrom(JsonTxt) then begin
            if jPackage.Get('Info', jInfoToken) then begin
                Package.INIT;
                Package.ID := GetTextFromToken(JInfoToken, 'ID');
                Package.Module := GetTextFromToken(jInfoToken, 'Module');
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
        Step1: Page "OnBoarding Step 1"; // Select Modules
        Step2: Page "OnBoarding Step 2"; // Select Packages
        Step3: Page "OnBoarding Step 3"; // Select how to Chart of Account
        Step4: Page "OnBoarding Step 4"; // Upload
        Step5: Page "OnBoarding Step 5"; // Present and edit COA
        Step6: Page "OnBoarding Step 6"; // Map to existing COA
        Step7: Page "OnBoarding Step 7"; // Assign number to numberseries

        Modules: Record "OnBoarding Modules";
        Packages: Record "OnBoarding Package";
        PF: Record "OnBoarding Field";
        sTag: Record "Analysis Selected Dimension";
        Method: Option " ","Generate one for me","I'll upload one","Use the existing";

        // Auto Gen Parameters
        FirstAccountNumber: Integer;
        AccountIncrement: Integer;
        AccountIncrementTotals: Integer;
        CreateCOATotals: Boolean;

    begin
        sTag.DeleteAll();
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
                    clear(Step2);
                    Step2.SetTableView(Packages);
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
            case Step3.GetMethod() of
                Method::"Generate one for me":
                    begin
                        Step3.GetAutoGenParameters(FirstAccountNumber,
                                                   AccountIncrement,
                                                   CreateCOATotals,
                                                   AccountIncrementTotals);
                        BuildChartOfAccountFromTags(FirstAccountNumber,
                                                   AccountIncrement,
                                                   CreateCOATotals,
                                                   AccountIncrementTotals);
                        COMMIT;
                        Step5.RunModal();
                    end;
                Method::"I'll upload one":
                    begin
                        COMMIT;
                        Step4.RunModal();
                        // Import ...
                        COMMIT;
                        Step5.RunModal();
                    end;
                Method::"Use the existing":
                    begin
                        // Map our tags to existing G/L
                        COMMIT;
                        Step6.RunModal();
                    end;
            end;
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