table 92103 "Package Tag"
{
    fields
    {
        field(1; Tag; Code[20])
        {

        }
        field(2; "Tag Type"; Option)
        {
            OptionMembers = "G/L Account","No. Series";
        }
        field(4; "Account Type"; Option)
        {
            OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";
        }
        field(8; "Account Category"; Option)
        {
            OptionMembers = " ",Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;

        }
        field(9; "Income/Balance"; Option)
        {
            OptionMembers = "Income Statement","Balance Sheet";
        }
        field(14; "Direct Posting"; Boolean)
        {
        }
        field(16; "Reconciliation Account"; Boolean)
        {
        }
        field(43; "Gen. Posting Type"; Option)
        {
            OptionMembers = " ",Purchase,Sale;
        }
        field(44; "Gen. Bus. Posting Group"; Code[20])
        {
        }
        field(45; "Gen. Prod. Posting Group"; Code[20])
        {
        }
        field(54; "Tax Area Code"; Code[20])
        {
        }
        field(55; "Tax Liable"; Boolean)
        {
        }
        field(56; "Tax Group Code"; Code[20])
        {
        }
        field(57; "VAT Bus. Posting Group"; Code[20])
        {
        }
        field(58; "VAT Prod. Posting Group"; Code[20])
        {
        }


        field(100; "Groups"; Text[250])
        {
            // Comma separated, first is deepest level
        }
        field(101; Description; Text[250]) { }
        field(125; "Help Text 1"; Text[250]) { }
        field(126; "Help Text 2"; Text[250]) { }
        field(127; "Help Text 3"; Text[250]) { }
        field(128; "Help Text 4"; Text[250]) { }
        field(200; "Package ID"; Code[30]) { }
    }
    keys
    {
        key(PK; "Package ID", Tag) { }
    }
}