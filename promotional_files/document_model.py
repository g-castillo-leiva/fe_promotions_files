import boto3
import os
from datetime import datetime

from botocore.exceptions import ClientError
#Variables de Entorno
#AWS_PROFILE = os.getenv("AWS_PROFILE", "personal")
DB_ENV= os.getenv("DB_ENV", "dev")

class DocumentModel:
    def __init__(self, dynamodb=None):
      if not dynamodb:
          #boto3.setup_default_session(profile_name=AWS_PROFILE)
          boto3.setup_default_session()
          dynamodb = boto3.resource('dynamodb')

      self.table = dynamodb.Table(f'document-{DB_ENV}')
    
    def create(self, uuid, category, metadata, filename):
      response = self.table.put_item(
        Item={
              'uuid': uuid,
              'metadata': metadata,
              'category': category,
              'filename': filename,
              'timestamp': str(datetime.utcnow())              
          }
      )
      return response
    def find_by_id(self, uuid, category):
        try:
            response = self.table.get_item(Key={'uuid': uuid, 'category' : category})
        except ClientError as e:
            print(e.response['Error']['Message'])
            return False
        else:
            if('Item' not in response):
                return False
            
            return response['Item'] 
    def delete(self, uuid, category):
      try:
          self.table.delete_item(Key={'uuid': uuid, 'category': category})
      except ClientError as err:
            print(
                "Couldn't delete document %s. Here's why: %s: %s", category,
                err.response['Error']['Code'], err.response['Error']['Message'])
            raise      

    # def find_by_id(self, uuid):
    #     try:

    #         response = self.table.query(
    #           KeyConditionExpression = "#id_condition = :id",
    #           ExpressionAttributeValues =
    #           {':id':uuid},
    #           ExpressionAttributeNames= { "#id_condition": "uuid" }
    #           )   
    #         print(response)         
    #     except ClientError as e:
    #         print(e.response['Error']['Message'])
    #         return False
    #     else:
    #         if('Items' not in response):
    #             return False
            
    #         return response['Items'][0]   
    def list(self, category):
      documents = self.table.scan(
               FilterExpression = "category = :category",
               ExpressionAttributeValues = {':category':category}
     )   
      return documents['Items']      
    @staticmethod    
    def create_table(dynamodb=None):
      table = dynamodb.create_table(
          TableName= f'document-{DB_ENV}',
          KeySchema=[
              {
                  'AttributeName': 'uuid',
                  'KeyType': 'HASH'  # Partition key
              },
              {
                  'AttributeName': 'category',
                  'KeyType': 'RANGE'  # Partition key
              },                
              
          ],
          AttributeDefinitions=[
              {
                  'AttributeName': 'uuid',
                  'AttributeType': 'S'
              },
              {
                  'AttributeName': 'category',
                  'AttributeType': 'S'  # Partition key
              },                   

          ],
          ProvisionedThroughput={
              'ReadCapacityUnits': 1,
              'WriteCapacityUnits': 1
          }
      )
      return table


def script_db():
    #boto3.setup_default_session(profile_name=AWS_PROFILE)
    table = DocumentModel.create_table(dynamodb= boto3.resource('dynamodb'))
    #d = DocumentModel()
    #print(d.find_by_id('0f07fb6d-0198-4667-8974-a1560aa531ab'))
    print("Table status:", table.table_status)  

if __name__ == '__main__':
    can_execute_script = os.getenv("execute_script_db", True)
    if(can_execute_script):
        script_db()

 
