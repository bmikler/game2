import sys
from huggingface_hub import hf_hub_download, snapshot_download
p=hf_hub_download(repo_id="Viglong/Orient-Anything", filename="croplargeEX2/dino_weight.pt", repo_type="model", cache_dir="weights")
print(p)
d=snapshot_download(repo_id="facebook/dinov2-base", cache_dir="weights", allow_patterns=["*.json","*.safetensors"])
print(d)
