page 70310079 "OnBoarding Step 4 Hgd"
{
    // Upload a chart of account Excel
    PageType = NavigatePage;
    Caption = 'OnBoarding';

    layout
    {
        area(Content)
        {
            Group(instructions)
            {
                Caption = 'Instructions';
                label(l1)
                {
                    Caption = 'Upload an XLSX Excel spreadsheet file. The first sheet in the file should have the following layout with a header row and be called "sheet1".';
                }
                label(c1)
                {
                    Caption = 'A Column: Account Number';
                }
                label(c2)
                {
                    Caption = 'B Column: Account Name';
                }
                label(c3)
                {
                    Caption = 'C Column: income/balance (Specify if this account is part of the income statement or balance sheet)';
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
            action(Import)
            {
                Caption = 'Import Excel File';
                InFooterBar = true;
                trigger OnAction()
                var
                    ImportExcel: Codeunit "Onboarding Import COA Hgd";
                begin
                    ImportExcel.Run();
                end;
            }
            action(ContinueActin)
            {
                Caption = 'Continue';
                InFooterBar = true;
                trigger OnAction()
                begin
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

    Var
        ContinuePressed: Boolean;
}
