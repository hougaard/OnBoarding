page 92106 "OnBoarding Step 2"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    SourceTable = "OnBoarding Package";
    SourceTableView = sorting (SortIndex);
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
                    Style = Strong;
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
                    field(Country; Country)
                    {
                        Editable = false;
                        ApplicationArea = All;
                        Visible = not AllowMultiple;
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
                var
                    PTest: Record "OnBoarding Package";
                begin
                    PTest.Setrange(Module, Rec.Module);
                    PTest.setrange(Select, true);
                    if not AllowMultiple then
                        if Ptest.Count() <> 1 then
                            error('You can only select one package from this screen');
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

    procedure PreparePage(Cap: Text; CountryFilter: Text; _AllowMultiple: Boolean)
    begin
        DescTxt := Cap;
        if CountryFilter <> '' then
            Setfilter(Country, CountryFilter);
        AllowMultiple := _AllowMultiple;
    end;

    var
        DescTxt: Text;
        AllowMultiple: Boolean;
        ContinuePressed: Boolean;


}