table 70310077 "OnBoarding Field"
{
    fields
    {
        field(1; "Package ID"; Code[30])
        {
            TableRelation = "OnBoarding Package";
            DataClassification = SystemMetadata;
        }
        field(2; "Table No."; Integer)
        {
            DataClassification = SystemMetadata;
            TableRelation = "OnBoarding Table" where ("Package ID" = field ("Package ID"));
        }
        field(3; "Record No."; Integer)
        { DataClassification = SystemMetadata; }
        field(4; "Field No."; Integer)
        {
            DataClassification = SystemMetadata;

        }
        field(5; "Special Action"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = " ","Account","Number Series","Account Filter";
        }
        field(100; "Field Value"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Package ID", "Table No.", "Record No.", "Field No.")
        { }
    }
}