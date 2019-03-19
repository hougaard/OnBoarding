page 92108 "OnBoarding Step 5"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding, Define your chart of accounts';
    SourceTable = "OnBoarding Selected Tag";
    SourceTableView = sorting (SortIndex) where ("Tag Type" = const ("G/L Account"));
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
                IndentationColumn = "Indention Level";
                IndentationControls = Description;
                field(TagValue; TagValue)
                {
                    Caption = 'Account Number';
                    ApplicationArea = All;
                    Editable = true;
                }
                field(Description; Description)
                {
                    Caption = 'Description';
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                }
                field("Total Begin/End"; "Total Begin/End")
                {
                    Caption = 'Account Type';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Indention Level"; "Indention Level")
                {
                    Visible = false;
                }
                field("Income/Balance"; "Income/Balance")
                {
                    ApplicationArea = All;
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
                Caption = 'Continue to next step';
                ApplicationArea = All;
                InFooterBar = true;
                trigger OnAction()
                var
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

    trigger OnAfterGetRecord()
    begin
        NameEmphasize := "Total Begin/End" > 0;
    end;

    procedure Continue(): Boolean
    begin
        exit(ContinuePressed);
    end;

    var
        NameEmphasize: Boolean;
        ContinuePressed: Boolean;
}