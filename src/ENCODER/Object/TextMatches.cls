Class ENCODER.Object.TextMatches Extends (%Persistent, %JSON.Adaptor)
{

Property RawText As %String(MAXLEN = 256);

Property CodeId As %String;

Property Description As %String(MAXLEN = 256);

Property Similarity As %Double(STORAGEDEFAULT = "columnar");

Property AnalysisId As %Integer;

Index AnalysisIndex On AnalysisId;

Storage Default
{
<Data name="TextMatchesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RawText</Value>
</Value>
<Value name="3">
<Value>CodeId</Value>
</Value>
<Value name="4">
<Value>Description</Value>
</Value>
<Value name="5">
<Value>AnalysisId</Value>
</Value>
</Data>
<Data name="_CDM_Similarity">
<Attribute>Similarity</Attribute>
<Structure>vector</Structure>
</Data>
<DataLocation>^ENCODER.Object.TextMatchesD</DataLocation>
<DefaultData>TextMatchesDefaultData</DefaultData>
<IdLocation>^ENCODER.Object.TextMatchesD</IdLocation>
<IndexLocation>^ENCODER.Object.TextMatchesI</IndexLocation>
<StreamLocation>^ENCODER.Object.TextMatchesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
