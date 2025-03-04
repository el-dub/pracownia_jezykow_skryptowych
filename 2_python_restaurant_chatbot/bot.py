import discord
import requests
from discord.ext import commands

RASA_WEBHOOK_URL = "http://0.0.0.0:5005/webhooks/rest/webhook"
DISCORD_TOKEN = "DISCORD_TOKEN"

intents = discord.Intents.default()
intents.messages = True
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return

    payload = {
        "sender": str(message.author),
        "message": message.content
    }

    rasa_response = requests.post(
        RASA_WEBHOOK_URL,
        json=payload
    )

    if rasa_response.status_code == 200:
        responses = rasa_response.json()
        for response in responses:
            await message.channel.send(response.get("text"))
    else:
        print(rasa_response.json())
        await message.channel.send("No connection to server.")

bot.run(DISCORD_TOKEN)
