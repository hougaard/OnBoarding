page 70310082 "OnBoarding Step 7 Hgd"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    layout
    {
        area(Content)
        {
            group(g1)
            {
                Caption = 'How do you want your documents numbered';
                field(How; Method)
                {
                    Caption = 'Document numbering action';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        case Method of
                            Method::"Generate them for me":
                                AutoBuildVisible := true;
                            Method::" ":
                                AutoBuildVisible := false;
                            Method::"I will do this myself":
                                AutoBuildVisible := false;
                        end;
                    end;
                }
                group(AutoBuild)
                {
                    Caption = 'Auto-generation Parameters';
                    Visible = AutoBuildVisible;
                    field(FirstAccountNumber; FirstNumber)
                    {
                        Caption = 'First Number';
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
                Image = Cancel;
                ApplicationArea = All;
                InFooterBar = true;
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
                var
                    SelectDocNumberMethodLbl: Label 'Select a document number method first.';
                begin
                    if Method <> Method::" " then begin
                        ContinuePressed := true;
                        CurrPage.Close();
                    end else
                        error(SelectDocNumberMethodLbl);
                end;
            }
        }
    }
    procedure Continue(): Boolean
    begin
        exit(ContinuePressed);
    end;

    procedure GetMethod(): Option "","Generate","I'll do it myself";
    begin
        exit(Method);
    end;

    procedure GetStartNumber(): Code[20]
    begin
        exit(FirstNumber);
    end;

    trigger OnOpenPage()
    begin
        FirstNumber := '1000';
        ContinuePressed := false;
    end;

    var
        Method: Option " ","Generate them for me","I will do this myself";
        FirstNumber: Code[20];
        AutoBuildVisible: Boolean;
        ContinuePressed: Boolean;
}