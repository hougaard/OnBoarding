page 92112 "OnBoarding Step 7"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding, Number Series';
    SourceTable = "OnBoarding Selected Tag";
    SourceTableView = sorting (SortIndex) where ("Tag Type" = const ("No. Series"));
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
                    Caption = 'Start Number';
                    ApplicationArea = All;
                    Editable = true;
                }
                field(Description; Description)
                {
                    Caption = 'Number Series';
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
                Caption = 'Abort';
                InFooterBar = true;
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(Continue)
            {
                Caption = 'Continue';
                InFooterBar = true;
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }
}