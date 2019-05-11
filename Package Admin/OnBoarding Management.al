codeunit 92101 "OnBoarding Management"
{
    procedure CreateRapidStartPackage()
    var
        ConfigPackage: Record "Config. Package";
        ConfigMgt: Codeunit "Config. Package Management";
        Packages: Record "OnBoarding Package";
        Tables: Record "OnBoarding Table";
    begin

        ConfigPackage.INIT;
        ConfigPackage.validate(Code, 'ONBOARDING');
        if not ConfigPackage.INSERT(TRUE) then
            ConfigPackage.MODIFY(TRUE);
        ConfigPackage.validate("Package Name", 'OnBoarding Data');
        ConfigPackage.MODIFY(TRUE);

        Packages.Setrange(Select, true);
        if packages.findset then
            repeat
                Tables.Setrange("Package ID", Packages.ID);
                if tables.findset then
                    repeat
                        AddTableToConfigPackage(ConfigPackage, Tables."Table No.");
                    until tables.next = 0;
            until packages.next = 0;
        AddTableToConfigPackage(ConfigPackage, DATABASE::"G/L Account");
        AddTableToConfigPackage(ConfigPackage, DATABASE::"No. Series");
        AddTableToConfigPackage(ConfigPackage, DATABASE::"No. Series Line");
    end;

    procedure AddTableToConfigPackage(ConfigPackage: Record "Config. Package";
                                      TableNo: Integer)
    var
        ConfigTable: Record "Config. Package Table";
    begin
        ConfigTable.INIT;
        ConfigTable."Package Code" := ConfigPackage.Code;
        COnfigTable.validate("Table ID", TableNo);
        if Configtable.INSERT(TRUE) then begin
            Configtable.validate("Skip Table Triggers", false);
            ConfigTable.MODIFY(TRUE);
        end;
    end;

    procedure SuggestStartingNumbers(StartNumber: Code[20])
    var
        sTag: Record "OnBoarding Selected Tag";
    begin
        sTag.SetRange("Tag Type", Stag."Tag Type"::"No. Series");
        sTag.SetFilter(TagValue, '=%1', '');
        if stag.findset then
            repeat
                Stag.TagValue := GetCamel(stag.Description) + format(StartNumber);
                Stag.Modify();
            until stag.next = 0;
    end;

    procedure GetCamel(t: Text): Text
    var
        i: Integer;
        O: Text;
    begin
        for i := 1 to StrLen(t) do begin
            if t[i] > '9' then
                if (UpperCase(t[i]) = t[i]) then
                    if i > 1 then begin
                        if (UpperCase(t[i - 1]) <> t[i - 1]) or
                           (t[i - 1] < '9') then
                            o += t[i];
                    end else
                        o += t[i];
        end;
        exit(O);
    end;

    procedure CreateEverything()
    begin
        // Create Number Series
        CreateNumberSeries();

        // Create Chart Of Accounts
        CreateChartOfAccounts();

        // Create all the data from the selected packages
        CreateDataFromPackages();
        if not Confirm('Do you want to Commit the changes?\(Debug message)') then
            ERROR('Aborting');
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
        tt: Record "OnBoarding Selected Tag";

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
                            R.Init();
                            repeat
                                if CurrentRec <> F."Record No." then begin
                                    // New Rec, time to insert
                                    if not R.INSERT then
                                        r.Modify;
                                    R.Init();
                                    CurrentRec := F."Record No.";
                                end;
                                Fr := R.Field(F."Field No.");
                                case Fr.Relation() of
                                    15:
                                        begin
                                            stag.setrange(tag, f."Field Value");
                                            stag.findfirst();
                                            Fr.value := stag.TagValue;
                                        end;
                                    308:
                                        begin
                                            stag.setrange(tag, f."Field Value");
                                            stag.findfirst();
                                            Fr.Value := copystr(stag.Tag, 2);
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
                            if not R.INSERT then
                                R.Modify();
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
                    GL.Init();
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
                    GL."Account Category" := stag."Account Category";
                    GL."Gen. Bus. Posting Group" := stag."Gen. Bus. Posting Group";
                    GL."Gen. Posting Type" := stag."Gen. Posting Type";
                    GL."Gen. Prod. Posting Group" := stag."Gen. Prod. Posting Group";
                    GL."Direct Posting" := stag."Direct Posting";
                    GL."Tax Area Code" := stag."Tax Area Code";
                    GL."Tax Group Code" := stag."Tax Group Code";
                    GL."Tax Liable" := stag."Tax Liable";
                    GL."Reconciliation Account" := stag."Reconciliation Account";
                    GL."VAT Bus. Posting Group" := stag."VAT Bus. Posting Group";
                    GL."VAT Prod. Posting Group" := stag."VAT Prod. Posting Group";
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
                if not NS.GET(copystr(stag.Tag, 2)) then begin // Only create NS if not exist
                    ns.Init();
                    ns.Validate(Code, copystr(stag.Tag, 2));
                    ns.insert(true);
                    ns.validate(Description, stag.Description);
                    ns.validate("Default Nos.", true);
                    ns.Modify(true);
                    nsl.Init();
                    nsl.Validate("Series Code", ns.code);
                    nsl.insert(true);
                    nsl.validate("Starting No.", stag.TagValue);
                    nsl.Modify(true);
                end;
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
        Totals: List of [Text];
        Total: Text;
        StagTest: Record "OnBoarding Selected Tag";
        StagTest2: Record "OnBoarding Selected Tag";
        AfterIndex: Integer;
        BeforeIndex: Integer;
        i: Integer;
        ParentTotalBegin: Integer;
        ParentTotalEnd: Integer;
        ParentIndention: Integer;
        NotFirst: Boolean;
        TotalsCount: Integer;
    begin
        sTag.DELETEALL;
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
                        Stag.Reset;
                        Stag.setrange(Tag, Tag.Tag);
                        if not stag.findfirst then begin
                            // A tag we haven't see before,
                            // First we'll check if the totals
                            // group this account is part of is
                            // already known
                            stag.Reset;
                            if Total <> '' then begin
                                //Message('%1 has groups: %2', tag.Description, tag.Groups);
                                StagTest.RESET;
                                StagTest.Setrange("Income/Balance", Tag."Income/Balance");
                                StagTest.setrange("Totals Group", Total);
                                StagTest.setrange("Total Begin/End", stagtest."Total Begin/End"::"End");
                                if StagTest.findfirst then begin
                                    // This group is know, lets add the account in that
                                    AfterIndex := StagTest.SortIndex;
                                    StagTest.Setrange("Totals Group"); // Reset so we can step back to 
                                    StagTest.Setrange("Total Begin/End"); // find the prevoius Index
                                    if StagTest.next(-1) = -1 then
                                        BeforeIndex := StagTest.SortIndex
                                    else
                                        error('This should never happen, a total-end account without a total-begin account');
                                    Stag.Init();
                                    Stag.TransferFrom(tag);
                                    Stag.SortIndex := ROUND((AfterIndex - BeforeIndex) / 2 + BeforeIndex, 1);
                                    Stag.Tag := Tag.Tag;
                                    Stag.Description := Tag.Description;
                                    Stag."Indention Level" := StagTest."Indention Level";
                                    if not Stag.INSERT then begin
                                        stagtest2.reset;
                                        stagtest2.get(Stag.SortIndex);
                                        error('Error 1: Cannot insert %1 as sort %2 because %3 is already there',
                                                Stag.Description,
                                                Stag.SortIndex,
                                                StagTest2.Description);
                                    end;
                                    //Message('Insert %1 as %2 (%3)', stag.Description, Stag.SortIndex, stag."Total Begin/End");
                                end else begin
                                    // The totals group is unknown, let's
                                    // add the groups and then the account.
                                    // Start with the last (outmost) group
                                    ParentTotalEnd := 0;
                                    TotalsCount := Totals.Count();
                                    for i := TotalsCount downto 1 do begin
                                        Totals.get(i, Total);
                                        StagTest.RESET;
                                        StagTest.SetRange("Income/Balance", tag."Income/Balance");
                                        StagTest.setrange("Totals Group", Total);
                                        //StagTest.setrange("Total Begin/End", StagTest."Total Begin/End"::"End");
                                        if not StagTest.findfirst then begin
                                            // This group does not exists, let's figure out where to create it
                                            // in the number range
                                            if i = TotalsCount then begin
                                                // This is a new top level
                                                ParentTotalBegin := CreateTotal(Tag, GetMax(Tag), Total, 1, 0); // Begin
                                                ParentTotalEnd := CreateTotal(Tag, ParentTotalBegin, Total, 2, 0); // End
                                            end else begin
                                                if ParentTotalEnd <> 0 then begin
                                                    ParentTotalBegin := CreateTotal(Tag, ParentTotalBegin, Total, 1, ParentIndention); // Begin
                                                    ParentTotalEnd := CreateTotal(Tag, ParentTotalBegin, Total, 2, ParentIndention); // End
                                                    stagTest2.get(Tag."Income/Balance", ParentTotalEnd);
                                                    ParentIndention := stagTest2."Indention Level";
                                                end else begin
                                                    error('!!!5!!!!');
                                                end;
                                            end;
                                        end else begin
                                            ParentTotalBegin := StagTest.SortIndex;
                                            ParentIndention := stagtest."Indention Level";
                                            stagtest.next;
                                            ParentTotalEnd := Stagtest.SortIndex;
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
                                        Stag.Init();
                                        sTag.TransferFrom(tag);
                                        Stag.SortIndex := ROUND((AfterIndex - BeforeIndex) / 2 + BeforeIndex, 1);
                                        Stag.Tag := Tag.Tag;
                                        Stag.Description := Tag.Description;
                                        Stag."Indention Level" := StagTest."Indention Level" + 1;
                                        stag."Income/Balance" := Tag."Income/Balance";
                                        if not Stag.INSERT then begin
                                            stagtest2.reset;
                                            stagtest2.get(Tag."Income/Balance", Stag.SortIndex);
                                            error('Error 4: Cannot insert %1 as sort %2 because %3 is already there',
                                                Stag.Description,
                                                Stag.SortIndex,
                                                StagTest2.Description);
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
        stag.setrange("Tag Type", stag."Tag Type"::"G/L Account");
        stag.SetCurrentKey("Income/Balance", SortIndex);
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
            stag.setrange("Tag Type", stag."Tag Type"::"G/L Account");
            stag.setrange("Total Begin/End", 1, 2);
            stag.deleteall;
        end;
    end;

    procedure GetMax(Tag: Record "Package Tag"): Integer;
    var
        st: Record "OnBoarding Selected Tag";
    begin
        st.Setrange("Income/Balance", Tag."Income/Balance");
        if st.findlast then
            exit(st.SortIndex)
        else
            exit(0);
    end;

    procedure CreateTotal(Tag: Record "Package Tag";
                          BeforeIndex: Integer;
                          Total: Text;
                          BeginEnd: Option " ","Begin","End";
                          ParentIndention: Integer): Integer
    var
        NewTotal: Record "OnBoarding Selected Tag";
        stagtest2: Record "OnBoarding Selected Tag";
    begin
        NewTotal.Init();
        stagtest2.setrange("Income/Balance", tag."Income/Balance");
        if stagtest2.get(Tag."Income/Balance", BeforeIndex) then begin
            if stagtest2.next = 1 then begin
                NewTotal.SortIndex := round((stagtest2.SortIndex - BeforeIndex) / 2, 1) + BeforeIndex;
            end else
                NewTotal.SortIndex := round((2000000000 - BeforeIndex) / 2, 1) + BeforeIndex;
        end else
            NewTotal.SortIndex := BeforeIndex + 10000;
        NewTotal.Description := Total;
        NewTotal."Income/Balance" := tag."Income/Balance";
        NewTotal."Indention Level" := ParentIndention + 1;
        NewTotal."Total Begin/End" := BeginEnd;
        NewTotal."Totals Group" := Total;
        if not NewTotal.INSERT then begin
            stagtest2.reset;
            stagtest2.get(Tag."Income/Balance", NewTotal.SortIndex);
            error('Error 2: Cannot insert %1 as sort %2 because %3 is already there',
                    NewTotal.Description,
                    NewTotal.SortIndex,
                    StagTest2.Description);
        end;
        exit(NewTotal.SortIndex);
    end;

    procedure GetPackages(NameFilter: Text)
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
        Tag: Record "Package Tag";
        D: Dialog;
        FC: Integer;
    begin
        if GuiAllowed() then
            D.Open('Reading package list from Github #1## of #2##');

        Package.DELETEALL;
        pTable.DELETEALL;
        pField.DELETEALL;
        Tag.DELETEALL;

        request.SetRequestUri('https://api.github.com/repos/hougaard/OnBoardingPackages/contents/');
        request.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365 Business Central');
        request.Method('GET');
        if http.Send(request, response) then begin
            if response.HttpStatusCode() = 200 then begin
                response.Content().ReadAs(jsonTxt);
                files.ReadFrom(jsonTxt);
                if GuiAllowed() then
                    D.Update(2, Files.Count());
                foreach fileToken in files do begin
                    JO := fileToken.AsObject();
                    JO.Get('download_url', value);
                    value.WriteTo(filename);
                    if (NameFilter = '') or
                       (strpos(filename, NameFilter) <> 0) then begin
                        FC += 1;
                        if GuiAllowed() then
                            D.Update(1, FC);
                        if strpos(filename, '.json') <> 0 then begin
                            filename := copystr(filename, 2, strlen(filename) - 2);
                            if http.Get(filename, response) then begin
                                response.Content().ReadAs(jsonTxt);
                                ImportPackage(jsonTxt);
                            end;
                        end;
                    end;
                end;
                if GuiAllowed() then
                    D.Close();
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
                Package.Init();
                Package.ID := GetTextFromToken(JInfoToken, 'ID');
                Package.Module := GetTextFromToken(jInfoToken, 'Module');
                Package.Description := GetTextFromToken(jInfoToken, 'Description');
                Package."Minimum Version" := GetTextFromToken(jInfoToken, 'Version');
                Package.Author := GetTextFromToken(jInfoToken, 'Author');
                Package.Country := GetTextFromToken(jInfoToken, 'Country');
                Package.ID += Package.Country;
                if strpos(Package.ID, 'BASE') <> 0 then
                    Package.SortIndex := -1; // Make sure base packages are shown first.
                Package.Insert();

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
        TableRec.Init();
        TableRec."Package ID" := PackageID;
        TableRec."Table No." := TableNo;
        R.OPEN(TableNo);
        TableRec.Desciption := R.Caption();
        TableRec.Insert();
        foreach jRecordToken in jRecords do begin
            RecNo += 1;
            jRecord := jRecordToken.AsObject();
            Keys := jRecord.Keys();
            Values := jRecord.Values();
            for i := 1 to Keys.Count do begin
                FieldRec.Init();
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
                            FieldRec."Special Action" := FieldRec."Special Action"::Account;
                        END;
                    'N':
                        begin
                            FieldRec."Field Value" := CreateTag(PackageID, 'N', jField);
                            FieldRec."Special Action" := FieldRec."Special Action"::"Number Series";
                        end;
                    'X':
                        begin
                            FieldRec."Field Value" := CreateTag(PackageID, 'X', jField);
                            FieldRec."Special Action" := FieldRec."Special Action"::"Account Filter";
                        end;

                end;
                FieldRec.Insert();
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
                    Tag.Init();
                    Tag."Package ID" := PackageID;
                    Tag.Tag := TagType + GetTextFromToken(jField, 'f1');
                    Tag."Tag Type" := Tag."Tag Type"::"G/L Account";
                    Tag.Description := GetTextFromToken(jField, 'f2');
                    Tag.Groups := GetTextFromToken(jField, 'Totals');

                    Tag."Account Category" := GetOptionFromToken(jField, 'f8');
                    Tag."Income/Balance" := GetOptionFromToken(jField, 'f9');
                    Tag."Direct Posting" := GetBooleanFromToken(jField, 'f14');
                    Tag."Reconciliation Account" := GetBooleanFromToken(jField, 'f16');
                    Tag."Gen. Posting Type" := GetOptionFromToken(jField, 'f43');
                    Tag."Gen. Bus. Posting Group" := GetTextFromToken(jField, 'f44');
                    Tag."Gen. Prod. Posting Group" := GetTextFromToken(jField, 'f45');
                    Tag."Tax Area Code" := GetTextFromToken(jField, 'f54');
                    Tag."Tax Liable" := GetBooleanFromToken(jField, 'f55');
                    tag."Tax Group Code" := GetTextFromToken(jField, 'f56');
                    tag."VAT Bus. Posting Group" := GetTextFromToken(jField, 'f57');
                    tag."VAT Prod. Posting Group" := GetTextFromToken(jField, 'f58');
                    if Tag.INSERT then;
                end;
            'N':
                begin
                    Tag.Init();
                    Tag."Package ID" := PackageID;
                    Tag.Tag := TagType + GetTextFromToken(jField, 'f1');
                    Tag."Tag Type" := Tag."Tag Type"::"No. Series";
                    Tag.Description := GetTextFromToken(jField, 'f2');
                    if Tag.INSERT then;
                end;
        end;
        exit(Tag.Tag);
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

    procedure GetOptionFromToken(T: JsonToken; Member: Text): Integer
    var
        O: JsonObject;
        V: JsonToken;
        Data: Text;
        Op: Integer;
    begin
        O := T.AsObject();
        O.Get(Member, V);
        V.WriteTo(Data);
        evaluate(Op, Data /*copystr(Data, 2, strlen(Data) - 2) */, 9);
        EXIT(Op);
    end;

    procedure GetBooleanFromToken(T: JsonToken; Member: Text): Boolean
    var
        O: JsonObject;
        V: JsonToken;
        Data: Text;
        Op: Boolean;
    begin
        O := T.AsObject();
        O.Get(Member, V);
        V.WriteTo(Data);
        evaluate(Op, copystr(Data, 2, strlen(Data) - 2));
        EXIT(Op);
    end;

    procedure RunTheProcess()
    var
        Step1: Page "OnBoarding Step 1"; // Select Modules
        Step2: Page "OnBoarding Step 2"; // Select Packages
        Step3: Page "OnBoarding Step 3"; // Select how to Chart of Account
        Step4: Page "OnBoarding Step 4"; // Upload
        Step5: Page "OnBoarding Step 5"; // Present and edit COA
        Step6: Page "OnBoarding Step 6"; // Map to existing COA
        Step7: Page "OnBoarding Step 7"; // Select how to number series
        Step8: Page "OnBoarding Step 8"; // Edit number for numberseries
        Step9: Page "OnBoarding Step 9"; // Review and Confirm

        // State machine
        State: Option "Start","Select Modules","Select Packages","Chart of Accounts action","Upload COA","Edit COA","Map to existing COA","Number Series Action","Edit Number Series","Review and Confirm";
        Done: Boolean;

        Modules: Record "OnBoarding Modules";
        Packages: Record "OnBoarding Package";
        PF: Record "OnBoarding Field";
        sTag: Record "Analysis Selected Dimension";
        Method: Option " ","Generate one for me","I'll upload one","Use the existing";
        NS_Method: Option " ","Generate them for me","I will do this myself";


        // Auto Gen Parameters
        FirstAccountNumber: Integer;
        AccountIncrement: Integer;
        AccountIncrementTotals: Integer;
        CreateCOATotals: Boolean;
        CountryCode: Code[10];

        ModulesDone: Boolean;
        ModulesContinue: Boolean;

    begin
        State := 0; //State::"Chart of Accounts action"; // We start at zero
        Done := false; // We're not done

        repeat // State machine loop
            case State of // This case statement defines where we're
                          // in the process, keeps looking until we're 
                          // done.
                State::Start:
                    begin
                        sTag.DeleteAll();
                        RefreshModules();
                        GetPackages('BASE-SETUP_');
                        State := State::"Select Modules";
                    end;
                State::"Select Modules":
                    begin
                        clear(Step1);
                        Step1.Editable(true);
                        Step1.RunModal();
                        if Step1.Continue() then
                            State := State::"Select Packages"
                        else
                            exit; // No reason to go back to 0
                    end;
                State::"Select Packages":
                    begin
                        Modules.SETRANGE(Select, true);
                        Modules.SetCurrentKey("Sorting Order");
                        if not Modules.IsEmpty() THEN BEGIN
                            if Modules.FINDFIRST then
                                repeat
                                    Packages.RESET;
                                    Packages.Setrange(Module, Modules."Module ID");
                                    if Modules."Sorting Order" > 0 then
                                        Packages.setrange(Country, CountryCode);
                                    COMMIT;
                                    clear(Step2);
                                    Step2.SetTableView(Packages);
                                    Step2.Editable(true);
                                    Step2.PreparePage(Modules.Description, '', Modules."Sorting Order" > 0);
                                    Step2.RunModal();
                                    if Step2.Continue() then begin
                                        if Modules."Sorting Order" = 0 then begin
                                            Packages.SetRange(Select, true);
                                            packages.findfirst;
                                            CountryCode := Packages.Country;
                                            Packages.Setrange(Select);
                                            GetPackages('_' + CountryCode + '_');
                                        end;
                                        ModulesDone := Modules.NEXT = 0;
                                        ModulesContinue := true;
                                    end else begin
                                        if Modules.NEXT(-2) <> 2 then begin
                                            State := State::"Select Modules";
                                            ModulesDone := true;
                                            ModulesContinue := false;
                                        end;
                                    end;
                                until ModulesDone;
                            if ModulesContinue then begin
                                State := State::"Chart of Accounts action";
                            end;
                        END else
                            Error('No modules selected, aborting');
                    end;
                State::"Chart of Accounts action":
                    begin
                        Packages.reset;
                        packages.Setrange(Select, true);
                        if not packages.IsEmpty() then begin
                            clear(Step3);
                            Step3.Editable(true);
                            Step3.RunModal();
                            if Step3.Continue() then begin
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
                                            State := State::"Edit COA";
                                        end;
                                    Method::"I'll upload one":
                                        begin
                                            State := State::"Upload COA";
                                        end;
                                    Method::"Use the existing":
                                        begin
                                            State := State::"Map to existing COA";
                                        end;
                                end;
                            end else
                                State := State::"Select Packages";
                        end;
                    end;
                State::"Upload COA":
                    begin
                        SelectTagsFromSelectedPackages(false);
                        COMMIT;
                        Clear(Step4);
                        Step4.RunModal();
                        if Step4.Continue() then
                            State := State::"Map to existing COA"
                        else
                            State := State::"Chart of Accounts action";
                    end;
                State::"Edit COA":
                    begin
                        SelectTagsFromSelectedPackages(true);
                        COMMIT;
                        Clear(Step5);
                        Step5.RunModal();
                        if Step5.Continue() then
                            State := State::"Number Series Action"
                        else
                            State := State::"Chart of Accounts action";
                    end;
                State::"Map to existing COA":
                    begin
                        SelectTagsFromSelectedPackages(false);
                        COMMIT;
                        Clear(Step6);
                        Step6.RunModal();
                        if Step6.Continue() then
                            State := State::"Number Series Action"
                        else
                            State := State::"Chart of Accounts action";
                    end;
                State::"Number Series Action":
                    begin
                        clear(Step7);
                        Step7.RunModal(); // Define number series
                        if Step7.Continue() then begin
                            if Step7.GetMethod() = NS_Method::"Generate them for me" then
                                SuggestStartingNumbers(Step7.GetStartNumber());
                            State := State::"Edit Number Series";
                        end else
                            State := State::"Chart of Accounts action";
                    end;
                State::"Edit Number Series":
                    begin
                        Clear(Step8);
                        step8.RunModal();
                        if Step8.Continue() then
                            State := State::"Review and Confirm"
                        else
                            State := State::"Number Series Action";
                    end;
                State::"Review and Confirm":
                    begin
                        Clear(Step9);
                        Step9.RunModal();
                        if Step9.Continue() then
                            Done := true // Yeah, done!
                        else
                            State := State::"Edit Number Series";
                    End;
            end;
            COMMIT;
        until Done;
    end;

    procedure SelectTagsFromSelectedPackages(OnlyNumberSeries: Boolean)
    var
        STag: Record "OnBoarding Selected Tag";
        Tag: Record "Package Tag";
        Package: Record "OnBoarding Package";
        Sort: Integer;
    begin
        Package.SetRange(Select, true);
        if Package.FINDSET then
            repeat
                Tag.setrange("Package ID", Package.ID);
                if OnlyNumberSeries then
                    tag.Setrange("Tag Type", Tag."Tag Type"::"No. Series");
                if Tag.findset then
                    repeat
                        Stag.Init();
                        STag.Tag := Tag.Tag;
                        Stag.Description := Tag.Description;
                        Stag."Tag Type" := Tag."Tag Type";
                        Sort -= 1;
                        Stag.SortIndex := Sort;
                        if STag.Insert() then; // We allow getting
                        // the same tag from
                        // multiple packages
                    until tag.next = 0;
            until Package.next = 0;
    end;

    procedure RefreshModules()
    var
        Modules: Record "OnBoarding Modules";
    begin
        Modules.DELETEALL;

        Modules.Init();
        Modules."Module ID" := 'BASE';
        Modules."Select" := true;
        Modules.Description := 'Base Setup';
        Modules."Sorting Order" := 0;
        Modules.Insert();


        Modules.Init();
        Modules."Module ID" := 'FIN';
        Modules."Select" := false;
        Modules.Description := 'Financial Management';
        Modules."Sorting Order" := 1;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'SALE';
        Modules."Select" := false;
        Modules.Description := 'Sales and Account Receivables';
        Modules."Sorting Order" := 2;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'PURCHASE';
        Modules."Select" := false;
        Modules.Description := 'Purchase and Account Payables';
        Modules."Sorting Order" := 3;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'INVENTORY';
        Modules."Select" := false;
        Modules.Description := 'Inventory';
        Modules."Sorting Order" := 4;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'JOB';
        Modules."Select" := false;
        Modules.Description := 'Jobs';
        Modules."Sorting Order" := 5;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'FA';
        Modules."Select" := false;
        Modules.Description := 'Fixed Assets';
        Modules."Sorting Order" := 6;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'WAREHOUSE';
        Modules."Select" := false;
        Modules.Description := 'Warehouse';
        Modules."Sorting Order" := 7;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'SERVICE';
        Modules."Select" := false;
        Modules.Description := 'Service Management';
        Modules."Sorting Order" := 8;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'MARKETING';
        Modules."Select" := false;
        Modules.Description := 'Relationship Management';
        Modules."Sorting Order" := 9;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'HR';
        Modules."Select" := false;
        Modules.Description := 'Human Resources';
        Modules."Sorting Order" := 10;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'PRODUCTION';
        Modules."Select" := false;
        Modules.Description := 'Production and Planning';
        Modules."Sorting Order" := 11;
        Modules.Insert();
    end;
}