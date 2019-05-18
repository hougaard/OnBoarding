codeunit 70310078 "OnBoarding Assisted Setup"
{
    [EventSubscriber(ObjectType::Table, Database::"Aggregated Assisted Setup", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure OnRegister(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup")
    var
        RecID: RecordId;
    begin
        TempAggregatedAssistedSetup.AddExtensionAssistedSetup(page::"OnBoarding Step 0",
                                                              'OnBoarding a complete setup',
                                                              true,
                                                              RecID,
                                                              0,
                                                              '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, true)]
    local procedure Init()
    var
        GL: Record "G/L Account";
    begin
        if GL.IsEmpty then
            if confirm('This seems to be clean new company, do you want to start the onboarding process?') then
                page.run(Page::"OnBoarding Step 0");
    end;

    local procedure IsCompleted(AAS: Record "Aggregated Assisted Setup"): Integer
    var
        stag: Record "OnBoarding Selected Tag";
        packages: Record "OnBoarding Package";
    begin
        if stag.FindFirst() then
            exit(AAS.Status::Completed)
        else
            if packages.findfirst then
                exit(AAS.Status::"Not Completed")
            else
                exit(AAS.Status::"Not Started");
    end;
}