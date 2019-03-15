page 92109 "OnBoarding Step 3"
{
    PageType = Card;
    // How do you want your Chart of Accounts
    layout
    {
        area(Content)
        {
            group(g1)
            {
                Caption = 'How do you want your Chart Of Accounts';
                field(How; Method)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        Method: Option "Generate one for me","I'll upload one","Use the existing";

}