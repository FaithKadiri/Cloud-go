from flask import Flask, request
import boto3
import psycopg2
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DB_HOST = os.environ['DB_HOST']
DB_NAME = os.environ['DB_NAME']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
S3_BUCKET = os.environ['S3_BUCKET']
app = Flask(__name__)

s3 = boto3.client('s3')

@app.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if not file or file.filename == '':
        return {"error": "no file"}, 400
    
    filename = file.filename
    s3.upload_fileobj(file, S3_BUCKET, filename)
    logger.info(f"Uploaded {file.filename} to S3")

    try:
        conn = psycopg2.connect(
            host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS )
        cur = conn.cursor()
        cur.execute("INSERT INTO uploads (filename) VALUES(%s)", (filename,))
        conn.commit()
        cur.close()
        conn.close()
        logger.info(f"Saved {filename} to database")
        return {"message": f"Uploaded {filename}"}, 200
    except Exception as e:
        logger.error(f"Database error: {str(e)}")
        return {"error": "Database error"}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
