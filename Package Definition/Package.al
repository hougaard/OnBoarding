table 92100 "OnBoarding Package"
{
    fields
    {
        field(1; ID; Code[30]) { DataClassification = SystemMetadata; }
        field(2; Description; Text[250]) { DataClassification = SystemMetadata; }
        field(3; Author; Text[250]) { DataClassification = SystemMetadata; }
        field(4; Country; Code[10])
        {
            // W1, NA, DK, etc...
            DataClassification = SystemMetadata;
        }
        field(5; "Minimum Version"; Code[20]) { DataClassification = SystemMetadata; }
        field(6; "Module"; Code[20]) { DataClassification = SystemMetadata; }
        field(100; "Select"; Boolean) { DataClassification = SystemMetadata; }
        field(200; "SortIndex"; Integer) { DataClassification = SystemMetadata; }
    }
    keys
    {
        key(PK; ID) { }
        key(Sort; SortIndex) { }
    }
}