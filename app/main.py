from flask import Flask
import random

app = Flask(__name__)

names = ["Investments", "Smallcase", "Stocks", "buy-the-dip", "TickerTape"]

@app.route("/api/v1/")
def hello_world():
    return random.choice(names)