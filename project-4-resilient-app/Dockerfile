FROM python:3.12-slim
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ /app/
ENV PORT=8080
EXPOSE 8080
CMD ["gunicorn","-b","0.0.0.0:8080","app:app","--workers","2","--threads","4"]
