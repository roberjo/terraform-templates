/**
 * EventBridge Scheduler Lambda Handler for API Processing
 * 
 * This Lambda function:
 * 1. Is triggered by EventBridge Scheduler
 * 2. Retrieves data from an external API
 * 3. Processes the data into individual messages
 * 4. Publishes the messages to an SNS topic
 */

const AWS = require('aws-sdk');
const https = require('https');
const sns = new AWS.SNS();

/**
 * Makes an HTTP request to an external API
 * @param {string} url - The URL to make the request to
 * @param {string} apiKey - The API key for authentication
 * @returns {Promise<object>} - A promise that resolves with the API response data
 */
const fetchFromAPI = (url, apiKey) => {
    return new Promise((resolve, reject) => {
        const options = {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            }
        };

        https.get(url, options, (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    try {
                        const parsedData = JSON.parse(data);
                        resolve(parsedData);
                    } catch (error) {
                        reject(new Error(`Error parsing API response: ${error.message}`));
                    }
                } else {
                    reject(new Error(`API request failed with status code: ${res.statusCode}`));
                }
            });
        }).on('error', (error) => {
            reject(new Error(`API request error: ${error.message}`));
        });
    });
};

/**
 * Publishes a message to an SNS topic
 * @param {object} message - The message to publish
 * @param {string} messageType - The type of message (for message filtering)
 * @returns {Promise<object>} - A promise that resolves with the SNS publish result
 */
const publishToSNS = async (message, messageType) => {
    const snsParams = {
        TopicArn: process.env.SNS_TOPIC_ARN,
        Message: JSON.stringify(message),
        MessageAttributes: {
            MessageType: {
                DataType: 'String',
                StringValue: messageType || 'default'
            }
        }
    };

    return sns.publish(snsParams).promise();
};

/**
 * Main Lambda handler function
 */
exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    try {
        // Extract parameters from the event
        const apiEndpoint = event.api_endpoint || process.env.API_ENDPOINT;
        const apiKey = event.api_key || process.env.API_KEY;
        const batchSize = event.batch_size || process.env.BATCH_SIZE || 100;
        
        if (!apiEndpoint) {
            throw new Error('No API endpoint specified');
        }
        
        // Fetch data from the API
        console.log(`Fetching data from API: ${apiEndpoint}`);
        const apiData = await fetchFromAPI(apiEndpoint, apiKey);
        
        // Validate the data structure
        if (!apiData || !Array.isArray(apiData.items)) {
            throw new Error('API response is not in the expected format');
        }
        
        const items = apiData.items;
        console.log(`Retrieved ${items.length} items from API`);
        
        // Process items in batches
        const batches = [];
        for (let i = 0; i < items.length; i += batchSize) {
            batches.push(items.slice(i, i + batchSize));
        }
        
        console.log(`Processing items in ${batches.length} batches`);
        
        // Process each batch
        let successCount = 0;
        let failureCount = 0;
        
        for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
            const batch = batches[batchIndex];
            console.log(`Processing batch ${batchIndex + 1} of ${batches.length} (${batch.length} items)`);
            
            // Process each item in the batch
            const publishPromises = batch.map(async (item) => {
                try {
                    // Create message with metadata
                    const message = {
                        payload: item,
                        metadata: {
                            timestamp: new Date().toISOString(),
                            source: 'api-processor',
                            batchIndex: batchIndex,
                            apiEndpoint: apiEndpoint
                        }
                    };
                    
                    // Publish message to SNS
                    const result = await publishToSNS(message, item.type || 'item');
                    console.log(`Successfully published message to SNS: ${result.MessageId}`);
                    successCount++;
                    return { success: true, messageId: result.MessageId };
                } catch (error) {
                    console.error(`Error publishing message to SNS: ${error}`);
                    failureCount++;
                    return { success: false, error: error.message };
                }
            });
            
            // Wait for all publish operations to complete
            await Promise.all(publishPromises);
        }
        
        // Return processing summary
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Processing complete',
                summary: {
                    totalItems: items.length,
                    batches: batches.length,
                    successCount: successCount,
                    failureCount: failureCount
                }
            })
        };
    } catch (error) {
        console.error('Error processing API data:', error);
        
        // Return error response
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error processing API data',
                error: error.message
            })
        };
    }
}; 