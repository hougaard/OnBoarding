codeunit 92100 "Onboarding Package Export"
{
    procedure ExportFromCompanies(CompanyFilter: Text)
    var
        PackageMgt: Codeunit "Onboarding Package Export";
        Appl: Codeunit "Application System Constants";
    begin
        PackageMgt.BuildPackageAndExportToGitHub('BASE',
                        'BASE-SETUP',
                        'Base Setup %1',
                        'Microsoft',
                        copystr(Appl.ApplicationVersion(), 1, 2),
                        CompanyFilter,
                        '8|9|11');
        // Finance
        PackageMgt.BuildPackageAndExportToGitHub('FIN',
                       'BASE-FIN',
                       'Finance Management Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                       '3|5|98|247|250|251|252');
        PackageMgt.BuildAccountSchedulePackges('FIN',
                                               'Microsoft',
                                               CompanyFilter,
                                                copystr(Appl.ApplicationVersion(), 1, 2));

        // Sales Tax
        PackageMgt.BuildPackageAndExportToGitHub('SALE',
                       'SALES_TAX',
                       'Sales Tax %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                       '318|319|320|321|322|325|323|324|326|327');

        // Sale
        PackageMgt.BuildPackageAndExportToGitHub('SALE',
                       'BASE-SALE',
                       'Sale Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '311|92');
        // Purchase
        PackageMgt.BuildPackageAndExportToGitHub('PURCHASE',
                       'BASE-PURCHASE',
                       'Purchase Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '312|93');
        // Inventory
        PackageMgt.BuildPackageAndExportToGitHub('INVENTORY',
                       'BASE-INVENTORY',
                       'Inventory Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '313|94');
        // Job
        PackageMgt.BuildPackageAndExportToGitHub('JOB',
                       'BASE-JOB',
                       'Jobs Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '314|315');
        // Fixed Assets
        PackageMgt.BuildPackageAndExportToGitHub('FA',
                       'BASE-FA',
                       'Fixed Assets Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '5603|5604|5605|5606|5607|5608');
        // Warehouse
        PackageMgt.BuildPackageAndExportToGitHub('WAREHOUSE',
                       'BASE-WAREHOUSE',
                       'Warehousing Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '5769|5719');
        // Service
        PackageMgt.BuildPackageAndExportToGitHub('SERVICE',
                       'BASE-SERVICE',
                       'Service Management Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '5911');
        // Service
        PackageMgt.BuildPackageAndExportToGitHub('MARKETING',
                       'BASE-MARKETING',
                       'Relationship Management Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '5911');
        // Hr
        PackageMgt.BuildPackageAndExportToGitHub('HR',
                       'BASE-HR',
                       'Human Resources Management Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '5218');
        // Production
        PackageMgt.BuildPackageAndExportToGitHub('PRODUCTION',
                       'BASE-PRODUCTION',
                       'Production and Planning Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '99000765');

    end;

    procedure ExportSimplified(CompanyFilter: Text)
    var
        PackageMgt: Codeunit "Onboarding Package Export";
        Appl: Codeunit "Application System Constants";
    begin
        // Finance
        PackageMgt.BuildPackageAndExportToGitHub('FIN',
                       'BASE-FIN-SIMPLE',
                       'Simplified Finance Management Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                       '3|5|98|247|250|251|252');
        // Sale
        PackageMgt.BuildPackageAndExportToGitHub('SALE',
                       'BASE-SALE-SIMPLE',
                       'Simplified Sale Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '311|92');
        // Purchase
        PackageMgt.BuildPackageAndExportToGitHub('PURCHASE',
                       'BASE-PURCHASE-SIMPLE',
                       'Simplified Purchase Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '312|93');
        // Iventory
        PackageMgt.BuildPackageAndExportToGitHub('INVENTORY',
                       'BASE-INVENTORY-SIMPLE',
                       'Simplified Inventory Basis Setup %1',
                       'Microsoft',
                       copystr(Appl.ApplicationVersion(), 1, 2),
                       CompanyFilter,
                        '313|94');

    end;

    procedure BuildAccountSchedulePackges(Module: Text;
                                          Author: Text;
                                          CompanyFilter: Text;
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
        Companies: Record Company;
        CI: Record "Company Information";
    begin
        if CompanyFilter <> '' then
            Companies.setfilter(Name, CompanyFilter);
        if Companies.findset then
            repeat
                CI.ChangeCompany(Companies.Name);
                CI.GET;
                AS.ChangeCompany(Companies.Name);
                if AS.FINDSET then
                    repeat
                        i := 0;
                        CLEAR(TJA);
                        CLEAR(J);
                        Clear(Info);

                        // Account Schedule
                        T.OPEN(84, false, Companies.Name);
                        F := T.Field(1);
                        F.SetRange(AS.Name);
                        TJA.Insert(i, TableRefToJson(T));
                        i += 1;
                        T.CLOSE();

                        // Schedule Line
                        T.OPEN(85, false, Companies.Name);
                        F := T.Field(1);
                        F.SetRange(AS.Name);
                        TJA.Insert(i, TableRefToJson(T));
                        i += 1;
                        T.CLOSE();

                        T.OPEN(334, false, Companies.Name); //Column Layout
                        F := T.Field(1);
                        F.SetRange(AS."Default Column Layout");
                        TJA.Insert(i, TableRefToJson(T));
                        i += 1;
                        T.CLOSE();

                        J.Add('Tables', TJA);
                        Info.Add('ID', AS.Name);
                        Info.Add('Module', Module);
                        Info.Add('Description', 'Account Schedule: ' + AS.Description);
                        Info.Add('Author', Author);
                        Info.Add('Country', CI."Country/Region Code");
                        Info.Add('Version', VersionTxt);
                        J.Add('Info', Info);
                        J.AsToken().WriteTo(PackageTxt);

                        SendToPackageReceiver(PackageTxt, AS.Name, CI."Country/Region Code", VersionTxt);

                    until AS.NEXT = 0;
            until Companies.NEXT = 0;
    end;

    procedure SendToPackageReceiver(PackageTxt: Text; PackageID: Text; Country: Text; VersionTxt: Text)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
    begin
        Content.WriteFrom(PackageTxt);
        if http.Post('http://10.93.18.181:9999/' +
                        PackageID + '_' +
                        Country + '_' +
                        VersionTxt, Content, response) then begin
            if response.HttpStatusCode() <> 200 then
                ERROR('Cannot contact package receiver');
        end;
    end;

    procedure BuildPackageAndExportToGitHub(Module: Text;
                 PackageID: Text;
                 Description: Text;
                 Author: Text;
                 VersionTxt: Text;
                 CompanyFilter: Text;
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
        Companies: Record Company;
        CI: Record "Company Information";
    begin
        if CompanyFilter <> '' then
            Companies.setfilter(Name, CompanyFilter);
        if Companies.findset then
            repeat
                CLEAR(TJA);
                CLEAR(Info);
                CLEAR(J);
                i := 0;
                CI.ChangeCompany(Companies.Name);
                CI.GET;
                T.SETRANGE("Object Type", T."Object Type"::Table);
                T.SETFILTER("Object ID", TableFilter);
                if T.FINDSET THEN
                    repeat
                        TJA.Insert(i, TableToJson(T."Object ID", Companies.Name));
                        i += 1;
                    until T.NEXT = 0;
                J.Add('Tables', TJA);
                Info.Add('ID', PackageID);
                Info.Add('Module', Module);
                Info.Add('Description', StrSubstNo(Description, CI."Country/Region Code"));
                Info.Add('Author', Author);
                Info.Add('Country', CI."Country/Region Code");
                Info.Add('Version', VersionTxt);
                J.Add('Info', Info);
                J.AsToken().WriteTo(PackageTxt);

                SendToPackageReceiver(PackageTxt, PackageID, CI."Country/Region Code", VersionTxt);
            until Companies.next = 0;
    end;

    procedure TableToJson(TableNo: Integer; Company: Text): JsonObject
    var
        T: RecordRef;
    begin
        T.OPEN(TableNo, false, Company);
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
        FilterTest: Text;
        FilterOutput: Text;
        p: Integer;
    begin
        for i := 1 to R.FieldCount() do begin
            f := R.FieldIndex(i);
            if f.Class() = FieldClass::Normal then begin
                if HandleTags then begin
                    case F.Relation() of
                        15:
                            begin
                                FilterTest := f.Value;

                                if (strpos(FilterTest, '|') <> 0) or
                                   (strpos(FilterTest, '..') <> 0) or
                                   (strpos(FilterTest, '&') <> 0) or
                                   (strpos(FilterTest, '*') <> 0) or
                                   (strpos(FilterTest, '?') <> 0) then begin
                                    // This is a filter value
                                    for p := 1 to strlen(FilterTest) do begin
                                        if p = 1 then begin
                                            if IsDigit(FilterTest[p]) then begin
                                                FilterOutput += 'G';
                                            end;
                                        end else begin
                                            if (IsDigit(FilterTest[p])) and
                                            (not IsDigit(FilterTest[p - 1])) then
                                                FilterOutput += 'G';
                                        end;
                                        FilterOutput += copystr(FilterTest, p, 1);
                                    end;

                                    //J.Add('X' + FilterOutput, GLTagToJson(RecRef));
                                end else begin
                                    GL.ChangeCompany(R.CurrentCompany());
                                    if GL.GET(f.Value) then begin
                                        RecRef.GetTable(GL);
                                        J.Add('G' + format(f.Number()), GLTagToJson(RecRef));
                                    end else
                                        if format(f.value) <> '' then;
                                    //message('Unknown G/L Account %1 in table %2', f.Value, R.Caption());
                                end;

                            END;
                        308:
                            begin
                                NS.ChangeCompany(R.CurrentCompany());
                                if NS.Get(f.Value) then begin
                                    J.Add('N' + format(f.Number), NSTagToJson(NS));
                                end else
                                    if format(f.value) <> '' then
                                        error('Unknown Number Series %1 in table %2', f.Value, R.Caption());
                            end;
                        else
                            J.Add('f' + format(f.Number()), format(f.Value, 0, 9));
                    end;
                end else
                    J.Add('f' + format(f.Number()), format(f.Value, 0, 9));
            end;
        end;
        exit(J);
    end;

    procedure IsDigit(c: Char): boolean
    begin
        exit((c >= '0') and
             (c <= '9'));
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
                J.Add('f' + format(f.Number()), format(f.Value, 0, 9));
            end;
        end;
        GL.ChangeCompany(R.CurrentCompany());
        R.SetTable(GL);
        J.Add('Totals', GetGLAccountGroups(GL, R.CurrentCompany()));
        exit(J);
    end;

    procedure GetGLAccountGroups(GL: Record "G/L Account"; CompanyName: Text): Text
    // Build a string of all the Total this account is part of
    var
        Before: Record "G/L Account";
        GroupTxt: Text;
        Groups: Array[30] of Text;
        Count: Integer;
        i: Integer;
    begin
        Before.ChangeCompany(CompanyName);
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