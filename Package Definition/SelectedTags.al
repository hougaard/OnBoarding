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
        field(100; TagValue; Code[30])
        {
        }
        field(200; "Indention Level"; Integer) { }
    }
}