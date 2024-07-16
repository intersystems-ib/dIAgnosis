Class ENCODER.Object.CodeRequests Extends %Persistent
{

Property MessageId As %String;

Property Description As %String(MAXLEN = 256);

Property Code As ENCODER.Object.Codes;

Property VectorDescription As %Library.Vector(DATATYPE = "DECIMAL", LEN = 768);

Property Notified As %Boolean;

Storage Default
{
<Data name="CodeRequestsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MessageId</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>Code</Value>
</Value>
<Value name="5">
<Value>VectorDescription</Value>
</Value>
<Value name="6">
<Value>Notified</Value>
</Value>
</Data>
<DataLocation>^ENCODER.Object.CodeRequestsD</DataLocation>
<DefaultData>CodeRequestsDefaultData</DefaultData>
<IdLocation>^ENCODER.Object.CodeRequestsD</IdLocation>
<IndexLocation>^ENCODER.Object.CodeRequestsI</IndexLocation>
<StreamLocation>^ENCODER.Object.CodeRequestsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
