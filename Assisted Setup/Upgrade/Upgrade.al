codeunit 70310079 "OnBoarding Upgrade Hgd"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    begin
        // Code to make sure company is OK to upgrade.
    end;

    trigger OnUpgradePerCompany()
    begin
        // Code to perform company related table upgrade tasks
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        // Code to make sure that upgrade was successful for each company
    end;
}