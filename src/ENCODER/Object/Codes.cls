Class ENCODER.Object.Codes Extends %Persistent
{

Property CodeId As %String;

Property Description As %String(MAXLEN = 256);

Property VectorDescription As %Library.Vector(DATATYPE = "DECIMAL", LEN = 768);

Property CodeType As %String;

Index CodeIdIdx On CodeId;

ClassMethod GetEncoding(sentence As %String) As %String [ Language = python, SqlProc ]
{
    import sentence_transformers
    # create the model and form the embeddings
    model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
    embeddings = model.encode(sentence, normalize_embeddings=True).tolist() # Convert search phrase into a vector
    # convert the embeddings to a string
    return str(embeddings)
}

Storage Default
{
<Data name="CodesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CodeId</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>VectorDescription</Value>
</Value>
<Value name="5">
<Value>CodeType</Value>
</Value>
</Data>
<DataLocation>^ENCODER.Object.CodesD</DataLocation>
<DefaultData>CodesDefaultData</DefaultData>
<IdLocation>^ENCODER.Object.CodesD</IdLocation>
<IndexLocation>^ENCODER.Object.CodesI</IndexLocation>
<StreamLocation>^ENCODER.Object.CodesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
