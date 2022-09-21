const axios = require('axios').default

const consumer = async (event) => {
  let statusCode = 200;

  let body = JSON.parse(event.Records[0].body);

  const payload = { 
    "MessageGroupId": body.MessageId,
    "MessageAttributeProductId": body.MessageAttributes.ProductId.Value,
    "MessageAttributeProductCnt": 10,
    "MessageAttributeFactoryId": body.MessageAttributes.FactoryId.Value,
    "MessageAttributeRequester": "길동씨",
    "CallbackUrl": process.env.CALLBACKURL
    }

  axios.post('LegacySystemEndpoint', payload)
  .then(function (response) {
    console.log(response);
  })
  .catch(function (error) {
    console.log(error);
  });

  console.log(event);
};

module.exports = {
  consumer
};
