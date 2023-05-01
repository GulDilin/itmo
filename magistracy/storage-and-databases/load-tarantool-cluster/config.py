from dotenv import load_dotenv
import os

load_dotenv()

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', 3301)
DB_USER = os.getenv('DB_USER', 'admin')
DB_PASS = os.getenv('DB_PASS', 'admin')

spaces = {
    'customer': {
        'customer_id': 'unsigned',
        'bucket_id': 'unsigned',
        'name': 'string',
    },
    'account': {
        'account_id': 'unsigned',
        'customer_id': 'unsigned',
        'bucket_id': 'unsigned',
        'balance': 'string',
        'name': 'string',
    }
}
