Class ENCODER.Message.AnalysisResponse Extends Ens.Response
{

Property AnalysisRequestId As %Integer;

Storage Default
{
<Data name="AnalysisResponseDefaultData">
<Subscript>"AnalysisResponse"</Subscript>
<Value name="1">
<Value>AnalysisRequestId</Value>
</Value>
</Data>
<DefaultData>AnalysisResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
