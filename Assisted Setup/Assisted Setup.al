codeunit 70310078 "OnBoarding Assisted Setup Hgd"
{
    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, true)]
    local procedure OnRegister()
    var
        W: Codeunit "Assisted Setup Upgrade";
    begin

    end;
    */


    [EventSubscriber(ObjectType::Table, Database::"Aggregated Assisted Setup", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure OnRegister(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup")
    var
        RecID: RecordId;
        L: Label 'Accelerate your deployment with onboarding packages';
    begin
        TempAggregatedAssistedSetup.AddExtensionAssistedSetup(page::"OnBoarding Step 0 Hgd",
                                                              L,
                                                              true,
                                                              RecID,
                                                              0,
                                                              '');
    end;


    //[EventSubscriber(ObjectType::Page, Page::"Order Processor Role Center", 'OnOpenPageEvent', '', true, true)]

    // [EventSubscriber(ObjectType::Codeunit, 
    //                  Codeunit::LogInManagement, 
    //                  'OnAfterCompanyOpen', '', true, true)]
    local procedure StartOnBoarding()
    var
        GL: Record "G/L Account";
        Packages: Record "OnBoarding Modules Hgd";
        L: Label 'This seems to be clean new company, do you want to start the onboarding process?';
    begin
        //if GuiAllowed then
        if GL.IsEmpty then
            if Packages.IsEmpty then
                if confirm(L) then begin
                    page.run(Page::"OnBoarding Step 0 Hgd");
                end else begin
                    // To prevent asking again
                    Packages.INIT;
                    Packages."Module ID" := '_';
                    Packages.INSERT;
                end;
    end;

    /*
    local procedure IsCompleted(AAS: Record "Aggregated Assisted Setup"): Integer
    var
        stag: Record "OnBoarding Selected Tag Hgd";
        packages: Record "OnBoarding Package Hgd";
    begin
        if stag.FindFirst() then
            exit(AAS.Status::Completed)
        else
            if packages.findfirst then
                exit(AAS.Status::"Not Completed")
            else
                exit(AAS.Status::"Not Started");
    end;
    */
}