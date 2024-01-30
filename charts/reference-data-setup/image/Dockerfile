FROM python:3.8-slim-buster
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY geotax_reference_data_extractor.py geotax_reference_data_extractor.py
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["python", "./geotax_reference_data_extractor.py"]