FROM python:3
LABEL maintainer="Evgeniy Matohin <matohin@gmail.com>"

COPY Pipfile* /
RUN python3 -m pipenv install --system

COPY . /

CMD ["gunicorn", "app:app", "-b :80", "--log-level=debug"]