import os
from flask import Flask
from flask import render_template, send_from_directory

app = Flask(__name__, template_folder='./webapp/templates')

@app.route('/')
def show_images():
    return render_template('template.html')

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'favicon.ico', mimetype='image/vnd.microsoft.icon')
