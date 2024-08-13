# roblox whitelist
note: this example contains 0 security measures and is easily reversable.

## server
even if its not the best & recommended practice, we use a json file to store our keys and users. when our a request is sent by the client, we try to validate if the key exists, then check the hwid stored on that key if it matches the client's hwid. based on that information, we decide whether we whitelist or not.
there is also a second api endpoint 'register user', which makes a key using sha256 with the username as our salt. this could be used for example a custom discord bot.

## client
we simply just send the request to the server using the client's key and hwid, we check for the correct response and then whitelist the client. 

!!! this is easily cracked. if you intend to make your whitelist safe, you could start by adding sanity checks, anti hooking checks and encrypting/hashing your query parameters.
