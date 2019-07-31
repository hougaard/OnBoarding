table 70310079 "OnBoarding Selected Tag Hgd"
{
    fields
    {
        field(1; Tag; Text[30])
        {
            Caption = 'Tag';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(3; "Tag Type"; Option)
        {
            Caption = 'Tag Type';
            OptionMembers = "G/L Account","No. Series";
            DataClassification = SystemMetadata;

        }
        field(9; "Income/Balance"; Option)
        {
            Caption = 'Income/Balance';
            OptionMembers = "Income Statement","Balance Sheet";
            DataClassification = SystemMetadata;
        }
        field(10; SortIndex; Integer)
        {
            Caption = 'Sort Index';
            DataClassification = SystemMetadata;
        }
        field(8; "Account Category"; Option)
        {
            Caption = 'Account Category';
            OptionMembers = " ",Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
            DataClassification = SystemMetadata;
        }
        field(11; "Account Subcategory Entry No."; Integer)
        {
            Caption = 'Account Subcategory Entry No.';
            DataClassification = SystemMetadata;
        }
        field(14; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
            DataClassification = SystemMetadata;
        }
        field(16; "Reconciliation Account"; Boolean)
        {
            Caption = 'Reconciliation Account';
            DataClassification = SystemMetadata;
        }
        field(43; "Gen. Posting Type"; Option)
        {
            Caption = 'General Posting Type';
            OptionMembers = " ",Purchase,Sale;
            DataClassification = SystemMetadata;
        }
        field(44; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'General Business Posting Group';
            DataClassification = SystemMetadata;
        }
        field(45; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'General Product Posting Group';
            DataClassification = SystemMetadata;
        }
        field(54; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = SystemMetadata;
        }
        field(55; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = SystemMetadata;
        }
        field(56; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = SystemMetadata;
        }
        field(57; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Business Posting Group';
            DataClassification = SystemMetadata;
        }
        field(58; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = SystemMetadata;
        }
        field(100; TagValue; Code[30])
        {
            Caption = 'Tag Value';
            DataClassification = SystemMetadata;
        }
        field(200; "Indention Level"; Integer)
        {
            Caption = 'Indention Level';
            DataClassification = SystemMetadata;
        }
        field(201; "Totals Group"; Text[50])
        {
            Caption = 'Totals Group';
            DataClassification = SystemMetadata;
        }
        field(202; "Total Begin/End"; Option)
        {
            Caption = 'Total Begin/End';
            OptionMembers = " ","Begin","End";
            DataClassification = SystemMetadata;
        }
        field(300; "Filter Tag Template"; Text[250])
        {
            Caption = 'Filter Tag Template';
            DataClassification = SystemMetadata;
        }
        field(301; "Filter Tag List"; Text[250])
        {
            Caption = 'Filter Tag List';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Income/Balance", SortIndex) { }
    }
    procedure TransferFrom(Tag: Record "Package Tag Hgd")
    begin
        "Income/Balance" := tag."Income/Balance";
        "Account Category" := tag."Account Category";
        "Account Subcategory Entry No." := tag."Account Subcategory Entry No.";
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