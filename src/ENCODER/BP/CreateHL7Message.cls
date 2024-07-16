/// 
Class ENCODER.BP.CreateHL7Message Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='ENCODER.Message.NotifyRequest' response='EnsLib.HL7.Message' height='2000' width='2000' >
<context>
<property name='codeRequest' type='ENCODER.Object.CodeRequests' instantiate='0' />
<property name='code' type='ENCODER.Object.Codes' instantiate='0' />
<property name='originalMessage' type='EnsLib.HL7.Message' instantiate='0' />
<property name='finalMessage' type='EnsLib.HL7.Message' instantiate='0' />
</context>
<sequence xend='200' yend='550' >
<code name='Get original message' xpos='200' ypos='250' >
<![CDATA[ set context.codeRequest = ##class(ENCODER.Object.CodeRequests).%OpenId(request.CodeRequestId)
 set context.originalMessage = ##class(EnsLib.HL7.Message).%OpenId(context.codeRequest.MessageId)
 ]]>
</code>
<transform name='Add encoded diagnosis' class='ENCODER.DT.AddCIE10Diag' source='context.originalMessage' target='context.finalMessage' xpos='200' ypos='350' />
<call name='Send to file' target='HL7_File_Out' async='1' xpos='200' ypos='450' >
<request type='EnsLib.HL7.Message' >
<assign property="callrequest" value="context.finalMessage" action="set" languageOverride="" />
</request>
</call>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
