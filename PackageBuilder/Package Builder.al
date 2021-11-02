page 70310085 "Package Builder Hgd"
{
    PageType = NavigatePage;
    Caption = 'OnBoarding Package Builder';
    UsageCategory = Administration;
    ApplicationArea = all;
    SourceTable = "Package Builder Table Hgd";
    layout
    {
        area(Content)
        {
            repeater(Rep)
            {

                field("Table No.."; Rec."Table No..")
                {
                    ToolTip = 'Specifies the value of the Table No.. field';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Filters; Rec.Filters)
                {
                    ToolTip = 'Specifies the value of the Filters field';
                    ApplicationArea = All;
                }
            }
        }
    }
}