/**
 * API Gateway Lambda Handler
 * 
 * This Lambda function processes incoming API Gateway requests and publishes them to SNS.
 */

const AWS = require('aws-sdk');
const sns = new AWS.SNS();

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    try {
        // Extract message payload from the request
        let messagePayload;
        
        if (event.body) {
            try {
                // Parse request body
                messagePayload = JSON.parse(event.body);
            } catch (error) {
                console.error('Error parsing request body:', error);
                return {
                    statusCode: 400,
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        message: 'Invalid JSON in request body'
                    })
                };
            }
        } else {
            // If no body, use the entire event as payload
            messagePayload = event;
        }
        
        // Add metadata to the message
        const message = {
            payload: messagePayload,
            metadata: {
                timestamp: new Date().toISOString(),
                source: 'api-gateway',
                requestId: event.requestContext?.requestId || 'unknown'
            }
        };
        
        // Publish message to SNS
        const snsParams = {
            TopicArn: process.env.SNS_TOPIC_ARN,
            Message: JSON.stringify(message),
            MessageAttributes: {
                // Add optional message attributes for filtering
                MessageType: {
                    DataType: 'String',
                    StringValue: messagePayload.type || 'default'
                }
            }
        };
        
        const result = await sns.publish(snsParams).promise();
        console.log('Message published to SNS:', result);
        
        // Return success response
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Message processed successfully',
                messageId: result.MessageId
            })
        };
    } catch (error) {
        console.error('Error processing message:', error);
        
        // Return error response
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Error processing message',
                error: error.message
            })
        };
    }
}; 