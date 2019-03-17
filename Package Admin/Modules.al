table 92104 "OnBoarding Modules"
{
    fields
    {
        field(1; "Module ID"; Code[20])
        { }
        field(2; Description; Text[250])
        { }
        field(10; "Select"; Boolean)
        { }
        field(20; "Sorting Order"; Integer)
        { }
    }
    keys
    {
        key(PK; "Module ID") { }
        key(Sort; "Sorting Order") { }
    }
}