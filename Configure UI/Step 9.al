page 70310084 "OnBoarding Step 9 Hgd"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding - Review and Finish';
    layout
    {
        area(Content)
        {
            group(grp)
            {
                Caption = 'Review and Finish';
                label(Review)
                {
                    ApplicationArea = All;
                    Caption = 'Now we''re ready to finish this, the following will happened:';
                }
                label(Step1)
                {
                    ApplicationArea = All;
                    Caption = '1. All the Setup in packages chosen will be generated';
                }
                label(Step2)
                {
                    ApplicationArea = All;
                    Caption = '2. The Chart Of Account will be created if chosen';
                }
                label(Step3)
                {
                    ApplicationArea = All;
                    Caption = '3. The Setup in all packages will use the new Account Numbers.';
                }
                label(Step4)
                {
                    ApplicationArea = All;
                    Caption = '4. Create the numbers as specified and reference them in the setup.';
                }
                field(CreateRapidStart; CreateRapidStart)
                {
                    ApplicationArea = All;
                    Caption = '5. Create a Configuration Package for easy export of generated setup';
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
                Caption = 'Create Everything';
                InFooterBar = true;
                trigger OnAction()
                var
                    OnMgt: Codeunit "OnBoarding Management Hgd";
                    L: Label 'All done, all the packages you have select have been applied, please verify the setup before you start posting.';
                begin
                    OnMgt.CreateEverything();
                    if CreateRapidStart then
                        OnMgt.CreateRapidStartPackage();
                    Message(L);
                    ContinuePressed := true;
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ContinuePressed := false;
        CreateRapidStart := true;
    end;

    procedure Continue(): Boolean
    begin
        exit(ContinuePressed);
    end;

    Var
        ContinuePressed: Boolean;
        CreateRapidStart: Boolean;
}