table 70310081 "Package Builder Table Hgd"
{
    Caption = 'Package Builder Table';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Table No.."; Integer)
        {
            Caption = 'Table No..';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(3; Filters; Text[2000])
        {
            Caption = 'Filters';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Table No..")
        {
            Clustered = true;
        }
    }

}
