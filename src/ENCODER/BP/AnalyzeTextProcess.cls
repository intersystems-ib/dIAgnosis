Class ENCODER.BP.AnalyzeTextProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.AnalysisRequest, Output pOutput As ENCODER.Message.AnalysisResponse) As %Status
{
        
        set pOutput = ##class(ENCODER.Message.AnalysisResponse).%New()
        set result = ..AnalyzeText(pInput.TextToAnalyze, pInput.AnalysisId, pInput.LanguageSelected)
        set pOutput.AnalysisRequestId = pInput.AnalysisId
        return $$$OK
}

Method AnalyzeText(text As %String, analysisId As %String, language As %String) As %String [ Language = python ]
{
    import sentence_transformers
    import iris
    import requests

    try:
        url = "http://ollama:11434/api/generate"
        data = {
            "model": "llama3.2",
            "prompt": "Extrae en formato CSV los diagnósticos en el siguiente texto sin mostrar diagnósticos que no se observen ni para los que no hay hallazgos patológicos, evita fórmulas de cortesía y notas: "+text,
            "stream": False
        }
        response = requests.post(url, json=data)
        analyzedText = response.json()
        
        model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
        phrases = analyzedText['response'].replace('"',"").split(",")
        sqlsentence = ""
        # iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", "Starting process")
        for phraseToAnalyze in phrases :
            if phraseToAnalyze != "":
                embedding = model.encode(phraseToAnalyze, normalize_embeddings=True).tolist()
                sqlsentence = "INSERT INTO ENCODER_Object.TextMatches (CodeId, Description, Similarity, AnalysisId, RawText) SELECT TOP 50 * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR('"+str(embedding)+"', DECIMAL)) AS Similarity, '"+analysisId+"', '"+phraseToAnalyze+"' FROM ENCODER_Object.Codes) ORDER BY Similarity DESC"                    
                iris.cls("ENCODER.Utils.Manager").ExecuteInsertQuery(sqlsentence)
    except Exception as err:
        iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", repr(err))
        return repr(err)

    return "Success"
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
