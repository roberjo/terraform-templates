/**
 * SQS Message Processor Lambda Handler
 * 
 * This Lambda function processes messages from the SQS queue.
 */

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    try {
        // SQS invokes Lambda with a batch of messages
        const messagePromises = event.Records.map(async (record) => {
            try {
                // Process SQS message
                console.log('Processing SQS message:', record.messageId);
                
                // Parse message body (contains the SNS message)
                const body = JSON.parse(record.body);
                
                // If this is an SNS message, the actual message is in the Message field
                let message;
                if (body.Message) {
                    // This is an SNS message
                    try {
                        message = JSON.parse(body.Message);
                    } catch (e) {
                        message = body.Message;
                    }
                } else {
                    // Direct SQS message
                    message = body;
                }
                
                console.log('Parsed message:', JSON.stringify(message, null, 2));
                
                // Custom business logic to process the message goes here
                // This is where you would implement your specific processing needs
                
                // Example: Check message type and route accordingly
                if (message.payload && message.metadata) {
                    const { payload, metadata } = message;
                    
                    console.log(`Processing message from ${metadata.source} with timestamp ${metadata.timestamp}`);
                    
                    // Process based on message type or content
                    // This is where your domain-specific logic would go
                    
                    // Example of handling different message types
                    if (payload.type === 'order') {
                        // Process order
                        console.log('Processing order:', payload.orderId);
                        // await processOrder(payload);
                    } else if (payload.type === 'notification') {
                        // Process notification
                        console.log('Processing notification:', payload.notificationId);
                        // await processNotification(payload);
                    } else {
                        // Default processing
                        console.log('Processing generic message');
                        // await processGenericMessage(payload);
                    }
                } else {
                    console.log('Processing message with unknown format');
                    // await processUnknownMessage(message);
                }
                
                // Successful processing result
                return {
                    messageId: record.messageId,
                    status: 'success'
                };
            } catch (error) {
                console.error(`Error processing message ${record.messageId}:`, error);
                
                // Return error details but don't fail the entire batch
                // SQS will retry the message based on the queue settings
                // unless we explicitly succeed the processing
                return {
                    messageId: record.messageId,
                    status: 'error',
                    error: error.message
                };
            }
        });
        
        // Wait for all messages to be processed
        const results = await Promise.all(messagePromises);
        
        // Count successes and failures
        const successCount = results.filter(r => r.status === 'success').length;
        const failureCount = results.filter(r => r.status === 'error').length;
        
        console.log(`Processed ${successCount} messages successfully, ${failureCount} with errors`);
        
        // Return results
        return {
            batchItemFailures: results
                .filter(r => r.status === 'error')
                .map(r => ({ itemIdentifier: r.messageId }))
        };
        
    } catch (error) {
        console.error('Error processing SQS batch:', error);
        throw error; // Rethrow to trigger Lambda retry
    }
}; 