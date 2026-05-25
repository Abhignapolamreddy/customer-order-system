using OrderService as service from '../../srv/order-service';

annotate service.SalesOrders with @(
    UI.HeaderInfo                : {
        TypeName      : 'Order',
        TypeNamePlural: 'My Orders',
        Title         : {Value: ID}
    },

    UI.SelectionFields           : [status],

    UI.FieldGroup #GeneratedGroup: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Order Date',
                Value: orderDate
            },
            {
                $Type: 'UI.DataField',
                Label: 'Total_Amount',
                Value: totalAmount
            },

            {
                $Type: 'UI.DataField',
                Label: 'Customer',
                Value: customer_ID
            },
            {
                $Type: 'UI.DataField',
                Label: 'Status',
                Value: status
            },
            {
                $Type: 'UI.DataField',
                Label: 'Street',
                Value: shippingAddress_street
            },
            {
                $Type: 'UI.DataField',
                Label: 'City',
                Value: shippingAddress_city
            },
            {
                $Type: 'UI.DataField',
                Label: 'State',
                Value: shippingAddress_state
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal Code',
                Value: shippingAddress_postalCode
            },
            {
                $Type: 'UI.DataField',
                Label: 'Country',
                Value: shippingAddress_country
            }
        ]
    },

    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneralInfo',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneratedGroup'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'OrderItemsFacet',
            Label : 'Order Items',
            Target: 'orderItem/@UI.LineItem'
        }
    ],

    UI.LineItem                  : [
        {
            $Type: 'UI.DataField',
            Label: 'Order Date',
            Value: orderDate
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Amount',
            Value: totalAmount
        },
        {
            $Type: 'UI.DataField',
            Label: 'Customer',
            Value: customer_ID
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Status',
            Value      : status,
            Criticality: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'status'},
                    'DELIVERED'
                ]},
                3,
                {$If: [
                    {$Eq: [
                        {$Path: 'status'},
                        'CANCELLED'
                    ]},
                    1,
                    {$If: [
                        {$Eq: [
                            {$Path: 'status'},
                            'SHIPPED'
                        ]},
                        3,
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
        },
        {
            $Type: 'UI.DataField',
            Label: 'Street',
            Value: shippingAddress_street
        },
        {
            $Type: 'UI.DataField',
            Label: 'City',
            Value: shippingAddress_city
        },
        {
            $Type: 'UI.DataField',
            Label: 'State',
            Value: shippingAddress_state
        },
        {
            $Type: 'UI.DataField',
            Label: 'Postal Code',
            Value: shippingAddress_postalCode
        },
        {
            $Type: 'UI.DataField',
            Label: 'Country',
            Value: shippingAddress_country
        }
    ]
);

annotate service.OrderItems with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Label: 'Product',
        Value: product_ID
    },
    {
        $Type: 'UI.DataField',
        Label: 'Quantity',
        Value: quantity
    },
    {
        $Type: 'UI.DataField',
        Label: 'Unit Price',
        Value: unitPrice
    },

    {
        $Type: 'UI.DataField',
        Label: 'Line Total',
        Value: lineTotal
    },
    {
        $Type: 'UI.DataField',
        Label: 'Discount',
        Value: discount
    }
]);

annotate service.SalesOrders with {
    customer @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Customers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: customer_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'customerCode'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name'
            }
        ]
    }
};

annotate service.OrderItems with {
    product @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Products',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: product_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name'
            }
        ]
    };
};

annotate service.SalesOrders with {
    status @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            CollectionPath: 'UniqueOrderStatuses',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: status,
                ValueListProperty: 'status'
            }]
        }
    );
};

annotate service.SalesOrders with @(UI.Identification: [
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'OrderService.confirmOrder',
        Label : 'Confirm'
    },
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'OrderService.shipOrder',
        Label : 'Ship'
    },
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'OrderService.deliverOrder',
        Label : 'Deliver'
    },
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'OrderService.cancelOrder',
        Label : 'Cancel'
    }
]);

annotate service.OrderItems with @(
    UI.HeaderInfo         : {
        TypeName      : 'Order Item',
        TypeNamePlural: 'Order Items',
        Title         : {
            $Type: 'UI.DataField',
            Value: product_ID
        }
    },

    UI.FieldGroup #General: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Product',
                Value: product_ID
            },
            {
                $Type: 'UI.DataField',
                Label: 'Quantity',
                Value: quantity
            },
            {
                $Type: 'UI.DataField',
                Label: 'Unit Price',
                Value: unitPrice
            },
            {
                $Type: 'UI.DataField',
                Label: 'Discount',
                Value: discount
            },
            {
                $Type: 'UI.DataField',
                Label: 'Line Total',
                Value: lineTotal
            }
        ]
    },

    UI.Facets             : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'General Information',
        Target: '@UI.FieldGroup#General'
    }]
);

annotate service.SalesOrders with {
    totalAmount @Common.FieldControl: #ReadOnly;
};

annotate service.OrderItems with {
    unitPrice @Common.FieldControl: #ReadOnly;
    lineTotal @Common.FieldControl: #ReadOnly;
};

annotate service.OrderItems with @(Capabilities.UpdateRestrictions: {Updatable: {$edmJson: {$Eq: [
    {$Path: 'salesOrder/status'},
    'DRAFT'
]}}});

annotate service.SalesOrders with @(Capabilities.UpdateRestrictions: {Updatable: {$edmJson: {$Eq: [
    {$Path: 'status'},
    'DRAFT'
]}}});

annotate service.SalesOrders with actions {

    confirmOrder @Core.OperationAvailable: {$edmJson: {$Eq: [
        {$Path: 'status'},
        'DRAFT'
    ]}};

    shipOrder    @Core.OperationAvailable: {$edmJson: {$Eq: [
        {$Path: 'status'},
        'CONFIRMED'
    ]}};

    deliverOrder @Core.OperationAvailable: {$edmJson: {$Eq: [
        {$Path: 'status'},
        'SHIPPED'
    ]}};

    cancelOrder  @Core.OperationAvailable: {$edmJson: {$Or: [
        {$Eq: [
            {$Path: 'status'},
            'DRAFT'
        ]},
        {$Eq: [
            {$Path: 'status'},
            'CONFIRMED'
        ]},
        {$Eq: [
            {$Path: 'status'},
            'SHIPPED'
        ]}
    ]}};

};

annotate service.OrderItems with {
    unitPrice @Measures.ISOCurrency : currency;
    lineTotal @Measures.ISOCurrency : currency;
};

annotate service.SalesOrders with {
    totalAmount @Measures.ISOCurrency : currency;
};

annotate service.SalesOrders with {
    status @Common.FieldControl: #ReadOnly;
};

annotate service.SalesOrders with {
    shippingAddress_country @mandatory;
    shippingAddress_state @mandatory;
    shippingAddress_city @mandatory;
    shippingAddress_postalCode @mandatory;
    shippingAddress_street @mandatory;
};
