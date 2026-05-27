const cds=require('@sap/cds');
const { SELECT, UPDATE } = require('@sap/cds/lib/ql/cds-ql');

module.exports=cds.service.impl(async function(){
    const{Invoices}=this.entities;
   this.on('markAsPaid', Invoices, async (req) => {
        const invoiceID = req.params[0].ID;

        const invoice = await SELECT.one
            .from(Invoices)
            .where({ ID: invoiceID });

        if (!invoice) {
            req.error(404, 'Invoice not found');
        }

        if (invoice.status === 'PAID') {
            req.error(400, 'Invoice already paid');
        }

        await UPDATE(Invoices)
            .set({
                status: 'PAID',
                paidOn: new Date()
            })
            .where({ ID: invoiceID });
        return SELECT.one.from(Invoices).where({ ID: invoiceID });
    });

    this.on('getOverdueInvoices',async(req)=>{
        const{daysOverdue}=req.data;
        if(!daysOverdue||daysOverdue===0){
            req.error(400,"days should give valid")
        }
        const overDue=new Date();
        overDue.setDate(overDue.getDate()-daysOverdue)
        const overDueInvoices=await SELECT.from(Invoices).where({dueDate:{'<':overDue},status:'UNPAID'})
        return overDueInvoices;
    })
    this.on('markOverdueInvoices', async () => {
        const now = new Date();

        const overdueInvoices = await SELECT
            .from('Invoice')
            .where({
                status: 'UNPAID',
                dueDate: { '<': now }
            });

        for (const invoice of overdueInvoices) {
            await UPDATE('Invoice')
                .set({
                    status: 'OVERDUE'
                })
                .where({
                    ID: invoice.ID
                });

            sendAlert(
                `Invoice ${invoice.ID} is overdue`,
                'INVOICE_OVERDUE'
            ).catch(console.error);
        }

        return `Processed ${overdueInvoices.length} overdue invoices`;
    });

})