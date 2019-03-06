table 92102 "OnBoarding Field"
{
    fields
    {
        field(1; "Package ID"; Code[30])
        {
            TableRelation = "OnBoarding Package";
        }
        field(2; "Table No."; Integer)
        {
            TableRelation = "OnBoarding Table" where ("Package ID" = field ("Package ID"));
        }
        field(3; "Record No."; Integer)
        { }
        field(4; "Field No."; Integer)
        {

        }
        field(5; "Special Action"; Option)
        {
            OptionMembers = " ;Account;Number Series";
        }
        field(100; "Field Value"; Text[250])
        {

        }
    }
    keys
    {
        key(PK; "Package ID", "Table No.", "Record No.", "Field No.")
        { }
    }
}