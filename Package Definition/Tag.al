table 92103 "Package Tag"
{
    fields
    {
        field(1; Tag; Code[20])
        {

        }
        field(2; "Income/Balance"; Option)
        {
            OptionMembers = Income,Balance;
        }
        field(3; "Groups"; Text[250])
        {
            // Comma separated, first is deepest level
        }
        field(25; "Help Text 1"; Text[250]) { }
        field(26; "Help Text 2"; Text[250]) {}
        field(27; "Help Text 3"; Text[250]) {}
        field(28; "Help Text 4"; Text[250]) {}
        
    }
}