Class ENCODER.DT.ADT01ToCodeRequest Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, ENCODER.Object.CodeRequests) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='ENCODER.Object.CodeRequests' sourceDocType='2.5:ADT_A01' create='new' language='objectscript' >
<assign value='source.{DG1(1):DiagnosisDescription}' property='target.Description' action='set' />
<assign value='$$$JobSessionId' property='target.MessageId' action='set' />
</transform>
}

}
