const express = require('express');
const AWS = require('aws-sdk');
const cors = require('cors');

const app = express();
const port = 3000;

// Configuração do DynamoDB
AWS.config.update({
  region: 'us-east-1', // Substitua pela sua região
});
const dynamoDB = new AWS.DynamoDB.DocumentClient();

app.use(cors());

// Endpoint para obter os dados de UV
app.get('/uv-data', async (req, res) => {
  const params = {
    TableName: 'UVMonitor', // Nome da tabela no DynamoDB
    Key: { location: 'Itapira-Centro' },
  };

  try {
    const data = await dynamoDB.get(params).promise();
    if (data.Item) {
      res.json(data.Item);
    } else {
      res.status(404).json({ error: 'Dados não encontrados' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Erro ao acessar o DynamoDB', details: error });
  }
});

app.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});
