![image](https://github.com/intersystems-ib/dIAgnosis/blob/main/assets/dIAgnosis.png)
# d[IA]gnosis
dIAgnosis is a solution for the diagnostics support using ICD-10 codification (CIE-10 in spanish) based on InterSystems IRIS for Health and a LLM trained using [BioLORD](https://huggingface.co/FremyCompany/BioLORD-2023-M).

d[IA]gnosis uses Embedded Python and the Vector search functionality from IRIS. The front-end is developed in Angular 17. 

# What do you need to install? 
* [Git](https://git-scm.com/downloads) 
* [Docker](https://www.docker.com/products/docker-desktop) (if you are using Windows, make sure you set your Docker installation to use "Linux containers").
* [Docker Compose](https://docs.docker.com/compose/install/)
* [Visual Studio Code](https://code.visualstudio.com/download) + [InterSystems ObjectScript VSCode Extension](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript)

# Setup
Build the image we will use during the workshop:

```console
$ git clone https://github.com/intersystems-ib/dIAgnosis
$ cd dIAgnosis
$ docker-compose build
```

# Introduction

## What is purpose of this project?

The main purpose of this project is to provide to the encoders of a tool to get the exact ICD-10 codes for the diagnostics defined by doctors.

## How does this project work?

This project is designed as a common web application with a backend developed on InterSystems IRIS for Health Community edition and a frontend developed on Angular 17.

## Backend

As we said before, our backend is developed on InterSystems IRIS for Health leveraging the Embedded Python and Vector Search functionalities. The backend is responsible for:
* Import CSV file with the ICD-10 codes using [Embedded Python](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AFL_epython) capabilities.
* Download LLM, vectorization of ICD-10 codes and storing of it.
* Vectorization of diagnostics from HL7 messages and comparison with ICD-10 codes using Vector Search.
* Text analysis to find out diagnoses in raw texts.

## Frontend

Developed on Angular provides an easy to use user interface sending REST calls to the backend and receiving and managing the responses. You don't need any user, the access is free and you will find the following screens:

* List of diagnoses received from HL7 messages into the IRIS production:
![image](https://github.com/intersystems-ib/dIAgnosis/blob/main/assets/hl7_diagnosis.png)

* Administration screen to import ICD codes from a CSV file:
![image](https://github.com/intersystems-ib/dIAgnosis/blob/main/assets/import_icd.png)

* Analysis text screen to analyze raw text and find out diagnoses:
![image](https://github.com/intersystems-ib/dIAgnosis/blob/main/assets/analysis_text.png)

* Screen with a history of text analysis:
![image](https://github.com/intersystems-ib/dIAgnosis/blob/main/assets/analyzed_texts.png)

# Testing the project 
* Run the containers to deploy the backend and the frontend:
```
docker-compose up -d
```
Automatically an IRIS instance will be deployed and a production will be configured and run available to import data to create the prediction model and train it.

* Open the [Management Portal](http://localhost:52774/csp/sys/%25CSP.Portal.Home.zen?$NAMESPACE=ENCODER).
* Login using the default `superuser`/ `SYS` account.
* Click on [Production](http://localhost:52774/csp/healthshare/encoder/EnsPortal.ProductionConfig.zen?$NAMESPACE=ENCODER&) to access the production that we are going to use. You can access also through *Interoperability > User > Configure > Production*.