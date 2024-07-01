Class ENCODER.BP.AnalyzeTextProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.AnalysisRequest, Output pOutput As ENCODER.Message.GenericResponse) As %Status
{
        
        set pOutput = ##class(ENCODER.Message.GenericResponse).%New()
        return $$$OK
}

Method AnalyzeText(text As %String) As %String [ Language = python ]
{
    import sentence_transformers

    model = sentence_transformers.SentenceTransformer('/shared/model/')
    phrases = text.replace(","," ").split(".")
    for phrase in phrases:
        words = phrase.split(" ")
        totalWords = len(words)
        i = 0
        while i + 3 < totalWords :
            texts = []
            texts.append(words[i]+" "+words[i+1]+" "+words[i+2])
            i = i+1
        embeddings = model.encode(texts, normalize_embeddings=True)

    
    return "Finished"
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
