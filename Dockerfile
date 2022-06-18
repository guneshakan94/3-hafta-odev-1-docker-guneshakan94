FROM python:alpine
COPY . /uygulama
WORKDIR /uygulama/app
RUN pip install flask
EXPOSE 5000
CMD ["python","app.py"]