page 70310082 "OnBoarding Step 7"
{
    PageType = NavigatePage;
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
                                begin
                                    AutoBuildVisible := true;
                                end;
                            Method::" ":
                                begin
                                    AutoBuildVisible := false;
                                End;
                            Method::"I will do this myself":
                                begin
                                    AutoBuildVisible := false;
                                end;
                        end;
                    end;
                }
                group(AutoBuild)
                {
                    Caption = 'Autogeneration Parameters';
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
                begin
                    if Method <> Method::" " then begin
                        ContinuePressed := true;
                        CurrPage.Close();
                    end else
                        error('Select a document number method first.');
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