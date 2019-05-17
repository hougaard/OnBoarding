table 70310079 "OnBoarding Selected Tag"
{
    fields
    {
        field(1; Tag; Text[30])
        {
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Tag Type"; Option)
        {
            OptionMembers = "G/L Account","No. Series";
            DataClassification = SystemMetadata;

        }
        field(9; "Income/Balance"; Option)
        {
            OptionMembers = "Income Statement","Balance Sheet";
            DataClassification = SystemMetadata;
        }
        field(10; SortIndex; Integer)
        { DataClassification = SystemMetadata; }
        field(8; "Account Category"; Option)
        {
            OptionMembers = " ",Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
            DataClassification = SystemMetadata;
        }
        field(14; "Direct Posting"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(16; "Reconciliation Account"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(43; "Gen. Posting Type"; Option)
        {
            OptionMembers = " ",Purchase,Sale;
            DataClassification = SystemMetadata;
        }
        field(44; "Gen. Bus. Posting Group"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(45; "Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(54; "Tax Area Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(55; "Tax Liable"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(56; "Tax Group Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(57; "VAT Bus. Posting Group"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(58; "VAT Prod. Posting Group"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(100; TagValue; Code[30])
        {
            DataClassification = SystemMetadata;
        }
        field(200; "Indention Level"; Integer) { DataClassification = SystemMetadata; }
        field(201; "Totals Group"; Text[50]) { DataClassification = SystemMetadata; }
        field(202; "Total Begin/End"; Option)
        {
            OptionMembers = " ","Begin","End";
            DataClassification = SystemMetadata;
        }
        field(300; "Filter Tag Template"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(301; "Filter Tag List"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Income/Balance", SortIndex) { }
    }
    procedure TransferFrom(Tag: REcord "Package Tag")
    begin
        "Income/Balance" := tag."Income/Balance";
        "Account Category" := tag."Account Category";
        "Gen. Bus. Posting Group" := tag."Gen. Bus. Posting Group";
        "Gen. Posting Type" := tag."Gen. Posting Type";
        "Gen. Prod. Posting Group" := tag."Gen. Prod. Posting Group";
        "Direct Posting" := tag."Direct Posting";
        "Tax Area Code" := tag."Tax Area Code";
        "Tax Group Code" := tag."Tax Group Code";
        "Tax Liable" := tag."Tax Liable";
        "Reconciliation Account" := tag."Reconciliation Account";
        "VAT Bus. Posting Group" := tag."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := tag."VAT Prod. Posting Group";
        "Filter Tag List" := tag."Filter Tag List";
        "Filter Tag Template" := tag."Filter Tag Template";
    end;
}