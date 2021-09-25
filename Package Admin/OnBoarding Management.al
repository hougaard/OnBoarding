codeunit 70310075 "OnBoarding Management Hgd"
{
    procedure CreateRapidStartPackage()
    var
        ConfigPackage: Record "Config. Package";
        //ConfigMgt: Codeunit "Config. Package Management";
        Packages: Record "OnBoarding Package Hgd";
        Tables: Record "OnBoarding Table Hgd";
    begin

        ConfigPackage.INIT();
        ConfigPackage.validate(Code, 'ONBOARDING');
        if not ConfigPackage.INSERT(TRUE) then
            ConfigPackage.MODIFY(TRUE);
        ConfigPackage.validate("Package Name", 'OnBoarding Data');
        ConfigPackage.validate("Exclude Config. Tables", true);
        ConfigPackage.MODIFY(TRUE);

        Packages.Setrange(Select, true);
        if packages.findset() then
            repeat
                Tables.Setrange("Package ID", Packages.ID);
                if tables.findset() then
                    repeat
                        AddTableToConfigPackage(ConfigPackage, Tables."Table No.");
                    until tables.next() = 0;
            until packages.next() = 0;
        AddTableToConfigPackage(ConfigPackage, DATABASE::"G/L Account");
        AddTableToConfigPackage(ConfigPackage, DATABASE::"No. Series");
        AddTableToConfigPackage(ConfigPackage, DATABASE::"No. Series Line");
    end;

    procedure AddTableToConfigPackage(ConfigPackage: Record "Config. Package";
                                      TableNo: Integer)
    var
        ConfigTable: Record "Config. Package Table";
    begin
        ConfigTable.INIT();
        ConfigTable."Package Code" := ConfigPackage.Code;
        COnfigTable.validate("Table ID", TableNo);
        if Configtable.INSERT(TRUE) then begin
            Configtable.validate("Skip Table Triggers", false);
            ConfigTable.MODIFY(TRUE);
        end;
    end;

    procedure SuggestStartingNumbers(StartNumber: Code[20])
    var
        sTag: Record "OnBoarding Selected Tag Hgd";
    begin
        sTag.SetRange("Tag Type", Stag."Tag Type"::"No. Series");
        sTag.SetFilter(TagValue, '=%1', '');
        if stag.findset() then
            repeat
                Stag.TagValue := copystr(GetCamel(stag.Description) + format(StartNumber), 1, MaxStrLen(Stag.TagValue));
                Stag.Modify();
            until stag.next() = 0;
    end;

    procedure GetCamel(t: Text): Text
    var
        i: Integer;
        O: Text;
    begin
        for i := 1 to StrLen(t) do
            if t[i] > '9' then
                if (UpperCase(t[i]) = t[i]) then
                    if i > 1 then begin
                        if (UpperCase(t[i - 1]) <> t[i - 1]) or
                           (t[i - 1] < '9') then
                            o += t[i];
                    end else
                        o += t[i];
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
    end;

    procedure CreateDataFromPackages()
    var
        Package: Record "OnBoarding Package Hgd";
        T: Record "OnBoarding Table Hgd";
        F: Record "OnBoarding Field Hgd";
        tag: Record "Package Tag Hgd";
        stag: Record "OnBoarding Selected Tag Hgd";
        R: RecordRef;
        Fr: FieldRef;
        NewRec: Boolean;
        CurrentRec: Integer;
        _decimal: Decimal;
        _date: Date;
        _datetime: DateTime;
        _time: Time;
        _integer: Integer;
        _boolean: Boolean;
        FilterStr: Text;
        FilterList: List Of [Text];
        FilterArray: array[10] of Text;
        i: Integer;
        L1Lbl: Label 'Data in package %1 required a account not present in your chart of account, please check the setup.';
        L2Lbl: Label 'Data in package %1 have created an incomplete setup, please check the setup.';
    begin
        Package.Setrange(Select, true);
        if Package.findset() then
            repeat
                //Message('Applying %1', Package.Description);
                T.Setrange("Package ID", Package.ID);
                if T.findset() then
                    repeat
                        R.OPEN(T."Table No.");
                        NewRec := true;
                        F.SETRANGE("Package ID", Package.ID);
                        F.SETRANGE("Table No.", T."Table No.");
                        if F.findset() then begin
                            CurrentRec := F."Record No.";
                            R.Init();
                            repeat
                                if CurrentRec <> F."Record No." then begin
                                    // New Rec, time to insert
                                    if not R.INSERT() THEN
                                        r.modify();
                                    R.Init();
                                    CurrentRec := F."Record No.";
                                end;
                                Fr := R.Field(F."Field No.");

                                case Fr.Relation() of
                                    15:
                                        if format(f."Field Value") <> '' then begin
                                            tag.GET(Package.ID, F."Field Value");
                                            FilterList := tag."Filter Tag List".Split(',');
                                            for i := 1 to FilterList.Count() do begin
                                                FilterList.Get(i, FilterArray[i]);
                                                stag.setrange(tag, FilterArray[i]);
                                                if stag.FindFirst() then
                                                    FilterArray[i] := stag.TagValue
                                                else
                                                    if tag.get(FilterArray[i]) then
                                                        // Now to check if the account needed is actually a End-Total
                                                        // That we have created
                                                        if tag."Account Type" = tag."Account Type"::"End-Total" then begin
                                                            stag.reset();
                                                            stag.setrange(Description, tag.Description);
                                                            if stag.FindFirst() then
                                                                FilterArray[i] := stag.TagValue
                                                            else begin
                                                                message(L1Lbl, package.Description);
                                                                FilterArray[i] := 'MISSING';
                                                            end;
                                                        end
                                                        else begin
                                                            message(L2Lbl, package.Description);
                                                            FilterArray[i] := 'MISSING';
                                                        end;

                                            end;
                                            FilterStr := StrSubstNo(tag."Filter Tag Template",
                                                                    FilterArray[1],
                                                                    FilterArray[2],
                                                                    FilterArray[3],
                                                                    FilterArray[4],
                                                                    FilterArray[5],
                                                                    FilterArray[6],
                                                                    FilterArray[7],
                                                                    FilterArray[8],
                                                                    FilterArray[9],
                                                                    FilterArray[10]);
                                            if FilterStr = '' then
                                                error('Table %1, Field %2, Filter=%3, List=%4',
                                                R.Number(), Fr.Number(), tag."Filter Tag Template", tag."Filter Tag List");
                                            Fr.Value := FilterStr;
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

                                                if F."Field Value" = '' then
                                                    fr.value := 0
                                                else begin
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
                            until F.next() = 0;
                            if not R.INSERT() THEN
                                R.Modify();
                        end;
                        R.CLOSE();
                    until T.next() = 0;
            until Package.next() = 0;
    end;

    procedure CreateChartOfAccounts()
    var
        stag: Record "OnBoarding Selected Tag Hgd";
        GL: Record "G/L Account";
        Indent: Codeunit "G/L Account-Indent";
    begin
        stag.setrange("Tag Type", stag."Tag Type"::"G/L Account");
        if stag.findset() then
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
                    GL."Account Subcategory Entry No." := stag."Account Subcategory Entry No.";
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
            until stag.next() = 0;
        Indent.Indent();
    end;

    procedure CreateNumberSeries()
    var
        stag: Record "OnBoarding Selected Tag Hgd";
        ns: Record "No. Series";
        nsl: Record "No. Series Line";
    begin
        stag.setrange("Tag Type", stag."Tag Type"::"No. Series");
        if stag.findset() then
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
            until stag.next() = 0;
    end;

    procedure VerifyAccountAssignment()
    begin

    end;

    procedure BuildChartOfAccountFromTags(var FirstAccount: Integer;
                                          var AccountIncre: Integer;
                                          var CreateTotals: Boolean;
                                          var TotalIncre: Integer)
    var
        STag: Record "OnBoarding Selected Tag Hgd";
        Tag: Record "Package Tag Hgd";
        Packages: Record "OnBoarding Package Hgd";
        StagTest: Record "OnBoarding Selected Tag Hgd";
        StagTest2: Record "OnBoarding Selected Tag Hgd";
        Totals: List of [Text];
        Total: Text;
        AfterIndex: Integer;
        BeforeIndex: Integer;
        i: Integer;
        ParentTotalBegin: Integer;
        ParentTotalEnd: Integer;
        ParentIndention: Integer;
        NotFirst: Boolean;
        TotalsCount: Integer;
        ShouldNeverHappenLbl: Label 'This should never happen, a total-end account without a total-begin account';
        CannotInsertLbl: Label 'Error 1: Cannot insert %1 as sort %2 because %3 is already there';
    begin
        sTag.DELETEALL();
        Packages.SetRange(Select, true);
        if Packages.findset() then
            repeat
                Tag.setrange("Package ID", Packages.ID);
                Tag.Setrange("Tag Type", Tag."Tag Type"::"G/L Account");
                if tag.findset() then
                    repeat
                        Totals := tag.Groups.Split(',');
                        if Totals.Count() > 0 then
                            Totals.Get(1, Total)
                        else
                            Total := '';
                        Stag.reset();
                        Stag.setrange(Tag, Tag.Tag);
                        if not stag.findfirst() then begin
                            // A tag we haven't see before,
                            // First we'll check if the totals
                            // group this account is part of is
                            // already known
                            stag.reset();
                            if Total <> '' then begin
                                //Message('%1 has groups: %2', tag.Description, tag.Groups);
                                StagTest.reset();
                                StagTest.Setrange("Income/Balance", Tag."Income/Balance");
                                StagTest.setrange("Totals Group", Total);
                                StagTest.setrange("Total Begin/End", stagtest."Total Begin/End"::"End");
                                if StagTest.findfirst() then begin
                                    // This group is know, lets add the account in that
                                    AfterIndex := StagTest.SortIndex;
                                    StagTest.Setrange("Totals Group"); // Reset so we can step back to 
                                    StagTest.Setrange("Total Begin/End"); // find the prevoius Index
                                    if StagTest.next(-1) = -1 then
                                        BeforeIndex := StagTest.SortIndex
                                    else
                                        error(ShouldNeverHappenLbl);
                                    Stag.Init();
                                    Stag.TransferFrom(tag);
                                    Stag.SortIndex := ROUND((AfterIndex - BeforeIndex) / 2 + BeforeIndex, 1);
                                    Stag.Tag := Tag.Tag;
                                    Stag.Description := Tag.Description;
                                    Stag."Indention Level" := StagTest."Indention Level";
                                    if not Stag.INSERT() THEN begin
                                        stagtest2.reset();
                                        stagtest2.get(Stag.SortIndex);
                                        error(CannotInsertLbl,
                                                Stag.Description,
                                                Stag.SortIndex,
                                                StagTest2.Description);
                                    end;
                                end else begin
                                    // The totals group is unknown, let's
                                    // add the groups and then the account.
                                    // Start with the last (outmost) group
                                    ParentTotalEnd := 0;
                                    TotalsCount := Totals.Count();
                                    for i := TotalsCount downto 1 do begin
                                        Totals.get(i, Total);
                                        StagTest.reset();
                                        StagTest.SetRange("Income/Balance", tag."Income/Balance");
                                        StagTest.setrange("Totals Group", Total);
                                        if not StagTest.findfirst() then begin
                                            // This group does not exists, let's figure out where to create it
                                            // in the number range
                                            if i = TotalsCount then begin
                                                // This is a new top level
                                                ParentTotalBegin := CreateTotal(Tag, GetMax(Tag), Total, 1, 0); // Begin
                                                ParentTotalEnd := CreateTotal(Tag, ParentTotalBegin, Total, 2, 0); // End
                                            end else
                                                if ParentTotalEnd <> 0 then begin
                                                    ParentTotalBegin := CreateTotal(Tag, ParentTotalBegin, Total, 1, ParentIndention); // Begin
                                                    ParentTotalEnd := CreateTotal(Tag, ParentTotalBegin, Total, 2, ParentIndention); // End
                                                    stagTest2.get(Tag."Income/Balance", ParentTotalEnd);
                                                    ParentIndention := stagTest2."Indention Level";
                                                end else
                                                    error('!!!5!!!!');
                                        end else begin
                                            ParentTotalBegin := StagTest.SortIndex;
                                            ParentIndention := stagtest."Indention Level";
                                            stagtest.next();
                                            ParentTotalEnd := Stagtest.SortIndex;
                                        end;
                                    end;
                                    // So At this point, all totals will be there, 
                                    // let's find the End of the inner total and
                                    // place the account just before that.
                                    StagTest.reset();
                                    Totals.get(1, Total);
                                    stagtest.setrange("Totals Group", total);
                                    stagtest.Setrange("Total Begin/End", stagtest."Total Begin/End"::"End");
                                    if stagtest.findfirst() then begin
                                        AfterIndex := StagTest.SortIndex;
                                        StagTest.Setrange("Totals Group"); // Reset so we can step back to 
                                        StagTest.Setrange("Total Begin/End"); // find the prevoius Index
                                        if StagTest.next(-1) = -1 then
                                            BeforeIndex := StagTest.SortIndex
                                        else
                                            error(ShouldNeverHappenLbl);
                                        Stag.Init();
                                        sTag.TransferFrom(tag);
                                        Stag.SortIndex := ROUND((AfterIndex - BeforeIndex) / 2 + BeforeIndex, 1);
                                        Stag.Tag := Tag.Tag;
                                        Stag.Description := Tag.Description;
                                        Stag."Indention Level" := StagTest."Indention Level" + 1;
                                        stag."Income/Balance" := Tag."Income/Balance";
                                        if not Stag.INSERT() THEN begin
                                            stagtest2.reset();
                                            stagtest2.get(Tag."Income/Balance", Stag.SortIndex);
                                            error(CannotInsertLbl,
                                                Stag.Description,
                                                Stag.SortIndex,
                                                StagTest2.Description);
                                        end;
                                        //Message('Insert %1 as %2 (%3)', stag.Description, Stag.SortIndex, stag."Total Begin/End");
                                    end else
                                        error('Cannot find the total we just created');
                                end;
                            end else
                                // tag not part of any totals....
                                error('TODO: Account outside total %1', format(tag));
                        end;
                    // else begin
                    // Ignore this tag for now...
                    until tag.next() = 0;
            until Packages.next() = 0;
        // Now assign account numbers to the account we have just created
        stag.reset();
        stag.setrange("Tag Type", stag."Tag Type"::"G/L Account");
        stag.SetCurrentKey("Income/Balance", SortIndex);
        if stag.findset() then
            repeat
                if NotFirst then
                    if stag."Total Begin/End" = stag."Total Begin/End"::" " then
                        FirstAccount += AccountIncre
                    else
                        FirstAccount += TotalIncre;

                stag.TagValue := Format(FirstAccount, 0, 9);
                stag.Modify();
                NotFirst := true;
            until stag.next() = 0;
        if not CreateTotals then Begin
            // We'll just remove the totals again
            stag.reset();
            stag.setrange("Tag Type", stag."Tag Type"::"G/L Account");
            stag.setrange("Total Begin/End", 1, 2);
            stag.deleteall();
        end;
    end;

    procedure GetMax(Tag: Record "Package Tag Hgd"): Integer;
    var
        st: Record "OnBoarding Selected Tag Hgd";
    begin
        st.Setrange("Income/Balance", Tag."Income/Balance");
        if st.findlast() then
            exit(st.SortIndex)
        else
            exit(0);
    end;

    procedure CreateTotal(Tag: Record "Package Tag Hgd";
                          BeforeIndex: Integer;
                          Total: Text;
                          BeginEnd: Option " ","Begin","End";
                          ParentIndention: Integer): Integer
    var
        NewTotal: Record "OnBoarding Selected Tag Hgd";
        stagtest2: Record "OnBoarding Selected Tag Hgd";
        CannotInsertLbl: Label 'Error 2: Cannot insert %1 as sort %2 because %3 is already there';
    begin
        NewTotal.Init();
        stagtest2.setrange("Income/Balance", tag."Income/Balance");
        if stagtest2.get(Tag."Income/Balance", BeforeIndex) then begin
            if stagtest2.next() = 1 then
                NewTotal.SortIndex := round((stagtest2.SortIndex - BeforeIndex) / 2, 1) + BeforeIndex
            else
                NewTotal.SortIndex := round((2000000000 - BeforeIndex) / 2, 1) + BeforeIndex;
        end else
            NewTotal.SortIndex := BeforeIndex + 10000;
        NewTotal.Description := copystr(Total, 1, maxstrlen(NewTotal.Description));
        NewTotal."Income/Balance" := tag."Income/Balance";
        NewTotal."Indention Level" := ParentIndention + 1;
        NewTotal."Total Begin/End" := BeginEnd;
        NewTotal."Totals Group" := copystr(Total, 1, MaxStrLen(NewTotal."Totals Group"));
        if not NewTotal.INSERT() THEN begin
            stagtest2.reset();
            stagtest2.get(Tag."Income/Balance", NewTotal.SortIndex);
            error(CannotInsertLbl,
                    NewTotal.Description,
                    NewTotal.SortIndex,
                    StagTest2.Description);
        end;
        exit(NewTotal.SortIndex);
    end;

    procedure GetPackages(NameFilter: Text; ApplSupportOnly: Boolean)
    var
        Package: Record "OnBoarding Package Hgd";
        pTable: Record "OnBoarding Table Hgd";
        pField: Record "OnBoarding Field Hgd";
        Tag: Record "Package Tag Hgd";
        Appl: Codeunit "Application System Constants";
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
        D: Dialog;
        FC: Integer;
        CountryFilter: Text;
        VersionFilter: Text;
        Download: Boolean;
        ReadingPackageLbl: Label 'Reading package list #1## of #2##';
        CannotReadLbl: Label 'Cannot read package list, error %1';
        CannotContactPackageServerLbl: Label 'Cannot contact Package Server';
        ExternalCallNotAllowedLbl: Label 'Call to package server blocked by your environment';
    begin
        if GuiAllowed() then
            D.Open(ReadingPackageLbl);

        Package.DELETEALL();
        pTable.DELETEALL();
        pField.DELETEALL();
        Tag.DELETEALL();

        CountryFilter := copystr(Appl.OriginalApplicationVersion(), 1, 2);
        VersionFilter := copystr(Appl.PlatformProductVersion(), 1, 2);

        request.SetRequestUri('https://api.github.com/repos/hougaard/OnBoardingPackages/contents/');
        request.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365 Business Central');
        request.Method('GET');
        if http.Send(request, response) then begin
            if response.IsBlockedByEnvironment() then
                error(ExternalCallNotAllowedLbl);
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
                            if ApplSupportOnly then begin
                                if CountryFilter <> 'US' then
                                    Download := strpos(filename, '_' + CountryFilter + '_' + VersionFilter) <> 0
                                else
                                    Download := (strpos(filename, '_US_' + VersionFilter) <> 0) or
                                                (strpos(filename, '_CA_' + VersionFilter) <> 0) or
                                                (strpos(filename, '_MX_' + VersionFilter) <> 0);
                            end else
                                Download := true;
                            if Download then begin
                                filename := copystr(filename, 2, strlen(filename) - 2);
                                if http.Get(filename, response) then begin
                                    if response.IsBlockedByEnvironment() then
                                        error(ExternalCallNotAllowedLbl);
                                    if response.HttpStatusCode() = 200 then begin
                                        response.Content().ReadAs(jsonTxt);
                                        ImportPackage(jsonTxt);
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
                if GuiAllowed() then
                    D.Close();
            end else
                Error(CannotReadLbl, response.HttpStatusCode());
        end else
            Error(CannotContactPackageServerLbl);
    end;

    procedure ImportPackage(JsonTxt: Text)
    var
        Package: Record "OnBoarding Package Hgd";
        jPackage: JsonObject;
        jInfoToken: JsonToken;
        //jInfo: JsonObject;
        jTables: JsonArray;
        jTablesToken: JsonToken;
        jTableToken: JsonToken;
        jTable: JsonObject;
        //pTable: Record "OnBoarding Table Hgd";
        //pField: Record "OnBoarding Field Hgd";
        Keys: List of [Text];
        Values: List of [JsonToken];
        TableTxt: Text;
        TableNo: Integer;
        jRecords: JsonArray;
    begin
        if jPackage.ReadFrom(JsonTxt) then
            if jPackage.Get('Info', jInfoToken) then begin
                Package.Init();
                Package.ID := copystr(GetTextFromToken(JInfoToken, 'ID'), 1, maxstrlen(package.id));
                Package."Module" := copystr(GetTextFromToken(jInfoToken, 'Module'), 1, maxstrlen(package.Module));
                Package.Description := copystr(GetTextFromToken(jInfoToken, 'Description'), 1, maxstrlen(package.Description));
                Package."Minimum Version" := copystr(GetTextFromToken(jInfoToken, 'Version'), 1, MaxStrLen(package."Minimum Version"));
                Package.Author := copystr(GetTextFromToken(jInfoToken, 'Author'), 1, maxstrlen(package.Author));
                Package.Country := copystr(GetTextFromToken(jInfoToken, 'Country'), 1, maxstrlen(package.Country));
                //Package.ID += Package.Country;
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

    procedure ImportRecords(PackageID: Code[30]; TableNo: Integer; jRecords: JsonArray)
    var
        TableRec: Record "OnBoarding Table Hgd";
        FieldRec: Record "OnBoarding Field Hgd";
        R: RecordRef;
        jRecordToken: JsonToken;
        jRecord: JsonObject;
        //jFieldToken: JsonToken;
        jField: JsonToken;
        RecNo: Integer;
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
        TableRec.Desciption := copystr(R.Caption(), 1, MaxStrLen(tablerec.Desciption));
        TableRec.Insert();
        foreach jRecordToken in jRecords do begin
            RecNo += 1;
            jRecord := jRecordToken.AsObject();
            Keys := jRecord.Keys();
            Values := jRecord.Values();
            for i := 1 to Keys.Count() do begin
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
                        FieldRec."Field Value" := copystr(jField.AsValue().AsText(), 1, maxstrlen(fieldrec."Field Value"));
                    'G':
                        begin
                            FieldRec."Field Value" := copystr(CreateTag(PackageID, 'G', jField), 1, maxstrlen(fieldrec."Field Value"));
                            FieldRec."Special Action" := FieldRec."Special Action"::Account;
                        END;
                    'N':
                        begin
                            FieldRec."Field Value" := copystr(CreateTag(PackageID, 'N', jField), 1, maxstrlen(fieldrec."Field Value"));
                            FieldRec."Special Action" := FieldRec."Special Action"::"Number Series";
                        end;
                end;
                FieldRec.Insert();
            end;
        end;
    end;

    procedure CreateTag(PackageID: Code[30]; TagType: Text; jField: JsonToken): Text;
    var
        Tag: Record "Package Tag Hgd";
        Tag2: Record "Package Tag Hgd";
        A: JsonArray;
        T: JsonToken;
    begin
        case TagType of
            'G':
                begin
                    Tag.Init();
                    Tag."Package ID" := PackageID;
                    FilterTagCounter += 1;
                    Tag.Tag := copystr(TagType + format(FilterTagCounter, 0, 9), 1, MaxStrLen(tag.Tag));
                    Tag."Tag Type" := Tag."Tag Type"::"Account Filter";
                    Tag.Description := 'Filter Tag';
                    Tag."Filter Tag Template" := copystr(GetTextFromToken(jField, 'Filter'), 1, maxstrlen(tag."Filter Tag Template"));

                    A := GetArrayFromToken(jField, 'Accounts');
                    if A.Count() > 0 then
                        foreach T in A do begin
                            if Tag."Filter Tag List" <> '' then
                                Tag."Filter Tag List" += ',';
                            Tag."Filter Tag List" += GetTextFromToken(T, 'f1');
                            if Tag."Filter Tag List" <> '' then begin
                                Tag2.Init();
                                Tag2."Package ID" := PackageID;
                                Tag2.Tag := copystr(GetTextFromToken(T, 'f1'), 1, MaxStrLen(tag2.tag));
                                Tag2."Tag Type" := Tag."Tag Type"::"G/L Account";
                                Tag2.Description := copystr(GetTextFromToken(T, 'f2'), 1, MaxStrLen(tag2.Description));
                                Tag2.Groups := copystr(GetTextFromToken(T, 'Totals'), 1, MaxStrLen(tag2.Groups));

                                Tag2."Account Category" := GetOptionFromToken(T, 'f8');
                                Tag2."Income/Balance" := GetOptionFromToken(T, 'f9');
                                Tag2."Direct Posting" := GetBooleanFromToken(T, 'f14');
                                Tag2."Reconciliation Account" := GetBooleanFromToken(T, 'f16');
                                Tag2."Gen. Posting Type" := GetOptionFromToken(T, 'f43');
                                Tag2."Gen. Bus. Posting Group" := copystr(GetTextFromToken(T, 'f44'), 1, MaxStrLen(Tag2."Gen. Bus. Posting Group"));
                                Tag2."Gen. Prod. Posting Group" := copystr(GetTextFromToken(T, 'f45'), 1, maxstrlen(Tag2."Gen. Prod. Posting Group"));
                                Tag2."Tax Area Code" := copystr(GetTextFromToken(T, 'f54'), 1, MaxStrLen(Tag2."Tax Area Code"));
                                Tag2."Tax Liable" := GetBooleanFromToken(T, 'f55');
                                tag2."Tax Group Code" := copystr(GetTextFromToken(T, 'f56'), 1, maxstrlen(tag2."Tax Group Code"));
                                tag2."VAT Bus. Posting Group" := copystr(GetTextFromToken(T, 'f57'), 1, maxstrlen(tag2."VAT Bus. Posting Group"));
                                tag2."VAT Prod. Posting Group" := copystr(GetTextFromToken(T, 'f58'), 1, maxstrlen(tag2."VAT Prod. Posting Group"));
                                if Tag2.INSERT() THEN; // Ignore since we can get sam tag from two packages
                            end;
                        end;
                    if Tag.INSERT() THEN;
                end;
            'N':
                begin
                    Tag.Init();
                    Tag."Package ID" := PackageID;
                    Tag.Tag := TagType + GetTextFromToken(jField, 'f1');
                    Tag."Tag Type" := Tag."Tag Type"::"No. Series";
                    Tag.Description := copystr(GetTextFromToken(jField, 'f2'), 1, MaxStrLen(tag.Description));
                    if Tag.INSERT() THEN;
                end;
        end;
        exit(Tag.Tag);
    end;

    procedure GetArrayFromToken(T: JsonToken; Member: Text): JsonArray
    var
        O: JsonObject;
        V: JsonToken;
    begin
        O := T.AsObject();
        if O.Get(Member, V) then
            EXIT(V.AsArray());
    end;

    procedure GetTextFromToken(T: JsonToken; Member: Text): Text
    var
        O: JsonObject;
        V: JsonToken;
        Data: Text;
    begin
        O := T.AsObject();
        if O.Get(Member, V) then begin
            V.WriteTo(Data);
            EXIT(copystr(Data, 2, strlen(Data) - 2));
        end;
    end;

    procedure GetOptionFromToken(T: JsonToken; Member: Text): Integer
    var
        O: JsonObject;
        V: JsonToken;
        Data: Text;
        Op: Integer;
    begin
        O := T.AsObject();
        if O.Get(Member, V) then begin
            V.WriteTo(Data);
            evaluate(Op, Data); // copystr(Data, 2, strlen(Data) - 2), 9);
            EXIT(Op);
        end;
    end;

    procedure GetBooleanFromToken(T: JsonToken; Member: Text): Boolean
    var
        O: JsonObject;
        V: JsonToken;
        Data: Text;
    begin
        O := T.AsObject();
        if O.Get(Member, V) then begin
            V.WriteTo(Data);
            //evaluate(Op, copystr(Data, 2, strlen(Data) - 2));
            //EXIT(Op);
            exit(Data = '1');
        end;
    end;

    procedure RunTheProcess()
    var
        Modules: Record "OnBoarding Modules Hgd";
        Packages: Record "OnBoarding Package Hgd";
        sTag: Record "Analysis Selected Dimension";
        Step1: Page "OnBoarding Step 1 Hgd"; // Select Modules
        Step2: Page "OnBoarding Step 2 Hgd"; // Select Packages
        Step3: Page "OnBoarding Step 3 Hgd"; // Select how to Chart of Account
        Step4: Page "OnBoarding Step 4 Hgd"; // Upload
        Step5: Page "OnBoarding Step 5 Hgd"; // Present and edit COA
        Step6: Page "OnBoarding Step 6 Hgd"; // Map to existing COA
        Step7: Page "OnBoarding Step 7 Hgd"; // Select how to number series
        Step8: Page "OnBoarding Step 8 Hgd"; // Edit number for numberseries
        Step9: Page "OnBoarding Step 9 Hgd"; // Review and Confirm

        // State machine
        State: Option "Start","Select Modules","Select Packages","Chart of Accounts action","Upload COA","Edit COA","Map to existing COA","Number Series Action","Edit Number Series","Review and Confirm";
        Done: Boolean;

        //PF: Record "OnBoarding Field Hgd";
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
        BaseID: Text;
        //Appl: Codeunit "Application System Constants";
        NoModulesSelectLbl: Label 'No modules selected, aborting';

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
                        State := State::"Select Modules";
                    end;
                State::"Select Modules":
                    begin
                        GetPackages('BASE-SETUP-', true);
                        COMMIT();
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
                            if Modules.findfirst() then
                                repeat
                                    Packages.reset();
                                    Packages.Setrange("Module", Modules."Module ID");
                                    if Modules."Sorting Order" > 0 then
                                        Packages.setrange(Country, CountryCode);
                                    COMMIT();
                                    clear(Step2);
                                    Step2.SetTableView(Packages);
                                    Step2.Editable(true);
                                    Step2.PreparePage(Modules.Description, '', Modules."Sorting Order" > 0);
                                    Step2.RunModal();
                                    if Step2.Continue() then begin
                                        if Modules."Sorting Order" = 0 then begin
                                            Packages.SetRange(Select, true);
                                            packages.findfirst();
                                            BaseID := Packages.ID;
                                            CountryCode := Packages.Country;
                                            GetPackages('_' + CountryCode + '_' + Packages."Minimum Version", false);
                                            Packages.reset();
                                            Packages.Get(BaseID);
                                            Packages.Select := true; // Reselect base package
                                            Packages.modify();
                                        end;
                                        ModulesDone := Modules.next() = 0;
                                        ModulesContinue := true;
                                    end else
                                        if Modules.NEXT(-2) <> 2 then begin
                                            State := State::"Select Modules";
                                            ModulesDone := true;
                                            ModulesContinue := false;
                                        end;
                                until ModulesDone;
                            if ModulesContinue then
                                State := State::"Chart of Accounts action";

                        END else
                            Error(NoModulesSelectLbl);
                    end;
                State::"Chart of Accounts action":
                    begin
                        Packages.reset();
                        packages.Setrange(Select, true);
                        if not packages.IsEmpty() then begin
                            clear(Step3);
                            Step3.Editable(true);
                            Step3.RunModal();
                            if Step3.Continue() then
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
                                        State := State::"Upload COA";
                                    Method::"Use the existing":
                                        State := State::"Map to existing COA";
                                end
                            else
                                State := State::"Select Packages";
                        end;
                    end;
                State::"Upload COA":
                    begin
                        SelectTagsFromSelectedPackages(false);
                        COMMIT();
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
                        COMMIT();
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
                        COMMIT();
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
            COMMIT();
        until Done;
    end;

    procedure SelectTagsFromSelectedPackages(OnlyNumberSeries: Boolean)
    var
        STag: Record "OnBoarding Selected Tag Hgd";
        Tag: Record "Package Tag Hgd";
        Package: Record "OnBoarding Package Hgd";
        Sort: Integer;
    begin
        Package.SetRange(Select, true);
        if Package.findset() then
            repeat
                Tag.setrange("Package ID", Package.ID);
                if OnlyNumberSeries then
                    tag.Setrange("Tag Type", Tag."Tag Type"::"No. Series");
                if Tag.findset() then
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
                    until tag.next() = 0;
            until Package.next() = 0;
    end;

    procedure RefreshModules()
    var
        Modules: Record "OnBoarding Modules Hgd";
        L1Lbl: Label 'Base Setup';
        L2Lbl: Label 'Financial Management';
        L3Lbl: Label 'Sales and Account Receivables';
        L4Lbl: Label 'Purchase and Account Payables';
        L5Lbl: Label 'Inventory';
        L6Lbl: Label 'Jobs';
        L7Lbl: Label 'Fixed Assets';
        L8Lbl: Label 'Warehouse';
        L9Lbl: Label 'Service Management';
        L10Lbl: Label 'Relationship Management';
        L11Lbl: Label 'Human Resources';
        L12Lbl: Label 'Production and Planning';
    begin
        Modules.DELETEALL();

        Modules.Init();
        Modules."Module ID" := 'BASE';
        Modules."Select" := true;
        Modules.Description := L1Lbl;
        Modules."Sorting Order" := 0;
        Modules.Insert();


        Modules.Init();
        Modules."Module ID" := 'FIN';
        Modules."Select" := false;
        Modules.Description := L2Lbl;
        Modules."Sorting Order" := 1;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'SALE';
        Modules."Select" := false;
        Modules.Description := L3Lbl;
        Modules."Sorting Order" := 2;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'PURCHASE';
        Modules."Select" := false;
        Modules.Description := L4Lbl;
        Modules."Sorting Order" := 3;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'INVENTORY';
        Modules."Select" := false;
        Modules.Description := L5Lbl;
        Modules."Sorting Order" := 4;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'JOB';
        Modules."Select" := false;
        Modules.Description := L6Lbl;
        Modules."Sorting Order" := 5;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'FA';
        Modules."Select" := false;
        Modules.Description := L7Lbl;
        Modules."Sorting Order" := 6;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'WAREHOUSE';
        Modules."Select" := false;
        Modules.Description := L8Lbl;
        Modules."Sorting Order" := 7;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'SERVICE';
        Modules."Select" := false;
        Modules.Description := L9Lbl;
        Modules."Sorting Order" := 8;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'MARKETING';
        Modules."Select" := false;
        Modules.Description := L10Lbl;
        Modules."Sorting Order" := 9;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'HR';
        Modules."Select" := false;
        Modules.Description := L11Lbl;
        Modules."Sorting Order" := 10;
        Modules.Insert();

        Modules.Init();
        Modules."Module ID" := 'PRODUCTION';
        Modules."Select" := false;
        Modules.Description := L12Lbl;
        Modules."Sorting Order" := 11;
        Modules.Insert();
    end;

    var
        FilterTagCounter: Integer;
}