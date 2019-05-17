table 70310080 "OnBoarding Modules"
{
    fields
    {
        field(1; "Module ID"; Code[20])
        { DataClassification = SystemMetadata; }
        field(2; Description; Text[250])
        { DataClassification = SystemMetadata; }
        field(10; "Select"; Boolean)
        { DataClassification = SystemMetadata; }
        field(20; "Sorting Order"; Integer)
        { DataClassification = SystemMetadata; }
    }
    keys
    {
        key(PK; "Module ID") { }
        key(Sort; "Sorting Order") { }
    }
}