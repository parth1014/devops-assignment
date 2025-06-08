FROM python:3.10.17-alpine3.22

# Create non-root user and group
RUN addgroup -S flaskgroup && adduser -S flaskuser -G flaskgroup

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code
COPY . .

# Set permissions
RUN chown -R flaskuser:flaskgroup /app

# Switch to non-root user
USER flaskuser

# Expose port and run app
EXPOSE 8081
CMD ["flask", "--app", "main", "run", "--host=0.0.0.0", "--port=8081"]