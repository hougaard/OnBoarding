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
                    field(Module; Module) { ApplicationArea = All; }
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
                SubPageLink = "Package ID" = field (ID);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdatePackageList)
            {
                Caption = 'Read Packages from GitHub';
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
                Caption = 'Create Packages from CRONUS';
                ApplicationArea = All;

                trigger OnAction()
                var
                    PackageMgt: Codeunit "Onboarding Package Export";
                    Appl: Codeunit "Application System Constants";
                begin
                    PackageMgt.BuildPackageAndExportToGitHub('BASE',
                                    'BASE-SETUP',
                                    'Base Setup',
                                    'Microsoft',
                                    Appl.ApplicationVersion(),
                                    '8|9|11');
                    // Finance
                    PackageMgt.BuildPackageAndExportToGitHub('FIN',
                                   'BASE-FIN',
                                   'Finance Management Setup',
                                   'Microsoft',
                                   Appl.ApplicationVersion(),
                                   '3|5|98|247|250|251|252');
                    PackageMgt.BuildAccountSchedulePackges('FIN',
                                                           'Microsoft',
                                                           Appl.ApplicationVersion());

                    // Sales Tax
                    PackageMgt.BuildPackageAndExportToGitHub('SALE',
                                   'SALES_TAX',
                                   'Canadian Sales Tax',
                                   'Microsoft',
                                   Appl.ApplicationVersion(),
                                   '318|319|320|321|322|326|327');

                    // Sale
                    PackageMgt.BuildPackageAndExportToGitHub('SALE',
                                   'BASE-SALE',
                                   'Sale Basis Setup',
                                   'Microsoft',
                                   Appl.ApplicationVersion(),
                                   '311|92');
                    // Purchase
                    PackageMgt.BuildPackageAndExportToGitHub('PURCHASE',
                                   'BASE-PURCHASE',
                                   'Purchase Basis Setup',
                                   'Microsoft',
                                   Appl.ApplicationVersion(),
                                   '312|93');
                    // Iventory
                    PackageMgt.BuildPackageAndExportToGitHub('INVENTORY',
                                   'BASE-INVENTORY',
                                   'Inventory Basis Setup',
                                   'Microsoft',
                                   Appl.ApplicationVersion(),
                                   '313|94');

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
                ApplicationArea = All;
            }
            action(TagsAction)
            {
                Caption = 'Tags';
                RunObject = Page "Package Tags";
                RunPageLink = "Package ID" = field (ID);
                ApplicationArea = All;
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
                    field("Table No."; "Table No.")
                    { ApplicationArea = All; }
                    field(Desciption; Desciption)
                    { ApplicationArea = All; }
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

page 92105 "Package Tags"
{
    SourceTable = "Package Tag";
    PageType = List;
    layout
    {
        area(Content)
        {
            group(Tags)
            {
                Caption = 'Tags';
                repeater(Rep)
                {
                    field(Tag; Tag) { ApplicationArea = All; }
                    field("Tag Type"; "Tag Type") { ApplicationArea = All; }
                    field(Description; Description) { ApplicationArea = All; }
                    field(Groups; Groups) { ApplicationArea = All; }
                }
            }
        }
    }
}