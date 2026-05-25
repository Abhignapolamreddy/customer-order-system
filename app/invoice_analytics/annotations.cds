using InvoiceService as service from '../../srv/invoice-service';

annotate service.InvoiceAnalytics with @(

    UI.Chart #Chart: {
        $Type: 'UI.ChartDefinitionType',

        ChartType: #Column,

        DynamicMeasures: [
            '@Analytics.AggregatedProperty#TotalRevenue',
            '@Analytics.AggregatedProperty#OverdueCount'
        ],

        Dimensions: [
            status
        ],

        MeasureAttributes: [
            {
                $Type: 'UI.ChartMeasureAttributeType',
                DynamicMeasure: '@Analytics.AggregatedProperty#TotalRevenue',
                Role: #Axis1
            },
            {
                $Type: 'UI.ChartMeasureAttributeType',
                DynamicMeasure: '@Analytics.AggregatedProperty#OverdueCount',
                Role: #Axis1
            }
        ],

        DimensionAttributes: [
            {
                $Type: 'UI.ChartDimensionAttributeType',
                Dimension: status,
                Role: #Category
            }
        ]
    },

    UI.PresentationVariant #Default: {
        Visualizations: [
            '@UI.Chart#Chart',
            '@UI.LineItem'
        ]
    },

    UI.SelectionPresentationVariant #Default: {
        PresentationVariant: '@UI.PresentationVariant#Default'
    },

    UI.SelectionFields: [
        status
    ],

    UI.LineItem: [
        {
            Value: status,
            Label: 'Status'
        },
        {
            Value: totalAmount,
            Label: 'Total Revenue'
        },
        {
            Value: overdueFlag,
            Label: 'Overdue Count'
        }
    ]
);