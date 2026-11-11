"""Baixa as trilhas de config/musicas.json direto da Mixkit (licença: não redistribuir a música isolada).
Uso: python scripts/baixar_musicas.py   (idempotente: pula arquivos que já existem)"""
import json, pathlib, sys, urllib.request

raiz = pathlib.Path(__file__).resolve().parent.parent
cfg = json.loads((raiz / "config/musicas.json").read_text())
falhas = 0
for f in cfg["faixas"]:
    destino = raiz / f["arquivo"]
    if destino.exists() and destino.stat().st_size > 100_000:
        print(f"ok (já existe)  {f['titulo']}")
        continue
    destino.parent.mkdir(parents=True, exist_ok=True)
    url = f"https://assets.mixkit.co/music/{f['mixkit_id']}/{f['mixkit_id']}.mp3"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=120) as r:
            destino.write_bytes(r.read())
        print(f"baixado         {f['titulo']}")
    except Exception as e:  # rede bloqueada na nuvem: liberar assets.mixkit.co
        falhas += 1
        print(f"FALHOU          {f['titulo']}: {e}", file=sys.stderr)
sys.exit(1 if falhas else 0)
