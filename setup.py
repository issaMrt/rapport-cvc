"""Configuration : mot de passe du technicien, clé secrète et nom affiché par défaut.
Peut être relancé sans risque : le mot de passe n'est changé que si vous le demandez."""
import getpass
import json
import secrets
from pathlib import Path

from werkzeug.security import generate_password_hash

data = Path(__file__).parent / "data"
data.mkdir(exist_ok=True)
cfg = data / "config.json"

conf = json.loads(cfg.read_text()) if cfg.exists() else {}

if not conf.get("password_hash") or input("Changer le mot de passe ? (o/N) ").strip().lower() == "o":
    FAIBLES = {"123456", "1234567", "12345678", "000000", "111111", "azerty", "azerty1",
               "qwerty", "password", "motdepasse", "abcdef", "abc123", "123abc"}
    while True:
        pw = getpass.getpass("Choisissez un mot de passe (6 caractères minimum, lettres et chiffres) : ")
        if len(pw) < 6:
            print("Trop court : 6 caractères minimum.")
            continue
        if pw.lower() in FAIBLES or len(set(pw)) == 1:
            print("Mot de passe trop évident, choisissez-en un autre.")
            continue
        if pw != getpass.getpass("Confirmez : "):
            print("Les deux ne correspondent pas.")
            continue
        break
    conf["password_hash"] = generate_password_hash(pw)
    conf["secret_key"] = secrets.token_hex(32)

actuel = conf.get("technicien", "")
suffixe = f" [{actuel}]" if actuel else ""
nom = input(f"Nom du technicien affiché par défaut dans les rapports{suffixe} : ").strip()
conf["technicien"] = nom or actuel

cfg.write_text(json.dumps(conf))
print("OK : data/config.json enregistré. Lancez maintenant : python app.py")
