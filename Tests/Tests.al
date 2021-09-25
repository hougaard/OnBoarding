// Testing Codenit

codeunit 70310077 "OnBoarding Test Hgd"
{
    Subtype = Test;
    trigger OnRun()
    begin
        TestCamel();
        TestRefreshModules();
        Message('All tests completed successful!');
    end;

    [Test]
    procedure TestRefreshModules()
    var
        Modules: Record "OnBoarding Modules Hgd";
    begin
        Mgt.RefreshModules();
        if Modules.Count() <> 12 then
            error('Test fail: RefreshModules');
    end;

    procedure TestCamel()
    begin
        if Mgt.GetCamel('Posted Sales Invoice') <> 'PSI' then
            ERROR('Test fail: GetCamel');
    end;

    [test]
    procedure RunProcessSelectAll()
    var
        Modules: Record "OnBoarding Modules Hgd";
        Packages: Record "OnBoarding Package Hgd";
        //PF: Record "OnBoarding Field Hgd";
        sTag: Record "Analysis Selected Dimension";
        //Method: Option " ","Generate one for me","I'll upload one","Use the existing";
        // NS_Method: Option " ","Generate them for me","I will do this myself";

        // Auto Gen Parameters
        FirstAccountNumber: Integer;
        AccountIncrement: Integer;
        AccountIncrementTotals: Integer;
        CreateCOATotals: Boolean;
        CountryCode: Code[10];

        //ModulesDone: Boolean;
        //ModulesContinue: Boolean;
        BaseID: Text;
    //Appl: Codeunit "Application System Constants";
    //Mgt: Codeunit "OnBoarding Management Hgd";
    //A: Codeunit Assert;
    begin
        // Start
        sTag.Deleteall();

        // Select Modules
        Mgt.RefreshModules();
        if Modules.findset() then
            repeat
                Modules.validate(Select, true);
                modules.modify();
            until Modules.next() = 0;

        MGt.GetPackages('BASE-SETUP-', true);
        Packages.Setrange(Description, '*CA*');
        //A.IsTrue(Packages.count <> 1, 'Not just one base package with CA');
        //A.IsTrue(Packages.findfirst, 'Not found Canada base package');
        Packages.validate(Select, true);
        //A.IsTrue(Packages.Modify, 'Could not save base package');
        BaseID := Packages.ID;
        CountryCode := Packages.Country;
        Mgt.GetPackages('_' + CountryCode + '_' + Packages."Minimum Version", false);
        Packages.reset();
        Packages.ModifyAll(Select, true);
        FirstAccountNumber := 1000;
        AccountIncrement := 10;
        AccountIncrementTotals := 100;
        CreateCOATotals := true;
        Mgt.BuildChartOfAccountFromTags(FirstAccountNumber,
                                        AccountIncrement,
                                        CreateCOATotals,
                                        AccountIncrementTotals);
        Mgt.SuggestStartingNumbers('1000');
        Mgt.CreateEverything();
        Mgt.CreateRapidStartPackage();
    end;

    var
        Mgt: Codeunit "OnBoarding Management Hgd";
}