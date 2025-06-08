## Project Structure

Inside the `app` folder, you’ll find:

- `Dockerfile` — Docker setup to build the Flask app image, including creating a non-root user for security.
- `main.py` — The main Flask application code that serves the API endpoint.
- `requirements.txt` — Lists all the Python packages the app needs to run.
- `.dockerignore` — Specifies files and folders like `__pycache__` and the `Dockerfile` to exclude from the Docker build context.