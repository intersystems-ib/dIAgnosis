/// 
Class ENCODER.BP.HL7ToCodeBPL Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response' height='2000' width='2000' >
<context>
<property name='codeRequest' type='ENCODER.Object.CodeRequests' instantiate='1' />
</context>
<sequence xend='200' yend='450' >
<transform name='From ADT to CodeRequest' class='ENCODER.DT.ADT01ToCodeRequest' source='request' target='context.codeRequest' xpos='200' ypos='250' />
<code name='Save code request' xpos='200' ypos='350' >
<![CDATA[ set vectorDescription = ##class(ENCODER.Utils.Manager).GetEncoding(context.codeRequest.Description)
 set context.codeRequest.VectorDescription = context.codeRequest.VectorDescriptionDisplayToLogical(vectorDescription)
 do context.codeRequest.%Save()
]]>
</code>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
