import json
import hashlib
from flask import Flask, render_template, request # flask lib


app = Flask(__name__)
api_key = "super_secret_key_here"  # use env vars in actual practice


@app.route('/')
def main():
    return render_template("index.html")


@app.route('/api/whitelist', methods={'GET', 'POST'})  # called from client script
def whitelist():
    with open('data/users.json') as file:
        key = str(request.args.get('key'))
        hwid = str(request.args.get('hwid'))

        if key == "None" or hwid == "None":
            return 'Missing arguments'

        try:
            data = json.load(file)
        except:
            return "Something went wrong, retry again.", 500

        for _, userinfo in data.items():
            if userinfo["key"] and userinfo["claimed"] is True:
                if userinfo["key"] == key:
                    if userinfo["hwid"] == hwid:
                        return 'Whitelisted', 200
                    else:
                        return "Incorrect HWID", 400
                else:
                    return "Incorrect key", 400

            if userinfo["key"] and userinfo["claimed"] is False:
                if userinfo["key"] == key:
                    userinfo["claimed"] = True
                    userinfo["hwid"] = hwid

                    with open('data/users.json', 'w') as writefile:
                        json.dump(data, writefile, indent=4)
                    return 'Whitelisted', 200
    return 'ok'


@app.route('/api/register_user', methods={'GET', 'POST'})  # used by third parties to create a key and assign it to an user
def register_user():
    key = str(request.args.get('key'))
    user = str(request.args.get('user'))

    if not key or key == "None":
        return 'Missing argument'
    if not user or user == "None":
        return "Missing username"

    if key != api_key:
        return "Incorrect key"

    incremented_key = ""
    data = None
    with open('data/users.json', 'r') as read_file:
        data = json.load(read_file)
        if data:
            incremented_key = str(max(int(k) for k in data.keys()) + 1)

        hash_string = user + api_key
        encoded_hash_string = hash_string.encode()
        new_key = hashlib.sha256(string=encoded_hash_string, usedforsecurity=False).hexdigest()

        new_data = {
            "user": user,
            "key": new_key,
            "hwid": "",
            "claimed": False
        }

        data[incremented_key] = new_data

        with open('data/users.json', 'w') as file:
            json.dump(data, file, indent=4)
            read_file.close()
            file.close()
            return "Registered user", 200
