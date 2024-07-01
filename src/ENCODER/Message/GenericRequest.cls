Class ENCODER.Message.GenericRequest Extends Ens.Request
{

Property FilePath As %String;

Property CodeType As %String;

Storage Default
{
<Data name="GenericRequestDefaultData">
<Subscript>"GenericRequest"</Subscript>
<Value name="1">
<Value>FilePath</Value>
</Value>
<Value name="2">
<Value>CodeType</Value>
</Value>
</Data>
<DefaultData>GenericRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
