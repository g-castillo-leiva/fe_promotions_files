import os
from flask import Flask
from flask_restful import Api
from flask_jwt_extended import JWTManager
from promotional_files.routes import resource_bp
from promotional_files.config import ProductionConfig,DevelopmentConfig
from werkzeug.middleware.proxy_fix import ProxyFix


from flask import Flask

app = Flask(__name__)


def create_app(script_info=None):
  # instantiate the app
  app = Flask(__name__)
  app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_port=1)
  JWTManager(app)
  Api(app)


  app.register_blueprint(resource_bp, url_prefix='/documents')
    # set config
    #app_settings = os.getenv("APP_SETTINGS")
    #app.config.from_object(app_settings)

  if os.environ.get('FLASK_ENV') == 'production':
    print("Production Mode")
    config = ProductionConfig() 

    #from waitress import serve
    #serve(app, host="0.0.0.0", port=8080)
  else:
    config = DevelopmentConfig()
    print("dev  mode")    
  app.config.from_object(config)
  app.config.update(Testing=True)
    #app.run(host='0.0.0.0')
  @app.shell_context_processor
  def ctx():
      return {"app": app}

  return app

