table 70310080 "OnBoarding Modules Hgd"
{
    fields
    {
        field(1; "Module ID"; Code[20])
        {
            Caption = 'Module ID';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(10; "Select"; Boolean)
        {
            Caption = 'Select';
            DataClassification = SystemMetadata;
        }
        field(20; "Sorting Order"; Integer)
        {
            Caption = 'Sorting Order';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Module ID") { }
        key(Sort; "Sorting Order") { }
    }
}