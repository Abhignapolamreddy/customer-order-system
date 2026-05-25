sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"project1/test/integration/pages/InvoiceAnalyticsList",
	"project1/test/integration/pages/InvoiceAnalyticsObjectPage"
], function (JourneyRunner, InvoiceAnalyticsList, InvoiceAnalyticsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('project1') + '/test/flp.html#app-preview',
        pages: {
			onTheInvoiceAnalyticsList: InvoiceAnalyticsList,
			onTheInvoiceAnalyticsObjectPage: InvoiceAnalyticsObjectPage
        },
        async: true
    });

    return runner;
});

