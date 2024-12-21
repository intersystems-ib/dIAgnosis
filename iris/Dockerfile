ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-preview
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown -R irisowner:irisowner /opt/irisapp

RUN apt-get update && apt-get install -y python3 && apt-get -y install curl

# install required packages
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /requirements.txt /
RUN chmod 777 /requirements.txt

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/webapp.xml /
RUN chmod +x /webapp.xml

RUN pip3 install -r /requirements.txt --break-system-packages

USER irisowner

# copy files to image
WORKDIR /opt/irisapp
COPY --chown=irisowner:irisowner src src

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/certificates /certificates
RUN chmod +x /certificates

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/irissession.sh /
RUN chmod +x /irissession.sh

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/DemoSetup.Utilities.cls . 
RUN chmod +x /opt/irisapp/DemoSetup.Utilities.cls

SHELL ["/irissession.sh"]

RUN \
  zn "%SYS" \
  do ##class(SYS.Container).QuiesceForBundling() \
  do ##class(Security.Users).UnExpireUserPasswords("*") \
  zn "USER" \
  set sc=##class(%SYSTEM.OBJ).Load("/opt/irisapp/DemoSetup.Utilities.cls","ck") \
  set helper=##class(DemoSetup.Utilities).%New() \ 
  do helper.EnableSSLSuperServer() \
  set sc = $SYSTEM.OBJ.LoadDir("/opt/irisapp/src/Installer", "ck", , 1) \
  if sc do ##class(Installer.Installer).Install()

RUN \
  zn "ENCODER" \
  set sc = $SYSTEM.OBJ.LoadDir("/opt/irisapp/src/ENCODER", "ck", , 1) \
  set production = "ENCODER.Production" \
  set ^Ens.Configuration("csp","LastProduction") = production \
  do ##class(Ens.Director).SetAutoStart(production) \
  zn "%SYS" \
  do ##class(Security.Applications).Import("/webapp.xml",.n)