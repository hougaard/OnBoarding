codeunit 92103 "OnBoarding Assisted Setup"
{
    [EventSubscriber(ObjectType::Table, Database::"Aggregated Assisted Setup", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure OnRegister(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup")
    var
        RecID: RecordId;
    begin
        TempAggregatedAssistedSetup.AddExtensionAssistedSetup(page::"OnBoarding Step 0",
                                                              'OnBoarding a complete setup, up and running in no time',
                                                              true,
                                                              RecID,
                                                              0,
                                                              '');
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