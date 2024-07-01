Class ENCODER.Message.GenericResponse Extends Ens.Response
{

Property Result As %String;

Storage Default
{
<Data name="GenericResponseDefaultData">
<Subscript>"GenericResponse"</Subscript>
<Value name="1">
<Value>Result</Value>
</Value>
</Data>
<DefaultData>GenericResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
