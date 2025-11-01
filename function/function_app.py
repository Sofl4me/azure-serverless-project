import azure.functions as func
import logging
import os
from io import BytesIO
from PIL import Image
from azure.storage.blob import BlobServiceClient
from datetime import datetime

app = func.FunctionApp()

# Configuration
STORAGE_CONNECTION_STRING = os.environ.get('STORAGE_CONNECTION_STRING')
THUMBNAIL_WIDTH = int(os.environ.get('THUMBNAIL_WIDTH', 200))
THUMBNAIL_HEIGHT = int(os.environ.get('THUMBNAIL_HEIGHT', 200))

@app.blob_trigger(
    arg_name="inputblob",
    path="input/{name}",
    connection="STORAGE_CONNECTION_STRING"
)
def ImageProcessor(inputblob: func.InputStream):
    """
    Traite les images uploadées dans le container 'input'
    - Crée une thumbnail
    - Archive l'original
    - Copie dans output
    """
    
    logging.info(f"🎯 Traitement de l'image: {inputblob.name}")
    logging.info(f"📏 Taille: {inputblob.length} bytes")
    
    try:
        # Lire l'image
        image_data = inputblob.read()
        image = Image.open(BytesIO(image_data))
        
        logging.info(f"🖼️  Format: {image.format}, Taille: {image.size}, Mode: {image.mode}")
        
        # Connexion au Storage
        blob_service_client = BlobServiceClient.from_connection_string(
            STORAGE_CONNECTION_STRING
        )
        
        # Extraire le nom du fichier
        filename = inputblob.name.split('/')[-1]
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 1. Créer la thumbnail
        logging.info(f"🔄 Création de la thumbnail ({THUMBNAIL_WIDTH}x{THUMBNAIL_HEIGHT})")
        thumbnail = image.copy()
        thumbnail.thumbnail((THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT), Image.Resampling.LANCZOS)
        
        # Sauvegarder la thumbnail
        thumbnail_buffer = BytesIO()
        thumbnail.save(thumbnail_buffer, format=image.format or 'JPEG')
        thumbnail_buffer.seek(0)
        
        thumbnail_blob = blob_service_client.get_blob_client(
            container="thumbnails",
            blob=f"thumb_{filename}"
        )
        thumbnail_blob.upload_blob(thumbnail_buffer.read(), overwrite=True)
        logging.info(f"✅ Thumbnail sauvegardée: thumb_{filename}")
        
        # 2. Copier l'original dans output
        logging.info("📤 Copie vers output")
        output_blob = blob_service_client.get_blob_client(
            container="output",
            blob=filename
        )
        output_blob.upload_blob(image_data, overwrite=True)
        logging.info(f"✅ Image copiée dans output: {filename}")
        
        # 3. Archiver l'original
        logging.info("📦 Archivage de l'original")
        archive_blob = blob_service_client.get_blob_client(
            container="archive",
            blob=f"{timestamp}_{filename}"
        )
        archive_blob.upload_blob(image_data, overwrite=True)
        logging.info(f"✅ Image archivée: {timestamp}_{filename}")
        
        logging.info(f"🎉 Traitement terminé avec succès pour {filename}")
        
    except Exception as e:
        logging.error(f"❌ Erreur lors du traitement: {str(e)}")
        raise
