Class ENCODER.Message.NotifyRequest Extends Ens.Request
{

Property CodeRequestId As %Integer;

Storage Default
{
<Data name="NotifyRequestDefaultData">
<Subscript>"NotifyRequest"</Subscript>
<Value name="1">
<Value>CodeRequestId</Value>
</Value>
</Data>
<DefaultData>NotifyRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
