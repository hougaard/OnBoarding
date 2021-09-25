table 70310077 "OnBoarding Field Hgd"
{
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
            TableRelation = "OnBoarding Table Hgd" where("Package ID" = field("Package ID"));
        }
        field(3; "Record No."; Integer)
        {
            Caption = 'Record No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Field No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field No.';
        }
        field(5; "Special Action"; Option)
        {
            Caption = 'Special Action';
            DataClassification = SystemMetadata;
            OptionMembers = " ","Account","Number Series","Account Filter";
        }
        field(100; "Field Value"; Text[2000])
        {
            Caption = 'Field Value';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Package ID", "Table No.", "Record No.", "Field No.")
        { }
    }
}