import json
import boto3
from boto3.dynamodb.conditions import Key

# Inicializar o cliente DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('UVMonitor')  # Substitua pelo nome da sua tabela

def lambda_handler(event, context):
    method = event['httpMethod']
    
    if method == 'GET':
        return handle_get(event)
    elif method == 'POST':
        return handle_post(event)
    else:
        return {
            'statusCode': 405,
            'body': json.dumps({'message': 'Método não permitido'})
        }

def handle_get(event):
    # Chave primária para buscar os dados
    location = 'Itapira-Centro'
    
    try:
        response = table.get_item(Key={'location': location})
        
        if 'Item' in response:
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps(response['Item'])
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'message': 'Dados não encontrados'})
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro ao acessar o DynamoDB', 'error': str(e)})
        }

def handle_post(event):
    try:
        # Os dados do sensor enviados no corpo da requisição
        body = json.loads(event['body'])
        
        # Validar o formato esperado
        required_fields = ['location', 'level', 'status', 'lastUpdate']
        if not all(field in body for field in required_fields):
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Formato inválido. Campos necessários: ' + ', '.join(required_fields)})
            }
        
        # Inserir os dados no DynamoDB
        table.put_item(Item=body)
        
        return {
            'statusCode': 201,
            'body': json.dumps({'message': 'Dados inseridos com sucesso'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro ao inserir os dados', 'error': str(e)})
        }
