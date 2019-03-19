page 92107 "OnBoarding Step 0"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    UsageCategory = Administration;
    layout
    {
        area(Content)
        {
            group(grp)
            {
                Caption = 'OnBoarding - Get Started';
                label(Welcome)
                {
                    ApplicationArea = All;
                    Caption = 'OnBoarding is a tool that will let you select setup for the entire system in one easy operation.';
                }
                label(What)
                {
                    ApplicationArea = All;
                    Caption = 'You can get a minimal chart of account with everything needed for the chosen setup. Document numbers for everything are also generated.';
                }
                label(Info)
                {
                    ApplicationArea = All;
                    Caption = 'Click start to intiate the onboarding process.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                InFooterBar = true;
                RunObject = Page "Package List";
            }
            action(Start)
            {
                ApplicationArea = All;
                InFooterBar = true;
                trigger OnAction()
                var
                    OnMgt: Codeunit "OnBoarding Management";
                begin
                    OnMgt.RunTheProcess();
                    CurrPage.Close();
                end;
            }
        }
    }
}