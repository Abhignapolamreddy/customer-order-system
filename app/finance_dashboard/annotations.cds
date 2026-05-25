using InvoiceService as service from '../../srv/invoice-service';

annotate service.Invoices with @(

    UI.HeaderInfo: {
        TypeName: 'Invoice',
        TypeNamePlural: 'Invoices',
        Title: {
            Value: ID
        }
    },

    UI.SelectionFields: [
        status,
        dueDate
    ],

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: 'Invoice Date',
            Value: invoiceDate
        },
        {
            $Type: 'UI.DataField',
            Label: 'Due Date',
            Value: dueDate
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Amount',
            Value: totalAmount
        },
        {
            $Type: 'UI.DataField',
            Label: 'Tax Amount',
            Value: taxAmount
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Status',
            Value      : status,
            Criticality: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'status'},
                    'PAID'
                ]},
                3,
                {$If: [
                    {$Eq: [
                        {$Path: 'status'},
                        'UNPAID'
                    ]},
                    2,
                    {$If: [
                        {$Eq: [
                            {$Path: 'status'},
                            'OVERDUE'
                        ]},
                        1,
                        {$If: [
                            {$Eq: [
                                {$Path: 'status'},
                                'CONFIRMED'
                            ]},
                            3,
                            {$If: [
                            {$Eq: [
                                {$Path: 'status'},
                                'DRAFT'
                            ]},
                            5
                        ]}
                        ]}
                    ]}
                ]}
            ]}}
        }
    ],

    UI.FieldGroup #InvoiceDetails: {
        Data: [
            {
                $Type: 'UI.DataField',
                Label: 'Invoice Date',
                Value: invoiceDate
            },
            {
                $Type: 'UI.DataField',
                Label: 'Due Date',
                Value: dueDate
            },
            {
                $Type: 'UI.DataField',
                Label: 'Total Amount',
                Value: totalAmount
            },
            {
                $Type: 'UI.DataField',
                Label: 'Tax Amount',
                Value: taxAmount
            },
            {
                $Type: 'UI.DataField',
                Label: 'Status',
                Value: status
            },
            {
                $Type: 'UI.DataField',
                Label: 'Paid On',
                Value: paidOn
            }
        ]
    },

    UI.DataPoint #RevenueKPI: {
        Title: 'Total Revenue',
        Value: totalAmount
    },

    UI.DataPoint #OverdueKPI: {
        Title: 'Overdue',
        Value: OverdueFlag,
        CriticalityCalculation: {
            ImprovementDirection: #MINIMIZE,
            ToleranceRangeLowValue: 0,
            DeviationRangeLowValue: 1
        }
    },

    UI.HeaderFacets: [
        {
            $Type: 'UI.ReferenceFacet',
            ID: 'RevenueKPI',
            Label: 'Total Revenue',
            Target: '@UI.DataPoint#RevenueKPI'
        },
        {
            $Type: 'UI.ReferenceFacet',
            ID: 'OverdueKPI',
            Label: 'Overdue',
            Target: '@UI.DataPoint#OverdueKPI'
        }
    ],

    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet',
            ID: 'InvoiceDetails',
            Label: 'General Information',
            Target: '@UI.FieldGroup#InvoiceDetails'
        }
    ],

    UI.Identification: [
        {
            $Type: 'UI.DataFieldForAction',
            Action: 'InvoiceService.markAsPaid',
            Label: 'Mark as Paid'
        }
    ]
);


annotate service.Invoices with {
    status @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            CollectionPath: 'UniqueInvoiceStatuses',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: status,
                ValueListProperty: 'status'
            }]
        }
    );
};
