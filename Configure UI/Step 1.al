page 92104 "OnBoarding Step 1"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    Editable = true;
    SourceTable = "OnBoarding Modules";
    SourceTableView = SORTING ("Sorting Order");
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
                InFooterBar = true;
                Caption = 'Continue to next step';
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }
}
