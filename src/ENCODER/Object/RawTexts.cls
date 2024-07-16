Class ENCODER.Object.RawTexts Extends %Persistent
{

Property RawText As %String(MAXLEN = 5000);

Property AnalysisDate As %TimeStamp;

Storage Default
{
<Data name="RawTextsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RawText</Value>
</Value>
<Value name="3">
<Value>AnalysisDate</Value>
</Value>
</Data>
<DataLocation>^ENCODER.Object.RawTextsD</DataLocation>
<DefaultData>RawTextsDefaultData</DefaultData>
<IdLocation>^ENCODER.Object.RawTextsD</IdLocation>
<IndexLocation>^ENCODER.Object.RawTextsI</IndexLocation>
<StreamLocation>^ENCODER.Object.RawTextsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
