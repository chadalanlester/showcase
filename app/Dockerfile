FROM python:3.12-slim
WORKDIR /app
RUN adduser --disabled-password --gecos '' appuser
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY main.py /app/main.py
ENV PORT=8080
EXPOSE 8080
USER appuser
CMD ["python","/app/main.py"]
