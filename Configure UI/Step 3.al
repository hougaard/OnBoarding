page 70310078 "OnBoarding Step 3"
{
    PageType = NavigatePage;
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
                                begin
                                    AutoBuildVisible := true;
                                end;
                            Method::" ":
                                begin
                                    AutoBuildVisible := false;
                                End;
                            method::"I'll upload one":
                                begin
                                    AutoBuildVisible := false;
                                end;
                            Method::"Use the existing":
                                begin
                                    AutoBuildVisible := false;
                                end;
                        end;
                    end;
                }
                group(AutoBuild)
                {
                    Caption = 'Autogeneration Parameters';
                    Visible = AutoBuildVisible;
                    field(FirstAccountNumber; FirstAccountNumber)
                    {
                        Caption = 'First Account Number';
                        ApplicationArea = All;
                    }
                    field(AccountIncrement; AccountIncrement)
                    {
                        Caption = 'Account Number Increment';
                        ApplicationArea = All;
                    }
                    field(CreateCOATotals; CreateCOATotals)
                    {
                        Caption = 'Create Chart Of Account Totals';
                        ApplicationArea = All;
                    }
                    field(AccountIncrementTotals; AccountIncrementTotals)
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
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(ContinueAction)
            {
                InFooterBar = true;
                Caption = 'Continue to next step';
                trigger OnAction()
                begin
                    if Method <> Method::" " then begin
                        ContinuePressed := true;
                        CurrPage.Close()
                    end else
                        error('Select a Chart of Account Method first.');
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