codeunit 92101 "OnBoarding Management"
{
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