TAG := $(shell date '+%Y%m%d')
PYTHON_VERSION := 3.9.15

build:
	docker build -t softasap/docker-prefect-ecr:2.18-python3.9-$(TAG) .

push:
	docker push  softasap/docker-prefect-ecr:2.18-python3.9-$(TAG)
current-base-image-deps:
	docker run -it prefecthq/prefect:2.18-python3.12-conda cat requirements.txt

#  https://dev.to/mattcale/pyenv-poetry-bffs-20k6
pyenv-install-base:
	pyenv install 3.12.0b1
	pyenv use $(PYTHON_VERSION)
	echo $(PYTHON_VERSION) > .python-version
	curl -sSL https://install.python-poetry.org | python3 -
	poetry --version
	poetry config virtualenvs.in-project true
	poetry config virtualenvs.in-project
	# initialize shell
	poetry shell
