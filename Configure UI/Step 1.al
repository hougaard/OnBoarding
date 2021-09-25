page 70310076 "OnBoarding Step 1 Hgd"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    Editable = true;
    SourceTable = "OnBoarding Modules Hgd";
    SourceTableView = SORTING("Sorting Order");
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
                Caption = 'Back';
                ApplicationArea = All;
                InFooterBar = true;
                Image = Cancel;
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(ContinueAction)
            {
                InFooterBar = true;
                ApplicationArea = All;
                Image = Continue;
                Caption = 'Continue to next step';
                trigger OnAction()
                begin
                    ContinuePressed := true;
                    CurrPage.Close();
                end;
            }
        }
    }
    procedure Continue(): Boolean
    begin
        exit(ContinuePressed);
    end;

    trigger OnOpenPage()
    begin
        ContinuePressed := false;
    end;

    Var
        ContinuePressed: Boolean;
}
