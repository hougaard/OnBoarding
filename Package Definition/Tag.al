table 70310078 "Package Tag Hgd"
{
    fields
    {
        field(1; Tag; Code[20])
        {
            Caption = 'Tag';
            DataClassification = SystemMetadata;
        }
        field(2; "Tag Type"; Option)
        {
            Caption = 'Tag Type';
            OptionMembers = "G/L Account","No. Series","Account Filter";
            DataClassification = SystemMetadata;
        }
        field(4; "Account Type"; Option)
        {
            Caption = 'Account Type';
            OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";
            DataClassification = SystemMetadata;
        }
        field(8; "Account Category"; Option)
        {
            Caption = 'Account Category';
            OptionMembers = " ",Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
            DataClassification = SystemMetadata;
        }
        field(9; "Income/Balance"; Option)
        {
            Caption = 'Income/Balance';
            OptionMembers = "Income Statement","Balance Sheet";
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


        field(100; "Groups"; Text[250])
        {
            Caption = 'Groups';
            // Comma separated, first is deepest level
            DataClassification = SystemMetadata;
        }
        field(101; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;

        }
        field(125; "Help Text"; Text[1000])
        {
            Caption = 'Help Text';
            DataClassification = SystemMetadata;
        }

        field(200; "Package ID"; Code[30])
        {
            Caption = 'Package ID';
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
        key(PK; "Package ID", Tag) { }
    }
}