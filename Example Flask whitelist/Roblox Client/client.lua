script_key = "ilovelife"

-----------------------------------

local player = game:GetService("Players").LocalPlayer
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-----------------------------------

if not script_key or not hwid then print("invalid attempt") return end

local function httpget(url)
    local a = {Method = "GET", Url = url}

    local request = http.request(a)

    return request.Body, request.StatusCode
end


local server = "http://127.0.0.1:5000/api/whitelist".."?key="..script_key.."&hwid="..hwid

local resp, code = httpget(server)

if not resp or resp == "" then return end

if resp == "Whitelisted" and code == 200 then
    print("Whitelisted")
else
    print(resp)
end