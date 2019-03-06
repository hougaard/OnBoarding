page 92100 "Package List"
{
    PageType = List;
    SourceTable = "OnBoarding Package";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            group(Packages)
            {
                repeater(Rep)
                {
                    field(ID; ID) { ApplicationArea = All; }
                    field(Description; Description) { ApplicationArea = All; }
                    field(Author; Author) { ApplicationArea = All; }
                    field(Country; Country) { ApplicationArea = All; }
                    field("Minimum Version"; "Minimum Version") { ApplicationArea = All; }
                }
            }
        }
        area(FactBoxes)
        {
            part(Tables; "Package Tables FactBox")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdatePackageList)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    OnMgt: Codeunit "OnBoarding Management";
                begin
                    OnMgt.GetPackages();
                end;
            }
            action(CreatePackage)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    PackageMgt: Codeunit "Onboarding Package Export";
                begin
                    PackageMgt.xx('FIN',
                                   'Finance',
                                   'Microsoft',
                                   'NA',
                                   '13.0.0.0',
                                   '3|5|98|247|252');
                end;
            }
        }
        area(Navigation)
        {
            action(TablesAction)
            {
                Caption = 'Tables';
                RunObject = Page "Package Tables";
                RunPageLink = "Package ID" = field (ID);
            }
        }
    }
}
page 92101 "Package Tables"
{
    PageType = List;
    SourceTable = "OnBoarding Table";

    layout
    {
        area(Content)
        {
            Group(Tables)
            {
                repeater(Rep)
                {
                    field("Table No."; "Table No.") { ApplicationArea = All; }
                    field(Desciption; Desciption) { ApplicationArea = All; }
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(FieldsAction)
            {
                Caption = 'Fields';
                RunObject = Page "Table Fields";
                RunPageLink = "Package ID" = field ("Package ID"), "Table No." = field ("Table No.");
            }
        }
    }
}
page 92102 "Package Tables Factbox"
{
    PageType = ListPart;
    SourceTable = "OnBoarding Table";

    layout
    {
        area(Content)
        {
            Group(Tables)
            {
                repeater(Rep)
                {
                    field("Table No."; "Table No.") { ApplicationArea = All; }
                    field(Desciption; Desciption) { ApplicationArea = All; }
                }
            }
        }
    }
}

page 92103 "Table Fields"
{
    PageType = List;
    SourceTable = "OnBoarding Field";
    layout
    {
        area(Content)
        {
            group("Fields")
            {
                repeater(Rep)
                {
                    field("Record No."; "Record No.") { ApplicationArea = All; }
                    field("Field No."; "Field No.") { ApplicationArea = All; }
                    field("Field Value"; "Field Value") { ApplicationArea = All; }
                }
            }
        }
    }
}