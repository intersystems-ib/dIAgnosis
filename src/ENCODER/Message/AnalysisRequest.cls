Class ENCODER.Message.AnalysisRequest Extends Ens.Request
{

Property TextToAnalyze As %String(MAXLEN = 50000);

Property AnalysisId As %String;

Storage Default
{
<Data name="AnalysisRequestDefaultData">
<Subscript>"AnalysisRequest"</Subscript>
<Value name="1">
<Value>TextToAnalyze</Value>
</Value>
<Value name="2">
<Value>AnalysisId</Value>
</Value>
</Data>
<DefaultData>AnalysisRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
