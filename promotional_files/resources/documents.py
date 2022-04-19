
from promotional_files.file_manager import FileManager
from promotional_files.document_model import DocumentModel
from flask_restful import Resource
from flask import  request, make_response, redirect
import uuid
from werkzeug.utils import secure_filename
from flask_jwt_extended import jwt_required
import os

class Documents(Resource):
    @jwt_required()
    def post(self):
      file = request.files.get('document')
      metadata = request.form.get('metadata')
      category = request.form.get('category')
      if not file or not metadata or not category:
        return make_response(
            {'message': 'File or metadata are missing"'},
            401,
            {'message': 'File or metadata are missing"'}
        )
      documentModel = DocumentModel()
      id = str(uuid.uuid4())
      new_document = f'{id}{os.path.splitext(file.filename)[1]}'
      documentModel.create(uuid=id, category=category, metadata=metadata, filename=secure_filename(file.filename))
      print(new_document)
      fm = FileManager()
      fm.upload(file=file, key=new_document)
      return make_response(
          {'data' : {'id': id}},
          200,
          {'message': 'success"'}
      )
    @jwt_required()
    def get(self, category, document_id=None, download=None):
      document = DocumentModel()    
      print(category)  
      if not document_id:
        return make_response(
              {'document' : document.list(category=category)},
              200,
              {'message': '"success"'})
      fm = FileManager()
      documentModel = DocumentModel()
      try: 
        doc = documentModel.find_by_id(document_id, category=category)      
        if (download):
            print("download")  
            doc_file = f'{doc["uuid"]}{os.path.splitext(doc["filename"])[1]}'
            url = fm.path(file=doc_file)
            return redirect(url, code=302)

        return make_response(
              {'document' : doc},
              200,
              {'message': '"success"'})
      except Exception:
        return make_response({'data' : 'invalid document'},
              401,
                {'message': '"invalid"'})
    @jwt_required()                                           
    def delete(self, category, document_id):
      if not document_id or not category:
        return make_response(
              'invalid parameters',
              401,
              {'message': '"success"'}) 


      documentModel = DocumentModel()
      documentModel.delete(category=category, uuid=document_id)
      fm = FileManager()
      fm.remove(key=document_id)
      return make_response(
            'success',
            201,
            {'message': '"success"'})                 
