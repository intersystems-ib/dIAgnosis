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
    import spacy

    try:
        lematize = ''
        if language == 'es':
            lematize = 'es_dep_news_trf'
        else:
            lematize = 'en_core_web_md'
        
        iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", "Loading lematizer")
        nlp = spacy.load(lematize)

        model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
        phrases = text.split(",")
        sqlsentence = ""
        iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", "Starting process")
        for phraseToAnalyze in phrases :
            if phraseToAnalyze != "":
                doc = nlp(phraseToAnalyze)
                phrase = ""
                phrases = []
                for token in doc:
                    if (token.pos_ == "NOUN" or token.pos_ == "ADJ" or token.pos_ == "DET"):
                        if phrase == "":
                            phrase = token.text
                        else :
                            phrase += " "+token.text
                    else :
                        if phrase != "" and len(phrase.split(" ")) > 1:
                            phrases.append(phrase)
                        phrase = ""
                embeddings = model.encode(phrases, normalize_embeddings=True)
                embeddingList = embeddings.tolist()
                i = 0
                for text in phrases:
                    iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", text)
                    sqlsentence = "INSERT INTO ENCODER_Object.TextMatches (CodeId, Description, Similarity, AnalysisId, RawText) SELECT TOP 50 * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR('"+str(embeddingList[i])+"', DECIMAL)) AS Similarity, '"+analysisId+"', '"+text+"' FROM ENCODER_Object.Codes) WHERE Similarity > 0.6 ORDER BY Similarity DESC"
                    iris.cls("ENCODER.Utils.Manager").ExecuteInsertQuery(sqlsentence)
                    iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", "Sentence finished")
                    
                    i = i + 1
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
