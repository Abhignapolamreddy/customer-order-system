const cds = require('@sap/cds');
const { SELECT, UPDATE } = require('@sap/cds/lib/ql/cds-ql');

module.exports = cds.service.impl(async function () {
    const { Customers, Products, SalesOrders, OrderItems } = this.entities;

    this.before('confirmOrder', SalesOrders, async (req) => {
        const orderID = req.params[0].ID;
        
        const order = await SELECT.one
            .from(SalesOrders)
            .where({ ID: orderID });

        if (!order) {
            req.error(404, 'Order not found');
        }

        if (order.status !== 'DRAFT') {
            req.error(400, 'Only draft orders can be confirmed');
        }

        const customer = await SELECT.one
            .from(Customers)
            .where({ ID: order.customer_ID });

        if (!customer) {
            req.error(404, 'Customer not found');
        }

        if (order.totalAmount > customer.creditLimit) {
            req.error(400, 'Customer Credit Limit Exceeded');
        }

        const items = await SELECT
            .from(OrderItems)
            .where({ salesOrder_ID: orderID });

        for (const item of items) {
            const product = await SELECT.one
                .from(Products)
                .where({ ID: item.product_ID });

            if (!product) {
                req.error(404, 'Product not found');
            }

            if (product.stockQty < item.quantity) {
                req.error(400, `Insufficient stock for ${product.name}`);
            }
        }
    });
    this.on('confirmOrder', SalesOrders, async (req) => {
        const orderID = req.params[0].ID;

        const items = await SELECT
            .from(OrderItems)
            .where({ salesOrder_ID: orderID });
        const order = await SELECT.one
            .from(SalesOrders)
            .where({ ID: orderID });
        const customer = await SELECT.one
            .from(Customers)
            .where({ ID: order.customer_ID });
            

        for (const item of items) {
            const product = await SELECT.one
                .from(Products)
                .where({ ID: item.product_ID });

            await UPDATE(Products)
                .set({
                    stockQty: product.stockQty - item.quantity
                })
                .where({ ID: item.product_ID });
        }
        await UPDATE(Customers)
        .set({
            creditLimit: customer.creditLimit - order.totalAmount
        })
        .where({ ID: order.customer_ID });
        await UPDATE(SalesOrders)
            .set({ status: 'CONFIRMED' })
            .where({ ID: orderID });

        return SELECT.one
            .from(SalesOrders)
            .where({ ID: orderID });
    });

    this.on('shipOrder', SalesOrders, async (req) => {
        const orderID = req.params[0].ID;

        const order = await SELECT.one.from(SalesOrders).where({ ID: orderID });

        if (!order) {
            req.error(404, 'Order not found');
        }

        if (order.status !== 'CONFIRMED') {
            req.error(400, 'Only confirmed orders can be shipped');
        }

        await UPDATE(SalesOrders)
            .set({ status: 'SHIPPED' })
            .where({ ID: orderID });

        return SELECT.one.from(SalesOrders).where({ ID: orderID });
    });
    this.on('deliverOrder', SalesOrders, async (req) => {
        const orderID = req.params[0].ID;

        const order = await SELECT.one.from(SalesOrders).where({ ID: orderID });

        if (!order) {
            req.error(404, 'Order not found');
        }

        if (order.status !== 'SHIPPED') {
            req.error(400, 'Only shipped orders can be delivered');
        }

        await UPDATE(SalesOrders)
            .set({ status: 'DELIVERED' })
            .where({ ID: orderID });

        return SELECT.one.from(SalesOrders).where({ ID: orderID });
    });

    this.on('cancelOrder', SalesOrders, async (req) => {
        const orderID = req.params[0].ID;
        const { reason } = req.data;

        const order = await SELECT.one
            .from(SalesOrders)
            .where({ ID: orderID });

        if (!order) {
            req.error(404, 'Order not found');
        }

        if (order.status === 'DELIVERED') {
            req.error(400, 'Delivered orders cannot be cancelled');
        }

        if (order.status === 'CANCELLED') {
            req.error(400, 'Order already cancelled');
        }

        const items = await SELECT
            .from(OrderItems)
            .where({ salesOrder_ID: orderID });

        for (const item of items) {
            const product = await SELECT.one
                .from(Products)
                .where({ ID: item.product_ID });

            if (!product) {
                req.error(404, 'Product not found');
            }

            await UPDATE(Products)
                .set({
                    stockQty: product.stockQty + item.quantity
                })
                .where({ ID: item.product_ID });
        }

        await UPDATE(SalesOrders)
            .set({
                status: 'CANCELLED'
            })
            .where({ ID: orderID });
            if (order.status !== 'DRAFT') {
        const customer = await SELECT.one
            .from(Customers)
            .where({ ID: order.customer_ID });

        await UPDATE(Customers)
    .set({
        creditLimit: Number(
            ((customer.creditLimit || 0) - (order.totalAmount || 0)).toFixed(2)
        )
    })
    }

        return SELECT.one
            .from(SalesOrders)
            .where({ ID: orderID });
    });

    this.before('CREATE', 'SalesOrders.drafts', async (req) => {
        console.log("HOOK RUNNING");

        const items = req.data.orderItem;

        if (!items) return;

        let totalAmount = 0;

        for (const item of items) {
            if (!item.product_ID) continue;

            const product = await SELECT.one
                .from(Products)
                .where({ ID: item.product_ID });

            if (!product) {
                req.error(404, 'Product not found');
            }

            item.unitPrice = product.unitPrice;

            item.lineTotal =
                ((item.quantity || 0) * product.unitPrice) - (item.discount || 0);

            totalAmount += item.lineTotal;
        }

        req.data.totalAmount = totalAmount;
    });
    this.before('PATCH', 'OrderItems.drafts', async (req) => {
    const existing = await SELECT.one(req.subject);

    const salesOrder_ID = req.data.salesOrder_ID ?? existing?.salesOrder_ID;

    if (!salesOrder_ID) return;

    const order = await SELECT.one
        .from(SalesOrders.drafts)
        .where({ ID: salesOrder_ID });

    if (!order) {
        req.error(404, 'Sales order not found');
    }

    if (order.status !== 'DRAFT') {
        req.error(400, 'Order items can only be edited in DRAFT status');
    }

    const product_ID = req.data.product_ID ?? existing?.product_ID;
    const quantity = req.data.quantity ?? existing?.quantity ?? 0;
    const discount = req.data.discount ?? existing?.discount ?? 0;

    if (!product_ID) return;

    const product = await SELECT.one
        .from(Products)
        .where({ ID: product_ID });

    if (!product) {
        req.error(404, 'Product not found');
    }

    req.data.unitPrice = product.unitPrice;

    req.data.lineTotal = Number(
        ((quantity * product.unitPrice) - discount).toFixed(2)
    );

    const items = await SELECT
        .from(OrderItems.drafts)
        .where({ salesOrder_ID });

    let totalAmount = req.data.lineTotal;

    for (const item of items) {
        if (item.ID === req.data.ID) continue;
        totalAmount += item.lineTotal || 0;
    }

    await UPDATE(SalesOrders.drafts)
        .set({
            totalAmount: Number(totalAmount.toFixed(2))
        })
        .where({ ID: salesOrder_ID });
});

    this.before('DELETE', 'OrderItems.drafts', async (req) => {
        const existing = await SELECT.one(req.subject);

        if (!existing?.salesOrder_ID) return;

        const items = await SELECT
            .from(OrderItems.drafts)
            .where({ salesOrder_ID: existing.salesOrder_ID });

        let totalAmount = 0;

        for (const item of items) {
            if (item.ID === existing.ID) continue; 
            totalAmount += item.lineTotal || 0;
        }

        await UPDATE(SalesOrders.drafts)
            .set({
                totalAmount: Number(totalAmount.toFixed(2))
            })
            .where({ ID: existing.salesOrder_ID });
    });
    this.after('deliverOrder', SalesOrders, async (order) => {
        await INSERT.into('Invoice').entries({
            invoiceDate: new Date(),
            dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
            totalAmount: order.totalAmount,
            taxAmount: Number((order.totalAmount * 0.18).toFixed(2)),
            status: 'UNPAID',
            salesOrder_ID: order.ID
        });
    });
   this.before('CREATE', 'SalesOrders', async (req) => {
   const customer = await SELECT.one.from(Customers)
      .where({ ID: req.data.customer_ID });

   //req.data.billingAddress = customer.billingAddress;
   req.data.shippingAddress = customer.shippingAddress;
});
})