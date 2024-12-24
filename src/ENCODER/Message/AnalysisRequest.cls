Class ENCODER.Message.AnalysisRequest Extends Ens.Request
{

Property TextToAnalyze As %String(MAXLEN = 50000);

Property AnalysisId As %String;

Property LanguageSelected As %String;

Property UseLLM As %Boolean;

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
<Value name="3">
<Value>LanguageSelected</Value>
</Value>
<Value name="4">
<Value>UseLLM</Value>
</Value>
</Data>
<DefaultData>AnalysisRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
