
import boto3  # pip install boto3
import os
# Let's use Amazon S3

#AWS_PROFILE = os.getenv("AWS_PROFILE", "personal")
BUCKET = os.getenv("BUCKET") #"bucketsmu-testjn"
class FileManager:
  def __init__(self, dynamodb=None):
    if not dynamodb:
        #boto3.setup_default_session(profile_name=AWS_PROFILE)
        boto3.setup_default_session()
        #dynamodb = boto3.resource('dynamodb')

    self.file_manager = boto3.client('s3')
  def upload(self, file, key):
    """
    Docs: http://boto3.readthedocs.io/en/latest/guide/s3.html
    """
    try:
        self.file_manager.upload_fileobj(
            file,
            BUCKET,
            key
        )
    except Exception as e:
        print("Something Happened: ", e)
        return e
    return "{}{}".format("S3_LOCATION", file.filename)
  def remove(self, key):
    self.file_manager.delete_object(Bucket=BUCKET, Key=key)

  def path(self, file):
    print(file)
    return self.file_manager.generate_presigned_url('get_object',
                                                    Params={'Bucket': BUCKET,
                                                            'Key': file},
                                                    ExpiresIn=600)
