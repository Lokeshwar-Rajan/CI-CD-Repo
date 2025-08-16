const AWS = require('aws-sdk');
const { Pool } = require('pg');

const secretArn = process.env.DB_SECRET_ARN;
const region = process.env.AWS_REGION || 'ap-south-1';

AWS.config.update({ region });

let pool;

async function getDbCredentials() {
    const client = new AWS.SecretsManager({ region });
    const data = await client.getSecretValue({ SecretId: secretArn }).promise();
    const secret = JSON.parse(data.SecretString);

    return {
        user: secret.username,
        host: secret.endpoint,
        database: secret.dbname,
        password: secret.password,
        port: 5432
    };
}

async function initPool() {
    if (!pool) {
        const creds = await getDbCredentials();
        pool = new Pool(creds);
    }
    return pool;
}

module.exports = {
    query: async (text, params) => {
        const dbPool = await initPool();
        return dbPool.query(text, params);
    }
};
