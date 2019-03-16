page 92106 "OnBoarding Step 2"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    SourceTable = "OnBoarding Package";
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
                Caption = 'Select packages for module';
                field(PackageCaption; DescTxt)
                {
                    Caption = 'Module';
                    ApplicationArea = All;
                    Editable = false;
                    Style = Attention;
                }
                // }
                // group(SelectPackages)
                // {
                repeater(Rep)
                {
                    field(Select; Select)
                    {
                        ApplicationArea = All;
                        Editable = true;
                    }
                    field(Description; Description)
                    {
                        Editable = false;
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
    procedure SetCaption(Cap: Text)
    begin
        DescTxt := Cap;
    end;

    var
        DescTxt: Text;

}