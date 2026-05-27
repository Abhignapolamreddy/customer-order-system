const xsenv = require('@sap/xsenv');
const {
  AlertNotificationClient,
  OAuthAuthentication,
  RegionUtils
} = require('@sap_oss/alert-notification-client');

xsenv.loadEnv();

const services = xsenv.getServices({
  ans: { name: 'alert-inst' }
});

const client = new AlertNotificationClient({
  authentication: new OAuthAuthentication({
    username: services.ans.client_id,
    password: services.ans.client_secret,
    oAuthTokenUrl: services.ans.oauth_url.split('?')[0]
  }),
  uri: services.ans.url,
  region: RegionUtils.US10
});

async function sendAlert(message, type) {
  const event = {
    resource: {
      resourceName: "OrderService",
      resourceType: "CAP_APP"
    },
    eventType: "CustomAlert",
    subject: `Order ${type}`,
    body: message,
    severity: "INFO",
    category: "NOTIFICATION"
  };

  try {
    console.log("EVENT:", JSON.stringify(event));
    await client.sendEvent(event);
    console.log("Alert sent");
  } catch (err) {
    console.error("Alert failed:", JSON.stringify(err.response?.data || err, null, 2));
  }
}

module.exports = { sendAlert };