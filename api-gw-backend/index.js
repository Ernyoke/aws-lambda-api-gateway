'use strict';

const AWS = require('aws-sdk')

// Handler
exports.handler = async function (event, context) {
    console.log(JSON.stringify(event));
    console.log(JSON.stringify(context));
    try {
        return formatResponse({ 'result': 'success' })
    } catch (error) {
        console.log(error);
        return formatResponse({'result': 'error'});
    }
}

const formatResponse = function (body) {
    return {
        statusCode: 200,
        headers: {
            'Content-Type': "application/json"
        },
        isBase64Encoded: false,
        multiValueHeaders: {
            'X-Custom-Header': ['My value', 'My other value'],
        },
        body: JSON.stringify(body)
    }
}