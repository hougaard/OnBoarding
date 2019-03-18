page 92111 "OnBoarding Step 6"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding, Assign Accounts to Setup';
    SourceTable = "OnBoarding Selected Tag";
    SourceTableView = sorting (SortIndex) where ("Tag Type" = const ("G/L Account"),
                                                 "Total Begin/End" = const (" "));
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Editable = true;
    layout
    {
        area(Content)
        {
            repeater(Rep)
            {
                field(TagValue; TagValue)
                {
                    Caption = 'G/L Account No.';
                    ApplicationArea = All;
                    Editable = true;
                    TableRelation = "G/L Account"."No." where ("Income/Balance" = field ("Income/Balance"),
                                                              "Account Type" = const (Posting));
                }
                field(Description; Description)
                {
                    Caption = 'Account Name';
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
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
            action(GenerateCOA)
            {
                Caption = 'Verify Assignments';
                ApplicationArea = All;
                InFooterBar = true;
                trigger OnAction()
                var
                    OnMgt: Codeunit "OnBoarding Management";
                begin
                    OnMgt.VerifyAccountAssignment();
                end;
            }
            action(ContinueAction)
            {
                Caption = 'Continue';
                InFooterBar = true;
                trigger OnAction()
                begin
                    ContinuePressed := true;
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ContinuePressed := false;
    end;
    procedure Continue(): Boolean
    begin
        exit(ContinuePressed);
    end;

    var
        ContinuePressed: Boolean;
}