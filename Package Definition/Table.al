table 70310076 "OnBoarding Table"
{
    DataPerCompany = false;
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
        }
        field(3; "Desciption"; Text[250])
        {
            DataClassification = SystemMetadata;
        }

    }
    keys
    {
        key(PK; "Package ID", "Table No.") { }
    }
}