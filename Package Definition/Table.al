table 92101 "OnBoarding Table"
{
    DataPerCompany = false;
    fields
    {
        field(1; "Package ID"; Code[30])
        {
            TableRelation = "OnBoarding Package";
        }
        field(2; "Table No."; Integer) { }
        field(3; "Desciption"; Text[250]) { }

    }
    keys
    {
        key(PK; "Package ID", "Table No.") { }
    }
}