page 92104 "OnBoarding Step 1"
{
    PageType = List;
    Caption = 'OnBoarding';
    Editable = true;
    SourceTable = "OnBoarding Modules";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    layout
    {
        area(Content)
        {
            group(SelectModules)
            {
                Caption = 'Select the Modules you want setup for';
                repeater(Rep)
                {
                    Editable = true;
                    field(Selected; "Select")
                    {
                        ApplicationArea = All;
                        Editable = true;
                    }
                    field(Description; Description)
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
            action(Continue)
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Continue to next step';
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }
}
