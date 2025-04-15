/**
 * Example Lambda function for API Gateway microservices pattern
 * This function will be packaged in example-function.zip
 */

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

// Get the table name from environment variables
const tableName = process.env.DYNAMODB_TABLE;

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  
  try {
    // Extract request details
    const httpMethod = event.httpMethod;
    const path = event.path;
    const pathParameters = event.pathParameters || {};
    const queryStringParameters = event.queryStringParameters || {};
    const body = event.body ? JSON.parse(event.body) : {};
    
    // Determine the service from the path
    const serviceName = path.split('/')[1];
    
    // Process based on HTTP method
    let response;
    
    switch (httpMethod) {
      case 'GET':
        if (pathParameters.id) {
          // Get a specific item
          response = await getItem(pathParameters.id);
        } else {
          // List items
          response = await listItems(queryStringParameters);
        }
        break;
        
      case 'POST':
        // Create a new item
        response = await createItem(body);
        break;
        
      case 'PUT':
        // Update an existing item
        response = await updateItem(pathParameters.id, body);
        break;
        
      case 'DELETE':
        // Delete an item
        response = await deleteItem(pathParameters.id);
        break;
        
      default:
        return formatResponse(405, { 
          error: 'Method not allowed',
          allowedMethods: ['GET', 'POST', 'PUT', 'DELETE']
        });
    }
    
    return formatResponse(200, response);
  } catch (error) {
    console.error('Error processing request:', error);
    
    return formatResponse(
      error.statusCode || 500,
      { error: error.message || 'Internal server error' }
    );
  }
};

/**
 * Get a single item by ID
 */
async function getItem(id) {
  console.log(`Getting item with ID: ${id}`);
  
  if (!tableName) {
    // If no table is configured, return mock data
    return mockData(id);
  }
  
  const params = {
    TableName: tableName,
    Key: { id }
  };
  
  try {
    const result = await dynamoDB.get(params).promise();
    
    if (!result.Item) {
      const error = new Error(`Item with ID ${id} not found`);
      error.statusCode = 404;
      throw error;
    }
    
    return result.Item;
  } catch (error) {
    console.error('Error getting item:', error);
    throw error;
  }
}

/**
 * List items with optional filtering
 */
async function listItems(queryParams) {
  console.log('Listing items with params:', queryParams);
  
  if (!tableName) {
    // If no table is configured, return mock data
    return { items: [mockData('1'), mockData('2'), mockData('3')] };
  }
  
  // Basic scan params
  const params = {
    TableName: tableName,
    Limit: queryParams.limit || 100
  };
  
  // Add filter if specified
  if (queryParams.filter) {
    params.FilterExpression = queryParams.filter;
  }
  
  try {
    const result = await dynamoDB.scan(params).promise();
    return {
      items: result.Items,
      count: result.Count,
      scannedCount: result.ScannedCount
    };
  } catch (error) {
    console.error('Error listing items:', error);
    throw error;
  }
}

/**
 * Create a new item
 */
async function createItem(data) {
  console.log('Creating item with data:', data);
  
  if (!data.id) {
    data.id = generateId();
  }
  
  if (!tableName) {
    // If no table is configured, return mock data
    return { ...data, created: true, timestamp: new Date().toISOString() };
  }
  
  // Add timestamps
  const timestamp = new Date().toISOString();
  const item = {
    ...data,
    createdAt: timestamp,
    updatedAt: timestamp
  };
  
  const params = {
    TableName: tableName,
    Item: item,
    ConditionExpression: 'attribute_not_exists(id)'
  };
  
  try {
    await dynamoDB.put(params).promise();
    return item;
  } catch (error) {
    if (error.code === 'ConditionalCheckFailedException') {
      const conflictError = new Error(`Item with ID ${data.id} already exists`);
      conflictError.statusCode = 409;
      throw conflictError;
    }
    
    console.error('Error creating item:', error);
    throw error;
  }
}

/**
 * Update an existing item
 */
async function updateItem(id, data) {
  console.log(`Updating item ${id} with data:`, data);
  
  if (!tableName) {
    // If no table is configured, return mock data
    return { ...data, id, updated: true, timestamp: new Date().toISOString() };
  }
  
  // Remove id from the data (can't update partition key)
  const updateData = { ...data };
  delete updateData.id;
  
  // Add update timestamp
  updateData.updatedAt = new Date().toISOString();
  
  // Build update expression
  let updateExpression = 'SET';
  const expressionAttributeNames = {};
  const expressionAttributeValues = {};
  
  Object.keys(updateData).forEach((key, index) => {
    const nameKey = `#attr${index}`;
    const valueKey = `:val${index}`;
    
    updateExpression += `${index === 0 ? ' ' : ', '}${nameKey} = ${valueKey}`;
    expressionAttributeNames[nameKey] = key;
    expressionAttributeValues[valueKey] = updateData[key];
  });
  
  const params = {
    TableName: tableName,
    Key: { id },
    UpdateExpression: updateExpression,
    ExpressionAttributeNames: expressionAttributeNames,
    ExpressionAttributeValues: expressionAttributeValues,
    ReturnValues: 'ALL_NEW',
    ConditionExpression: 'attribute_exists(id)'
  };
  
  try {
    const result = await dynamoDB.update(params).promise();
    return result.Attributes;
  } catch (error) {
    if (error.code === 'ConditionalCheckFailedException') {
      const notFoundError = new Error(`Item with ID ${id} not found`);
      notFoundError.statusCode = 404;
      throw notFoundError;
    }
    
    console.error('Error updating item:', error);
    throw error;
  }
}

/**
 * Delete an item
 */
async function deleteItem(id) {
  console.log(`Deleting item with ID: ${id}`);
  
  if (!tableName) {
    // If no table is configured, return mock successful deletion
    return { id, deleted: true, timestamp: new Date().toISOString() };
  }
  
  const params = {
    TableName: tableName,
    Key: { id },
    ReturnValues: 'ALL_OLD',
    ConditionExpression: 'attribute_exists(id)'
  };
  
  try {
    const result = await dynamoDB.delete(params).promise();
    
    if (!result.Attributes) {
      const notFoundError = new Error(`Item with ID ${id} not found`);
      notFoundError.statusCode = 404;
      throw notFoundError;
    }
    
    return {
      message: `Item ${id} successfully deleted`,
      deletedItem: result.Attributes
    };
  } catch (error) {
    if (error.code === 'ConditionalCheckFailedException') {
      const notFoundError = new Error(`Item with ID ${id} not found`);
      notFoundError.statusCode = 404;
      throw notFoundError;
    }
    
    console.error('Error deleting item:', error);
    throw error;
  }
}

/**
 * Format the API response
 */
function formatResponse(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
    },
    body: JSON.stringify(body)
  };
}

/**
 * Generate a random ID
 */
function generateId() {
  return Math.random().toString(36).substring(2, 15) + 
         Math.random().toString(36).substring(2, 15);
}

/**
 * Generate mock data for testing without DynamoDB
 */
function mockData(id) {
  const services = ['users', 'items', 'orders', 'products'];
  const serviceName = services.find(s => id.includes(s)) || 'unknown';
  
  return {
    id,
    name: `Example ${serviceName} item ${id}`,
    description: `This is a mock ${serviceName} item for testing`,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    type: serviceName,
    status: 'active',
    _note: 'This is mock data because no DynamoDB table was configured'
  };
} 