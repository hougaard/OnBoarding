table 92105 "OnBoarding Selected Tag"
{
    fields
    {
        field(1; Tag; Text[30]) { }
        field(2; Description; Text[250]) { }
        field(3; "Tag Type"; Option)
        {
            OptionMembers = "G/L Account","No. Series";
        }
        field(9; "Income/Balance"; Option)
        {
            OptionMembers = "Income Statement","Balance Sheet";
        }
        field(10; SortIndex; Integer)
        { }
        field(100; TagValue; Code[30])
        {
        }
        field(200; "Indention Level"; Integer) { }
        field(201; "Totals Group"; Text[50]) { }
        field(202; "Total Begin/End"; Option)
        {
            OptionMembers = " ","Begin","End";
        }
    }
    keys
    {
        key(PK; SortIndex) { }
    }
}