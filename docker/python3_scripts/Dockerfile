FROM python:3.7.9-slim-buster

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apt-get update && rm -rf /var/lib/apt/lists/*

RUN /usr/local/bin/python -m pip install --upgrade pip && pip install --no-cache-dir -q biopython

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY checkm2csv.py \
     classify_folders.py \
     split_drep.py \
     translate_genes.py \
/tools/

RUN chmod a+x /tools/*

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools