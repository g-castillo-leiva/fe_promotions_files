from flask import request, Blueprint
from flask_restful import Api, Resource
from promotional_files.resources import Documents


resource_bp = Blueprint('resource', __name__)
api = Api(resource_bp)


api.add_resource(Documents, '/document','/document/<category>','/document/<category>/<document_id>/','/document/<category>/<document_id>/<download>', endpoint='document')

@resource_bp.route('/healtcheck', methods=['GET'])
def index():
  return 'Hello World2'