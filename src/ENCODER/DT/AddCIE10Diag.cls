Class ENCODER.DT.AddCIE10Diag Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A01' create='new' language='objectscript' >
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='source.{DG1()}' property='target.{DG1()}' action='set' />
<assign value='context.codeRequest.Code.CodeId' property='target.{DG1(1):DiagnosisCodeDG1.Identifier}' action='set' />
<assign value='context.codeRequest.Code.Description' property='target.{DG1(1):DiagnosisCodeDG1.Text}' action='set' />
<assign value='"CIE10-ES"' property='target.{DG1(1):DiagnosisCodeDG1.NameofCodingSystem}' action='set' />
<assign value='"A08"' property='target.{MSH:MessageType.TriggerEvent}' action='set' />
</transform>
}

}
