table 92103 "Package Tag"
{
    fields
    {
        field(1; Tag; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Tag Type"; Option)
        {
            OptionMembers = "G/L Account","No. Series";
            DataClassification = SystemMetadata;
        }
        field(4; "Account Type"; Option)
        {
            OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";
            DataClassification = SystemMetadata;
        }
        field(8; "Account Category"; Option)
        {
            OptionMembers = " ",Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
            DataClassification = SystemMetadata;
        }
        field(9; "Income/Balance"; Option)
        {
            OptionMembers = "Income Statement","Balance Sheet";
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


        field(100; "Groups"; Text[250])
        {
            // Comma separated, first is deepest level
            DataClassification = SystemMetadata;
        }
        field(101; Description; Text[250])
        {
            DataClassification = SystemMetadata;

        }
        field(125; "Help Text 1"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(126; "Help Text 2"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(127; "Help Text 3"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(128; "Help Text 4"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(200; "Package ID"; Code[30])
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Package ID", Tag) { }
    }
}