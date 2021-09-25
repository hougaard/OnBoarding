page 70310075 "OnBoarding Step 0 Hgd"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding';
    UsageCategory = Administration;
    ApplicationArea = All;
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
                field(CompanyInformationCtl; CompanyInformation)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                }
                label(Info)
                {
                    ApplicationArea = All;
                    Caption = 'Click start to initiate the onboarding process.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            /* Moved to test app
            action(Setup)
            {
                ApplicationArea = All;
                InFooterBar = true;
                RunObject = Page "Package List";
            }
            */
            action(Start)
            {
                ApplicationArea = All;
                Image = Start;
                InFooterBar = true;
                trigger OnAction()
                var
                    OnMgt: Codeunit "OnBoarding Management Hgd";
                begin
                    OnMgt.RunTheProcess();
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        L1Lbl: Label 'All the setup will go into company "';
        L2Lbl: Label '", make sure you''re in the right company before continue.';
    begin
        CompanyInformation := L1Lbl +
                              CompanyName() +
                              L2Lbl;
    end;

    var
        CompanyInformation: Text;
}