import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table_name = 'dynamodb-table-modernizacion'
table = dynamodb.Table(table_name)


data = [

    {'PK': 'CATEGORY#Dogs', 'SK': 'PRODUCT#K9-BD-01', 'product_id': 'K9-BD-01', 'name': 'Bulldog', 'category': 'Dogs'},
    {'PK': 'CATEGORY#Dogs', 'SK': 'PRODUCT#K9-PO-02', 'product_id': 'K9-PO-02', 'name': 'Poodle', 'category': 'Dogs'},
    {'PK': 'CATEGORY#Dogs', 'SK': 'PRODUCT#K9-DL-01', 'product_id': 'K9-DL-01', 'name': 'Dalmation', 'category': 'Dogs'},
    {'PK': 'CATEGORY#Dogs', 'SK': 'PRODUCT#K9-RT-01', 'product_id': 'K9-RT-01', 'name': 'Golden Retriever', 'category': 'Dogs'},
    {'PK': 'CATEGORY#Dogs', 'SK': 'PRODUCT#K9-RT-02', 'product_id': 'K9-RT-02', 'name': 'Labrador Retriever', 'category': 'Dogs'},
    {'PK': 'CATEGORY#Dogs', 'SK': 'PRODUCT#K9-CW-01', 'product_id': 'K9-CW-01', 'name': 'Chihuahua', 'category': 'Dogs'},

    {'PK': 'CATEGORY#Fish', 'SK': 'PRODUCT#FI-SW-01', 'product_id': 'FI-SW-01', 'name': 'Angelfish', 'category': 'Fish'},
    {'PK': 'CATEGORY#Fish', 'SK': 'PRODUCT#FI-SW-02', 'product_id': 'FI-SW-02', 'name': 'Tiger Shark', 'category': 'Fish'},
    {'PK': 'CATEGORY#Fish', 'SK': 'PRODUCT#FI-FW-01', 'product_id': 'FI-FW-01', 'name': 'Koi', 'category': 'Fish'},
    {'PK': 'CATEGORY#Fish', 'SK': 'PRODUCT#FI-FW-02', 'product_id': 'FI-FW-02', 'name': 'Goldfish', 'category': 'Fish'},
    
    {'PK': 'CATEGORY#Reptiles', 'SK': 'PRODUCT#RP-SN-01', 'product_id': 'RP-SN-01', 'name': 'Rattlesnake', 'category': 'Reptiles'},
    {'PK': 'CATEGORY#Reptiles', 'SK': 'PRODUCT#RP-LI-02', 'product_id': 'RP-LI-02', 'name': 'Iguana', 'category': 'Reptiles'},

    {'PK': 'CATEGORY#Cats', 'SK': 'PRODUCT#FL-DSH-01', 'product_id': 'FL-DSH-01', 'name': 'Manx', 'category': 'Cats'},
    {'PK': 'CATEGORY#Cats', 'SK': 'PRODUCT#FL-DLH-02', 'product_id': 'FL-DLH-02', 'name': 'Persian', 'category': 'Cats'},

    {'PK': 'CATEGORY#Birds', 'SK': 'PRODUCT#AV-CB-01', 'product_id': 'AV-CB-01', 'name': 'Amazon Parrot', 'category': 'Birds'},
    {'PK': 'CATEGORY#Birds', 'SK': 'PRODUCT#AV-SB-02', 'product_id': 'AV-SB-02', 'name': 'Finch', 'category': 'Birds'},
]

def insert_data():
    """Insertar todos los datos en DynamoDB"""
    try:
        with table.batch_writer() as batch:
            for item in data:
                batch.put_item(Item=item)
                print(f"Insertado: {item['product_id']} - {item['name']}")
        
        print(f"Se insertaron {len(data)} productos exitosamente!")
        
    except Exception as e:
        print(f"Error insertando datos: {str(e)}")

def query_by_category(category):
    """Consultar productos por categoría"""
    try:
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('PK').eq(f'CATEGORY#{category}')
        )
        
        print(f"\nProductos en categoria '{category}':")
        for item in response['Items']:
            print(f"  - {item['product_id']}: {item['name']}")
            
    except Exception as e:
        print(f"Error consultando categoria {category}: {str(e)}")

def get_product(product_id, category):
    """Obtener un producto específico"""
    try:
        response = table.get_item(
            Key={
                'PK': f'CATEGORY#{category}',
                'SK': f'PRODUCT#{product_id}'
            }
        )
        
        if 'Item' in response:
            item = response['Item']
            print(f"\nProducto encontrado: {item['product_id']} - {item['name']}")
            return item
        else:
            print(f"\nProducto {product_id} no encontrado en categoria {category}")
            return None
            
    except Exception as e:
        print(f"Error obteniendo producto: {str(e)}")

if __name__ == "__main__":
    print("Iniciando carga de datos a DynamoDB...")
    
    insert_data()
    
    print("\n" + "="*50)
    print("EJEMPLOS DE CONSULTAS:")
    print("="*50)
    
    query_by_category('Dogs')
    query_by_category('Fish')
    
    get_product('K9-BD-01', 'Dogs')
    get_product('FI-SW-01', 'Fish')