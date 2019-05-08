// Testing Codenit

codeunit 92104 "OnBoarding Test"
{
    trigger OnRun()
    begin
        TestCamel();
        TestRefreshModules();
        Message('All tests completed successful!');
    end;

    procedure TestRefreshModules()
    var
        Modules: Record "OnBoarding Modules";
    begin
        Mgt.RefreshModules();
        if Modules.Count <> 12 then
            error('Test fail: RefreshModules');
    end;

    procedure TestCamel()
    begin
        if Mgt.GetCamel('Posted Sales Invoice') <> 'PSI' then
            ERROR('Test fail: GetCamel');
    end;

    var
        Mgt: Codeunit "OnBoarding Management";
}