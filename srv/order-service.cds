using { customer.order.db as db } from '../db/schema';

service OrderService {

    entity Customers as projection on db.Customer;

    entity Products as projection on db.Products;

    @restrict: [
        {
            grant: ['READ'],
            to: ['SalesRep', 'SalesManager', 'Administrator']
        },
        {
            grant: ['CREATE', 'UPDATE'],
            to: ['SalesRep', 'Administrator']
        }
    ]
    entity OrderItems as projection on db.OrderItem;

    entity UniqueOrderStatuses as
        select from SalesOrders {
            key status
        }
        group by status;

    @restrict: [
        {
            grant: ['READ'],
            to: ['SalesRep', 'SalesManager', 'Administrator']
        },
        {
            grant: ['CREATE', 'UPDATE'],
            to: ['SalesRep', 'Administrator']
        },
        {
            grant: ['DELETE'],
            to: ['SalesManager', 'Administrator']
        }
    ]
    entity SalesOrders as projection on db.SalesOrder actions {

        @restrict: [
            {
                grant: '*',
                to: ['SalesManager', 'Administrator']
            }
        ]
        action confirmOrder() returns String;

        @restrict: [
            {
                grant: '*',
                to: ['SalesManager', 'Administrator']
            }
        ]
        action shipOrder();

        @restrict: [
            {
                grant: '*',
                to: ['SalesManager', 'Administrator']
            }
        ]
        action deliverOrder();

        @restrict: [
            {
                grant: '*',
                to: ['SalesManager', 'Administrator']
            }
        ]
        action cancelOrder(reason: String);
    };

}