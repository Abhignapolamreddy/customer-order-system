namespace customer.order.db;
using{managed} from '@sap/cds/common';


entity Customer{
    key ID: UUID;
    customerCode:String;
    name:String;
    email:String;
    phone:String;
    creditLimit: Decimal(10,2);
    billingAddress:Address;
    shippingAddress:Address;
}

entity Products{
    key ID: UUID;
    productCode:String;
    name:String;
    unitPrice: Decimal(18,2);
    taxRate: Decimal(5,2);
    stockQty: Integer;
}

@odata.draft.enabled
entity SalesOrder:managed{
    key ID: UUID;
    orderDate: Date default $now;
    totalAmount: Decimal(18,2) default 0.00;
    status: OrderStatus default 'DRAFT';
    @mandatory
    shippingAddress:Address not null;
    currency    : String(3) default 'INR';
    @mandatory
    customer:Association to Customer;
    @mandatory
    orderItem:Composition of many OrderItem on orderItem.salesOrder = $self;
}
entity OrderItem:managed{
    key ID: UUID;
    quantity: Integer not null;
    unitPrice: Decimal(18,2)default 0.00 ;
    discount: Decimal(18,2) default 0;
    lineTotal: Decimal(18,2)default 0.00;
    salesOrder:Association to SalesOrder;
    currency : String(3) default 'INR';
    product:Association to Products;
}

entity Invoice:managed{
    key ID: UUID;
    invoiceDate: Date default $now;
    dueDate: Date;
    totalAmount: Decimal(10,2);
    taxAmount: Decimal(10,2);
    status: InvoiceStatus default 'UNPAID';
    paidOn: Date;
    salesOrder:Association to one SalesOrder;
}

type Address{
    street:String;
    city:String;
    state:String;
    postalCode:String;
    country:String;
}

type OrderStatus: String enum {
    DRAFT;
    PENDING;    
    CONFIRMED;
    SHIPPED;
    DELIVERED;
    CANCELLED;
}  

type InvoiceStatus: String enum {
    PAID;
    UNPAID;
    OVERDUE;
}

