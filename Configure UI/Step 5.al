page 92108 "OnBoarding Step 5"
{
    PageType = List;
    Caption = 'OnBoarding';
    SourceTable = "OnBoarding Selected Tag";
    SourceTableView = where ("Tag Type" = const ("G/L Account"));
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Editable = true;
    layout
    {
        area(Content)
        {
            group(Title)
            {
                Caption = 'Define your chart of accounts';
                repeater(Rep)
                {
                    field(TagValue; TagValue)
                    {
                        ApplicationArea = All;
                        Editable = true;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Total Begin/End"; "Total Begin/End")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GenerateCOA)
            {
                Caption = 'Build Chart of Account';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    OnMgt: Codeunit "OnBoarding Management";
                begin
                    OnMgt.GenerateCOA();
                end;
            }
        }
    }
}