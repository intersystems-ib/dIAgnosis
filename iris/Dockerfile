ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-preview
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown -R irisowner:irisowner /opt/irisapp

RUN apt-get update && apt-get install -y python3

# install required packages
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /requirements.txt /
RUN chmod 777 /requirements.txt

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/webapp.xml /
RUN chmod +x /webapp.xml

RUN pip3 install -r /requirements.txt --break-system-packages

RUN spacy download es_core_news_sm --break-system-packages

RUN spacy download en_core_web_sm --break-system-packages

USER irisowner

# copy files to image
WORKDIR /opt/irisapp
COPY --chown=irisowner:irisowner src src

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/irissession.sh /
RUN chmod +x /irissession.sh

SHELL ["/irissession.sh"]

RUN \
  zn "USER" \
  set sc = $SYSTEM.OBJ.LoadDir("/opt/irisapp/src/Installer", "ck", , 1) \
  if sc do ##class(Installer.Installer).Install() \
  zn "ENCODER" \
  set sc = $SYSTEM.OBJ.LoadDir("/opt/irisapp/src/ENCODER", "ck", , 1) \
  set production = "ENCODER.Production" \
  set ^Ens.Configuration("csp","LastProduction") = production \
  do ##class(Ens.Director).SetAutoStart(production) \
  zn "%SYS" \
  do ##class(Security.Applications).Import("/webapp.xml",.n)