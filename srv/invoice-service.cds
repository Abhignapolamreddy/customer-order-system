using { customer.order.db as db } from '../db/schema';

service InvoiceService {

    @restrict: [
        {
            grant: ['READ', 'CREATE', 'UPDATE', 'DELETE'],
            to: ['Finance', 'Administrator']
        }
    ]
    entity Invoices as projection on db.Invoice {
        *,
        case
            when dueDate < CURRENT_DATE and status != 'PAID'
            then 1
            else 0
        end as OverdueFlag : Integer

        
    }

    actions {

        @restrict: [
            {
                grant: '*',
                to: ['Finance', 'Administrator']
            }
        ]
        action markAsPaid(paymentRef : String);

    };

    entity UniqueInvoiceStatuses as
        select from db.Invoice {
            key status
        }
        group by status;

    @restrict: [
        {
            grant: '*',
            to: ['Finance', 'Administrator']
        }
    ]
    function getOverdueInvoices(
        daysOverdue : Integer
    ) returns array of Invoices;

    @restrict: [
        {
            grant: '*',
            to: ['Finance', 'Administrator']
        }
    ]

    @Aggregation.ApplySupported: {
        Transformations: [
            'aggregate',
            'groupby',
            'filter',
            'top',
            'skip',
            'orderby'
        ],

        GroupableProperties: [
            status
        ],

        AggregatableProperties: [
            {
                Property: totalAmount
            },
            {
                Property: overdueFlag
            }
        ]
    }

    @Analytics.AggregatedProperty #TotalRevenue: {
        Name: 'TotalRevenue',
        AggregationMethod: 'sum',
        AggregatableProperty: totalAmount,
        ![@Common.Label]: 'Total Revenue'
    }

    @Analytics.AggregatedProperty #OverdueCount: {
        Name: 'OverdueCount',
        AggregationMethod: 'sum',
        AggregatableProperty: overdueFlag,
        ![@Common.Label]: 'Overdue Count'
    }

    entity InvoiceAnalytics as
        select from db.Invoice {
            key status,

            sum(totalAmount) as totalAmount : Decimal(15,2),

            sum(
                case
                    when dueDate < CURRENT_DATE and status != 'PAID'
                    then 1
                    else 0
                end
            ) as overdueFlag : Integer
        }
        group by status;

}