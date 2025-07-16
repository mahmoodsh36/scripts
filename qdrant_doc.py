import argparse
import uuid
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams
from fastembed import TextEmbedding
from tqdm import tqdm

# config
QDRANT_URL = "http://localhost:6333"
COLLECTION_NAME = "books"
CHUNK_SIZE = 1000
CHUNK_OVERLAP = 100
BATCH_SIZE = 100
BATCH_EMBED_SIZE = 32
MODEL_NAME = "BAAI/bge-small-en-v1.5"
VECTOR_NAME = "fast-bge-small-en-v1.5" # has to be the same as in the mcp server

# args
parser = argparse.ArgumentParser(description="upload Markdown with FastEmbed embeddings")
parser.add_argument("file", type=str, help="path to the .md file")
args = parser.parse_args()
md_file = args.file

# init client & embedder
client = QdrantClient(QDRANT_URL)
embedder = TextEmbedding(model_name=MODEL_NAME)

# create collection with named vector
if not client.collection_exists(collection_name=COLLECTION_NAME):
    client.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config={
            VECTOR_NAME: VectorParams(
                size=embedder.embedding_size,
                distance=Distance.COSINE
            )
        }
    )

with open(md_file, "r", encoding="utf-8") as f:
    text = f.read()

# create overlapping chunks
chunks = []
start = 0
text_len = len(text)
while start < text_len:
    end = min(start + CHUNK_SIZE, text_len)
    chunk = text[start:end]
    chunks.append(chunk)
    start += CHUNK_SIZE - CHUNK_OVERLAP

print(f"✅ read {len(chunks)} overlapping chunks from {md_file}")

# helper: batch generator
def batchify(lst, batch_size):
    for i in range(0, len(lst), batch_size):
        yield lst[i:i + batch_size]

# embed chunks in batches
embedding_texts = chunks
embeddings = []

print("🔎 embedding text in batches...")
for batch in tqdm(list(batchify(embedding_texts, BATCH_EMBED_SIZE)), desc="embedding batches"):
    batch_embeddings = embedder.embed(batch)
    embeddings.extend(batch_embeddings)

# prepare points
points = []
for idx, (chunk, vec) in enumerate(zip(chunks, embeddings)):
    points.append({
        "id": str(uuid.uuid4()),
        "vector": {VECTOR_NAME: vec.tolist()},
        "payload": {
            "document": chunk,
            "chunk_id": idx,
            "source_file": md_file
        }
    })

# upload points in batches
print("⬆️ uploading to qdrant in batches...")
for i in tqdm(range(0, len(points), BATCH_SIZE), desc="uploading batches"):
    batch = points[i:i + BATCH_SIZE]
    client.upsert(
        collection_name=COLLECTION_NAME,
        points=batch
    )

print(f"✅ uploaded {len(points)} chunks into '{COLLECTION_NAME}' using vector '{VECTOR_NAME}' and model '{MODEL_NAME}'")