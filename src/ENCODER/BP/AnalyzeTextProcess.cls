Class ENCODER.BP.AnalyzeTextProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.AnalysisRequest, Output pOutput As ENCODER.Message.AnalysisResponse) As %Status
{
        
        set pOutput = ##class(ENCODER.Message.AnalysisResponse).%New()
        if (pInput.UseLLM) {
            set result = ..AnalyzeText(pInput.TextToAnalyze, pInput.AnalysisId, pInput.LanguageSelected)
        }
        else {
            set result = ..AnalyzeTextSimplified(pInput.TextToAnalyze, pInput.AnalysisId, pInput.LanguageSelected)
        }
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
            "prompt": "Extrae únicamente los diagnósticos del siguiente texto separándolos por , y sin añadir interpretaciones: "+text,
            "stream": False
        }
        response = requests.post(url, json=data)
        analyzedText = response.json()
        
        model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
        phrases = analyzedText['response'].split(",")
        sqlsentence = ""
        # iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", "Starting process")
        for phraseToAnalyze in phrases :
            if phraseToAnalyze != "":
                embedding = model.encode(phraseToAnalyze, normalize_embeddings=True).tolist()
                sqlsentence = "INSERT INTO ENCODER_Object.TextMatches (CodeId, Description, Similarity, AnalysisId, RawText) SELECT TOP 50 * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR('"+str(embedding)+"', DECIMAL)) AS Similarity, '"+analysisId+"', '"+phraseToAnalyze+"' FROM ENCODER_Object.Codes) ORDER BY Similarity DESC"                    
                stmt = iris.sql.prepare("INSERT INTO ENCODER_Object.TextMatches (CodeId, Description, Similarity, AnalysisId, RawText) SELECT TOP 50 * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR(?, DECIMAL)) AS Similarity, ?, ? FROM ENCODER_Object.Codes) WHERE Similarity > 0.65 ORDER BY Similarity DESC")                    
                rs = stmt.execute(str(embedding), analysisId, phraseToAnalyze)        
    except Exception as err:
        iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", repr(err))
        return repr(err)

    return "Success"
}

Method AnalyzeTextSimplified(text As %String, analysisId As %String, language As %String) As %String [ Language = python ]
{
    import sentence_transformers
    import iris
    import requests

    try:
        model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
        phrases = text.split(".")
        sqlsentence = ""
        # iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", "Starting process")
        for phraseToAnalyze in phrases :
            if phraseToAnalyze != "":
                embedding = model.encode(phraseToAnalyze, normalize_embeddings=True).tolist()
                stmt = iris.sql.prepare("INSERT INTO ENCODER_Object.TextMatches (CodeId, Description, Similarity, AnalysisId, RawText) SELECT TOP 50 * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR(?, DECIMAL)) AS Similarity, ?, ? FROM ENCODER_Object.Codes) WHERE Similarity > 0.65 ORDER BY Similarity DESC")                    
                rs = stmt.execute(str(embedding), analysisId, phraseToAnalyze)        
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
