page 70310078 "OnBoarding Step 3 Hgd"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    // How do you want your Chart of Accounts
    layout
    {
        area(Content)
        {
            group(g1)
            {
                Caption = 'How do you want your Chart Of Accounts';
                field(How; Method)
                {
                    Caption = 'Chart Of Account Action';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        case Method of
                            Method::"Generate one for me":
                                AutoBuildVisible := true;
                            Method::" ":
                                AutoBuildVisible := false;
                            method::"I'll upload one":
                                AutoBuildVisible := false;
                            Method::"Use the existing":
                                AutoBuildVisible := false;
                        end;
                    end;
                }
                group(AutoBuild)
                {
                    Caption = 'Auto-generation Parameters';
                    Visible = AutoBuildVisible;
                    field(FirstAccountNumberCtl; FirstAccountNumber)
                    {
                        Caption = 'First Account Number';
                        ApplicationArea = All;
                    }
                    field(AccountIncrementCtl; AccountIncrement)
                    {
                        Caption = 'Account Number Increment';
                        ApplicationArea = All;
                    }
                    field(CreateCOATotalsCtl; CreateCOATotals)
                    {
                        Caption = 'Create Chart Of Account Totals';
                        ApplicationArea = All;
                    }
                    field(AccountIncrementTotalsCtl; AccountIncrementTotals)
                    {
                        Caption = 'Total Accounts Increment';
                        Enabled = CreateCOATotals;
                        ApplicationArea = All;
                    }

                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Back)
            {
                Caption = 'Back';
                InFooterBar = true;
                Image = Cancel;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(ContinueAction)
            {
                InFooterBar = true;
                Image = Continue;
                ApplicationArea = All;
                Caption = 'Continue to next step';
                trigger OnAction()
                var
                    SelectChartOfAccountErrorLbl: Label 'Select a Chart of Account Method first.';
                begin
                    if Method <> Method::" " then begin
                        ContinuePressed := true;
                        CurrPage.Close()
                    end else
                        error(SelectChartOfAccountErrorLbl);
                end;
            }
        }
    }
    procedure Continue(): Boolean
    begin
        exit(ContinuePressed);
    end;

    procedure GetMethod(): Option "","Generate one for me","I'll upload one","Use the existing";
    begin
        exit(Method);
    end;

    procedure GetAutoGenParameters(var FirstAccount: Integer;
                                   var AccountIncre: Integer;
                                   var CreateTotals: Boolean;
                                   var TotalIncre: Integer)
    begin
        FirstAccount := FirstAccountNumber;
        AccountIncre := AccountIncrement;
        CreateTotals := CreateCOATotals;
        TotalIncre := AccountIncrementTotals;
    end;

    trigger OnOpenPage()
    begin
        FirstAccountNumber := 1000;
        AccountIncrement := 10;
        AccountIncrementTotals := 100;
        CreateCOATotals := true;
        ContinuePressed := false;
    end;

    var
        Method: Option " ","Generate one for me","I'll upload one","Use the existing";
        FirstAccountNumber: Integer;
        AccountIncrement: Integer;
        AccountIncrementTotals: Integer;
        CreateCOATotals: Boolean;
        AutoBuildVisible: Boolean;
        ContinuePressed: Boolean;
}