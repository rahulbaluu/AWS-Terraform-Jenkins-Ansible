# Use the official Python image from Docker Hub
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the application files into the container
COPY . /app

# Install the required Python libraries (Flask and other dependencies)
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache

# Expose the port that the app will run on (Flask default is 5000, but we'll change it to 8000)
EXPOSE 8000

# Set environment variables for Flask to run in production mode
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=production

# Run the Flask app directly
CMD ["python", "app.py"]
