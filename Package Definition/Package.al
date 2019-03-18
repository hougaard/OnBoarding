table 92100 "OnBoarding Package"
{
    fields
    {
        field(1; ID; Code[30]) { }
        field(2; Description; Text[250]) { }
        field(3; Author; Text[250]) { }
        field(4; Country; Code[10])
        {
            // W1, NA, DK, etc...
        }
        field(5; "Minimum Version"; Code[20]) { }
        field(6; "Module"; Code[20]) { }
        field(100; "Select"; Boolean) { }
        field(200; "SortIndex"; Integer) { }
    }
    keys
    {
        key(PK; ID) { }
        key(Sort; SortIndex) { }
    }
}