page 92106 "OnBoarding Step 2"
{
    PageType = List;
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
                Caption = 'Module';
                field(PackageCaption; DescTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Attention;
                }
            }
            group(SelectPackages)
            {
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
    procedure SetCaption(Cap: Text)
    begin
        DescTxt := Cap;
    end;

    var
        DescTxt: Text;

}