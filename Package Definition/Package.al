table 70310075 "OnBoarding Package Hgd"
{
    fields
    {
        field(1; ID; Code[30])
        {
            Caption = 'ID';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(3; Author; Text[250])
        {
            Caption = 'Author';
            DataClassification = SystemMetadata;
        }
        field(4; Country; Code[10])
        {
            Caption = 'Country';
            // W1, NA, DK, etc...
            DataClassification = SystemMetadata;
        }
        field(5; "Minimum Version"; Code[20])
        {
            Caption = 'Minumum Version';
            DataClassification = SystemMetadata;
        }
        field(6; "Module"; Code[20])
        {
            Caption = 'Module';
            DataClassification = SystemMetadata;
        }
        field(100; "Select"; Boolean)
        {
            Caption = 'Select';
            DataClassification = SystemMetadata;
        }
        field(200; "SortIndex"; Integer)
        {
            Caption = 'Sort Index';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; ID) { }
        key(Sort; SortIndex) { }
    }
}