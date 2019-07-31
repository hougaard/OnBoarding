table 70310076 "OnBoarding Table Hgd"
{
    DataPerCompany = false;
    fields
    {
        field(1; "Package ID"; Code[30])
        {
            Caption = 'Package ID';
            TableRelation = "OnBoarding Package Hgd";
            DataClassification = SystemMetadata;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Desciption"; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }

    }
    keys
    {
        key(PK; "Package ID", "Table No.") { }
    }
}