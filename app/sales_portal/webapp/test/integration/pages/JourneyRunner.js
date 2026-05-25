sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"salesportal/test/integration/pages/SalesOrdersList",
	"salesportal/test/integration/pages/SalesOrdersObjectPage",
	"salesportal/test/integration/pages/OrderItemsObjectPage"
], function (JourneyRunner, SalesOrdersList, SalesOrdersObjectPage, OrderItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('salesportal') + '/test/flp.html#app-preview',
        pages: {
			onTheSalesOrdersList: SalesOrdersList,
			onTheSalesOrdersObjectPage: SalesOrdersObjectPage,
			onTheOrderItemsObjectPage: OrderItemsObjectPage
        },
        async: true
    });

    return runner;
});

