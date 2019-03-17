table 92105 "OnBoarding Selected Tag"
{
    fields
    {
        field(1; Tag; Text[30]) { }
        field(2; Description; Text[250]) { }
        field(3; "Tag Type"; Option)
        {
            OptionMembers = "G/L Account","No. Series";
        }
        field(9; "Income/Balance"; Option)
        {
            OptionMembers = "Income Statement","Balance Sheet";
        }
        field(10; SortIndex; Integer)
        { }
        field(8; "Account Category"; Option)
        {
            OptionMembers = " ",Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;

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

        field(100; TagValue; Code[30])
        {
        }
        field(200; "Indention Level"; Integer) { }
        field(201; "Totals Group"; Text[50]) { }
        field(202; "Total Begin/End"; Option)
        {
            OptionMembers = " ","Begin","End";
        }
    }
    keys
    {
        key(PK; SortIndex) { }
    }
}