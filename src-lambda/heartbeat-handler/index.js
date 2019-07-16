const AWS = require("aws-sdk");

exports.handler = async function(event, context) {
  console.log("EVENT", JSON.stringify({ event, context }));
  return context.logStreamName;
};
