/**
 * SQS Message Processor Lambda
 * 
 * This Lambda function processes messages from an SQS queue that were originally
 * published to an SNS topic by the API Processor Lambda.
 */

const AWS = require('aws-sdk');

/**
 * Process a single message from the queue
 * @param {object} message - The SQS message to process
 * @returns {object} - The processing result
 */
const processMessage = async (message) => {
    try {
        // Parse the message body
        // For SNS->SQS messages, we need to parse the SQS body to get the SNS message,
        // and then parse the SNS message to get our actual data
        const sqsBody = JSON.parse(message.body);
        const snsMessage = JSON.parse(sqsBody.Message);
        
        // Extract the payload and metadata
        const { payload, metadata } = snsMessage;
        
        console.log('Processing message:', {
            messageId: message.messageId,
            messageType: sqsBody.MessageAttributes?.MessageType?.Value || 'unknown',
            timestamp: metadata.timestamp,
            source: metadata.source
        });
        
        // Here you would implement your actual business logic to process the message
        // This could include:
        // - Storing data in a database
        // - Triggering other workflows
        // - Transforming the data
        // - Making API calls to other services
        
        // For demonstration purposes, we'll log some information about the payload
        console.log(`Successfully processed item: ${payload.id || 'unknown'}`);
        
        // Return success result
        return {
            success: true,
            messageId: message.messageId,
            result: 'Message processed successfully'
        };
    } catch (error) {
        console.error(`Error processing message ${message.messageId}:`, error);
        
        // Return failure result
        return {
            success: false,
            messageId: message.messageId,
            error: error.message
        };
    }
};

/**
 * Main Lambda handler function
 */
exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    // Results will collect processing outcomes for all messages
    const results = {
        batchItemFailures: [],
        successCount: 0,
        failureCount: 0
    };
    
    if (!event.Records || !Array.isArray(event.Records)) {
        console.log('No records to process');
        return results;
    }
    
    console.log(`Processing ${event.Records.length} messages`);
    
    // Process each message in the batch
    const processPromises = event.Records.map(async (record) => {
        try {
            const result = await processMessage(record);
            
            if (result.success) {
                // Record successful processing
                results.successCount++;
            } else {
                // Record failed processing for retry
                results.failureCount++;
                results.batchItemFailures.push({ itemIdentifier: record.messageId });
                console.warn(`Failed to process message ${record.messageId}: ${result.error}`);
            }
            
            return result;
        } catch (error) {
            // Catch any unexpected errors
            console.error(`Unexpected error processing message ${record.messageId}:`, error);
            results.failureCount++;
            results.batchItemFailures.push({ itemIdentifier: record.messageId });
            return {
                success: false,
                messageId: record.messageId,
                error: error.message
            };
        }
    });
    
    // Wait for all messages to be processed
    await Promise.all(processPromises);
    
    console.log('Processing summary:', {
        totalProcessed: event.Records.length,
        successful: results.successCount,
        failed: results.failureCount
    });
    
    // Return results with any failed messages for SQS to retry
    return {
        batchItemFailures: results.batchItemFailures
    };
}; 