import os
import base64
class Config(object):
    DEBUG = False
    TESTING = False
    URL_REPORT= ''

class ProductionConfig(Config):
    DEBUG = True
    Testing = True
    JWT_SECRET_KEY = base64.b64decode("004f2af45d3a4e161a7dd2d17fdae47f")
    DB_ENV = os.getenv('DB_ENV')
    BUCKET =  os.getenv('BUCKET')
    PROPAGATE_EXCEPTIONS = True
    JWT_IDENTITY_CLAIM = 'public_id'

class DevelopmentConfig(Config):
    DEBUG = True
    Testing = True
    JWT_SECRET_KEY = base64.b64decode("004f2af45d3a4e161a7dd2d17fdae47f")
    DB_ENV = os.getenv('DB_ENV')
    BUCKET =  os.getenv('BUCKET')    
    PROPAGATE_EXCEPTIONS = True    
    JWT_IDENTITY_CLAIM = 'public_id'    

class TestingConfig(Config):
    TESTING = True
